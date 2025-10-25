import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:izinto/live/view/profile_view/profile_view.dart';
import 'package:izinto/models/user.dart';
import 'package:izinto/pages/auth/phone_auth.dart';
import 'package:izinto/pages/auth/get_started.dart';
import 'package:izinto/pages/home/specialty_page_body.dart';
import 'package:izinto/routes/route_helper.dart';
import 'package:izinto/services/firebase_storage_service.dart';
import '../base/show_snackbar.dart';
import '../live/view/auth_view/view_widgets/countdown_controller.dart';
import '../live/view/auth_view/view_widgets/otp_screen.dart';
import '../pages/auth/otp_screen.dart';
import '../pages/home/home_page.dart';
import '../pages/on_boarding/location_access.dart';
import '../pages/options/profile_settings.dart';
import '../utils/app_dialog.dart';
import '../utils/dimensions.dart';
import '../utils/showOtpDialog.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var verificationId = ''.obs;
  bool isCurrentViewOtp = false;
  bool isExistingUser = false;

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

  //GETTING USER INSTANCE FROM FIREBASE
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return SpecialtyPageBody();
          } else {
            return const GetStarted();
          }
        });
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
      print(e.toString());
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
      print(e.message);
      return null;
    }
  }

  //DELETE USER ACCOUNT
  Future<dynamic> deleteUser(BuildContext context) async {
    try {
      print('Attempt to delete');

      await _auth.currentUser?.delete();
      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .delete();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  //EMAIL VERIFICATION
  Future<dynamic> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, 'Email verification sent!');
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
  // GOOGLE SIGN IN - Updated approach

//
//  GOOGLE SIGN IN - Updated using official example pattern
  Future<dynamic> signInWithGoogle(
      BuildContext context, bool termsAccepted) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        User? user = userCredential.user;

        // Handle user data
        String? combinedName = user?.displayName;
        List<String> nameParts = combinedName?.split(" ") ?? ["User"];
        String firstName = nameParts[0];
        String lastName = nameParts.length > 1 ? nameParts[1] : "";

        final _uniquePromoCode = firstName[0] +
            (lastName.isNotEmpty ? lastName[0] : "U") +
            generateRandomNumber();

        // Check if new user
        if (userCredential.additionalUserInfo!.isNewUser) {
          // Create a new document for the user with the uid INCLUDING TERMS ACCEPTANCE
          await DatabaseService(uid: user?.uid).updateUserData(
              firstName,
              lastName,
              user?.phoneNumber ?? "",
              user?.email ?? "",
              'Subscribe',
              0.0,
              _uniquePromoCode,
              termsAccepted: termsAccepted, // Add this
              termsAcceptedAt: DateTime.now() // Add this
              );
          Get.offAll(() => ProfileView());
        } else {
          // For existing users, update terms acceptance
          await _updateUserTermsAcceptance(user!.uid, termsAccepted);
          Get.offAll(() => HomePage());
        }
        return _userFromFirebaseUser(user);
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, 'Firebase Auth Error: ${e.message}');
    } on GoogleSignInException catch (e) {
      showSnackBar(context, e.toString());
    } catch (e) {
      showSnackBar(context, 'Google Sign-In failed: $e');
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
    } catch (e) {
      print('Error updating terms acceptance: $e');
    }
  }

  // PHONE SIGN IN
  Future<dynamic> phoneAuthLogin(
      BuildContext context, String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (e) {
        showSnackBar(context, e.message!);
      },
      codeSent: ((verificationId, int? resendToken) async {
        this.verificationId.value = verificationId;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phone: phoneNumber,
              verificationId: verificationId,
            ),
          ),
        );
      }),
      codeAutoRetrievalTimeout: (verificationId) {
        this.verificationId.value = verificationId;
      },
    );
  }

  Future<dynamic> signIinWithPhone(
      BuildContext context, String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (e) {
            showSnackBar(context, e.message!);
          },
          codeSent: (verificationId, int? resendToken) {
            this.verificationId.value = verificationId;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPAutoFill(
                    verificationId: verificationId, phone: phoneNumber),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // Resend otp code from inside the otp view
  Future<dynamic> ResendOtp(BuildContext context, String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (e) {
        showSnackBar(context, e.message!);
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

  // SIGN OUT
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // FORGOT PASSWORD
  Future<dynamic> passwordReset(String _email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: _email);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}
