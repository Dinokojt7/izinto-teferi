import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'package:flutter/material.dart';

import '../base/show_snackbar.dart';
import '../models/user.dart';
import 'firebase_storage_service.dart';

class PhoneAuthMethods extends GetxController {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    // update();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);

      User? user = (await _firebaseAuth.signInWithCredential(credential)).user!;

      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }

      _isLoading = false;
      update();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, 'zikhala la ${e.message!}');
      _isLoading = false;
      update();
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
    update();
    try {
      await DatabaseService(uid: uid)
          .updateUserData('', '', '', '', 'Subscribe', 0, '')
          .then((value) {
        _isLoading = false;
        update();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      _isLoading = false;
      update();
    }
  }
}
