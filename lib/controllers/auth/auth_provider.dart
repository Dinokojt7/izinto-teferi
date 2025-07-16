import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../base/show_snackbar.dart';
import '../../live/view/auth_view/view_widgets/countdown_controller.dart';
import '../../models/user.dart';
import '../../services/firebase_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  AuthProvider() {
    checkSignIn();
  }

  void checkSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool('is_signedin') ?? false;
    notifyListeners();
  }

  //sign in
  void signIinWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _firebaseAuth.signInWithCredential(credential);
          },
          verificationFailed: (e) {
            showSnackBar(context, e.message!);
          },
          codeSent: (verificationId, int? resendToken) {
// this.verificationId.value = verificationId;

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

  // verify otp
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);

      User? user = (await _firebaseAuth.signInWithCredential(credential)).user!;

      if (user != null) {
        _uid = user.uid;
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      _isLoading = false;
      notifyListeners();
    }
  }

  // IS INSIDE DATABASE?
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection('users').doc(_uid).get();

    if (snapshot.exists) {
      print('USER EXIST IN THE DATABASE');
      return true;
    } else {
      print('NEW USER DOCUMENT CREATED');
      return false;
    }
  }

  //WRITE NEW USER
  void saveUserDataToFirebase({
    required BuildContext context,
    UserModel? userModel,
    Function? onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await DatabaseService(uid: uid)
          .updateUserData('', '', '', '', 'Subscribe', 0, '')
          .then((value) {
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      _isLoading = false;
      notifyListeners();
    }
  }
}
