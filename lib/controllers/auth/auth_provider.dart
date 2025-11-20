import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../base/show_snackbar.dart';
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
      return true;
    } else {
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
