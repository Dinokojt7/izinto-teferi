import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:izinto/live/view/profile_view/profile_view.dart';
import 'package:izinto/models/user.dart';
import 'package:izinto/services/firebase_storage_service.dart';
import 'package:provider/provider.dart';
import '../base/show_snackbar.dart';
import '../live/utilities/generic_snackbar.dart';
import '../live/view/home_view/home_view.dart';
import '../live/view/profile_view/controller/profile_view_controller.dart';
import '../utils/dimensions.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var verificationId = ''.obs;
  bool isCurrentViewOtp = false;
  bool isExistingUser = false;
  final GoogleSignIn signIn = GoogleSignIn.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final _random = Random();
  final numbers = '1234567890';

  /// Generate 8 random digits from the 'numbers' string
  String generateRandomNumber() {
    String randomNumber = '';
    for (int i = 0; i < 8; i++) {
      randomNumber += numbers[_random.nextInt(numbers.length)];
    }
    return randomNumber;
  }

  //CREATE USER OBJ BASED ON FIREBASE USER
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null
        ? UserModel(
            uid: user.uid,
          )
        : null;
  }

  //AUTH CHANGE USER STREAM
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // EMAIL SIGN UP
  Future<dynamic> signUpWithEmail(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;

      // create a new document for the user with the uid
      await DatabaseService(uid: user?.uid)
          .updateUserData('', '', '', '', 'Subscribe', 0.0, '');
      // await sendEmailVerification(context);
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      SnackBar(
        margin: EdgeInsets.only(
            bottom: Dimensions.screenHeight / 20,
            right: Dimensions.screenHeight / 50,
            left: Dimensions.screenHeight / 50),
        elevation: 8,
        backgroundColor: Color(0xff9A9483),
        behavior: SnackBarBehavior.floating,
        content: Text(e.toString()),
      );

      return null;
    }
  }

  // EMAIL LOGIN
  Future<dynamic> loginWithEmail(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;
      return _userFromFirebaseUser(user);
      // if (!_auth.currentUser!.emailVerified) {
      //   await sendEmailVerification(context);
      // }
    } on FirebaseAuthException catch (e) {
      GenericSnackBar().showCustomSnackBar(
        null, // No onTap callback
        context,
        'Error: ${e.message}',
        false, // isWiderSnack
      );
      return null;
    }
  }

  //DELETE USER ACCOUNT
  Future<dynamic> deleteUser(BuildContext context) async {
    try {
      await _auth.currentUser?.delete();
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .delete();
    } on FirebaseAuthException catch (e) {
      GenericSnackBar().showCustomSnackBar(
        null, // No onTap callback
        context,
        'Error: ${e.message}',
        false, // isWiderSnack
      );
    }
  }

  //CHECK USER DOC IN FIREBASE
  Future<bool> checkUserDocumentExists() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadProfileData(context) async {
    try {
      await Provider.of<ProfileViewController>(context, listen: false)
          .getData();
      await Provider.of<ProfileViewController>(context, listen: false)
          .getAddresses();
    } catch (e) {}
  }

//EMAIL VERIFICATION
  Future<dynamic> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      GenericSnackBar().showCustomSnackBar(
        null, // No onTap callback
        context,
        'Email verification sent!', false, // isWiderSnack
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

//  GOOGLE SIGN IN - Updated using official example pattern
  Future<dynamic> signInWithGoogle(
      BuildContext context, bool termsAccepted) async {
    try {
      // Initialize Google Sign-In
      await GoogleSignIn.instance.initialize();

      // Check if platform supports authenticate
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        GenericSnackBar().showCustomSnackBar(
          null, // No onTap callback
          context,
          'Google Sign-In is not supported on this platform',
          false, // isWiderSnack
        );
        return null;
      }

      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate(scopeHint: ['email']);

      if (googleUser == null) {
        GenericSnackBar().showCustomSnackBar(
            null, context, 'Google Sign-In was cancelled by user', false);
        return null;
      }

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        User? user = userCredential.user;
        String? combinedName = user?.displayName;
        List<String> nameParts = combinedName?.split(" ") ?? ["User"];
        String firstName = nameParts[0];
        String lastName = nameParts.length > 1 ? nameParts[1] : "";

        final _uniquePromoCode = firstName[0] +
            (lastName.isNotEmpty ? lastName[0] : "U") +
            generateRandomNumber();
        final bool _hasFirebaseDocument = await checkUserDocumentExists();
        // Handle new vs existing user
        if (userCredential.additionalUserInfo!.isNewUser ||
            !_hasFirebaseDocument) {
          await DatabaseService(uid: user?.uid).updateUserData(
            firstName,
            lastName,
            user?.phoneNumber ?? "",
            user?.email ?? "",
            'Subscribe',
            0.0,
            _uniquePromoCode,
            termsAccepted: termsAccepted,
            termsAcceptedAt: DateTime.now(),
          );
          await _loadProfileData(context);
          Get.offAll(() => ProfileView());
        } else {
          await _loadProfileData(context);
          await _updateUserTermsAcceptance(user!.uid, termsAccepted);
          Get.offAll(() => HomeView());
        }

        return _userFromFirebaseUser(user);
      } else {
        GenericSnackBar().showCustomSnackBar(
          null,
          context,
          'Authentication failed. Please try again.',
          false,
        );
        return null;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication error';
      if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credentials. Please try again.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'Account not found.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Invalid credentials. Please try again.';
      } else {
        errorMessage = 'Authentication failed: ${e.message}';
      }

      GenericSnackBar().showCustomSnackBar(
        null,
        context,
        errorMessage,
        false,
      );
    } on GoogleSignInException {
      GenericSnackBar().showCustomSnackBar(
        null,
        context,
        'Google Sign-In failed. Please try again.',
        false,
      );
    } catch (e) {
      GenericSnackBar().showCustomSnackBar(
        null,
        context,
        'Something went wrong. Please try again.',
        false,
      );
    }

    return null;
  }

  Future<void> _updateUserTermsAcceptance(
      String uid, bool termsAccepted) async {
    try {
      await _firebaseFirestore.collection('users').doc(uid).update({
        'termsAccepted': termsAccepted,
        'termsAcceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  // Resend otp code from inside the otp view
  Future<dynamic> ResendOtp(BuildContext context, String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (e) {
        GenericSnackBar().showCustomSnackBar(
          null,
          context,
          'Phone verification failed: ${e.message}',
          false,
        );
      },
      codeSent: ((verificationId, int? resendToken) async {
        this.verificationId.value = verificationId;
      }),
      codeAutoRetrievalTimeout: (verificationId) {
        this.verificationId.value = verificationId;
      },
    );
  }

  // void phoneAuthentication(String phoneNo){
  //   phoneAuthLogin(context, phoneNumber)
  // }

  // FORGOT PASSWORD
  Future<dynamic> passwordReset(String _email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: _email);
    } on FirebaseAuthException catch (e) {
      GenericSnackBar().showCustomSnackBar(
        null,
        context,
        'Error: ${e.message}',
        false,
      );
    }
  }
}
