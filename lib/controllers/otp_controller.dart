import 'package:get/get.dart';
import 'package:izinto/live/wrapper.dart';
import 'package:flutter/material.dart';
import '../pages/on_boarding/location_access.dart';
import '../services/firebase_auth_methods.dart';

class OTPController extends GetxController {
  static OTPController get instance => Get.find();

  void verifyOTP(String otp) async {
    print('Currently running this function');
    var isVerified = false;
    //  await FirebaseAuthMethods().verifyOTP(otp);
    isVerified
        ? Get.to(() => const LocationAccess(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 100))
        : Get.back();
  }
}
