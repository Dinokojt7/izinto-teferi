import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/auth_view/phone_verification_view.dart';
import 'package:provider/provider.dart';

import '../../../../services/firebase_storage_service.dart';
import '../../../utilities/generic_snackbar.dart';
import '../../../wrapper.dart';
import '../../profile_view/controller/profile_view_controller.dart';
import '../../profile_view/profile_view.dart';
import '../view_widgets/otp_screen.dart';
import '../../../../pages/auth/phone_auth.dart';
import '../../../../services/firebase_auth_methods.dart';
import '../../home_view/home_view.dart';

class PhoneAuthViewController extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isValid = false;
  bool _isActive = true;
  String _verificationCode = '';
  bool _showTermsDialog = false;
  TextEditingController phoneNumberController = TextEditingController();

  bool get isInitialized => _isInitialized;
  bool get isValid => _isValid;
  bool get isActive => _isActive;
  String get verificationCode => _verificationCode;
  bool get showTermsDialog => _showTermsDialog;

  bool _isGoogleAuth = false;
  bool get isGoogleAuth => _isGoogleAuth;

  Future<void> setAuthContextToGoogle() async {
    _isGoogleAuth = true;
    notifyListeners();
  }

  Future<void> resetAuthContext() async {
    _isGoogleAuth = false;
    notifyListeners();
  }

  //Show terms of use dialog
  Future<void> onShowTermsDialog() async {
    _showTermsDialog = !_showTermsDialog;
    notifyListeners();
  }

  Future<void> displayTermsDialog() async {
    await _onLoader();
    Future.delayed(const Duration(seconds: 2), () {
      _isInitialized = false;
      onShowTermsDialog();
    });
  }

  // Function to handle General terms dialog display
  Future<void> _onLoader() async {
    _isInitialized = true;
    notifyListeners();
  }

  bool _isTermsAccepted = false;
  bool get isTermsAccepted => _isTermsAccepted;
  Future<void> acceptTerms(bool value) async {
    _isTermsAccepted = value;
    notifyListeners();
  }

  // Updated to accept termsAccepted parameter
  Future<void> onConfirmButtonTapped(BuildContext widgetContext) async {
    if (_isGoogleAuth) {
      await loginWithGoogleAccount(widgetContext, _isTermsAccepted);
      _isInitialized = false;
    } else {
      if (_isValid) {
        await onShowTermsDialog();
        _isInitialized = true;
        String phoneNumber = phoneNumberController.text;

        // Verify phone and navigate to OTP screen
        await _verifyPhone(widgetContext, phoneNumber, _isTermsAccepted);
      }
    }
    notifyListeners();
  }

// Check if user document exists in Firestore
  Future<bool> _checkUserDocumentExists(String uid) async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

// Create user document for phone authentication
  // Create user document for phone authentication using DatabaseService
  Future<void> _createPhoneUserDocument({
    required String uid,
    required String phoneNumber,
    required bool termsAccepted,
    required String promoCode,
  }) async {
    try {
      // Use DatabaseService to create user document and save promo code
      await DatabaseService(uid: uid).updateUserData(
        '', // name - empty for phone auth users to fill in later
        '', // surname - empty for phone auth users to fill in later
        phoneNumber, // phone number
        '', // email - empty for phone auth
        'Subscribe', // subscription status
        0.0, // iTokens
        promoCode, // promo code - this will trigger _savePromoCodeToCollection
        termsAccepted: termsAccepted,
        termsAcceptedAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

// Load profile data (reuse existing method)
  Future<void> _loadProfileData(BuildContext context) async {
    try {
      await Provider.of<ProfileViewController>(context, listen: false)
          .getData();
      await Provider.of<ProfileViewController>(context, listen: false)
          .getAddresses();
    } catch (e) {}
  }

// Generate random number (reuse existing method)
  String generateRandomNumber() {
    final numbers = '1234567890';
    final random = Random();
    String randomNumber = '';
    for (int i = 0; i < 8; i++) {
      randomNumber += numbers[random.nextInt(numbers.length)];
    }
    return randomNumber;
  }

  Future<dynamic> _verifyPhone(
      BuildContext context, String phoneNumber, bool termsAccepted) async {
    try {
      String formattedPhone = _formatPhoneNumber(phoneNumber);


      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-sign in if verification completes automatically

          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);

          // Handle user data creation/update after successful authentication
          if (userCredential.user != null) {
            User? user = userCredential.user;

            final _uniquePromoCode = "N" + "U" + generateRandomNumber();
            final bool _hasFirebaseDocument =
                await FirebaseAuthMethods().checkUserDocumentExists();
            if (userCredential.additionalUserInfo!.isNewUser ||
                !_hasFirebaseDocument) {
              await DatabaseService(uid: user?.uid).updateUserData(
                "",
                "",
                phoneNumber,
                "",
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
              Get.offAll(() => Wrapper());
            }
          }

          if (context.mounted) {
            Get.offAll(() => Wrapper());
          }
        },
        codeSent: (String verificationId, int? resendToken) {

          _verificationCode = verificationId;
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PhoneVerificationView(
                  phone: formattedPhone,
                  verificationId: verificationId,
                  termsAccepted: termsAccepted,
                ),
              ),
            );
          }
          _isInitialized = false;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {

          _isInitialized = false;
          if (context.mounted) {
            GenericSnackBar().showCustomSnackBar(
              null,
              context,
              'Failed to verify phone number: ${e.message}',
              false,
            );
          }
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {

          _verificationCode = verificationId;
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {

      _isInitialized = false;
      if (context.mounted) {
        Get.snackbar(
          'Error',
          'Something went wrong. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      notifyListeners();
    }
  }

  Future<void> resendOTP(String phoneNumber, BuildContext context) async {
    await _verifyPhone(
        context, phoneNumber, true); // Assume terms accepted for resend
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Handle South African numbers
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(1);
    }

    if (!digitsOnly.startsWith('27')) {
      digitsOnly = '27$digitsOnly';
    }

    return '+$digitsOnly';
  }

  Future<void> loginWithGoogleAccount(
      BuildContext? context, bool termsAccepted) async {
    await onShowTermsDialog();
    _isInitialized = true;
    await FirebaseAuthMethods().signInWithGoogle(context!, termsAccepted);
    notifyListeners();
  }

  // Update user data with terms acceptance
  Future<void> _updateUserTermsAcceptance(
      String uid, bool termsAccepted) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'termsAccepted': termsAccepted,
        'termsAcceptedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {

    }
  }

  void onPageChange() {
    _isInitialized = true;
    notifyListeners();
  }

  // Function to validate phone number
  void validatePhoneNumber() {
    String phoneNumber = phoneNumberController.text;

    if (phoneNumber.startsWith('0')) {
      _isValid = phoneNumber.length == 10;
    } else if (phoneNumber.startsWith('+27')) {
      if (phoneNumber.startsWith('+270')) {
        _isValid = phoneNumber.length == 13;
      } else if (phoneNumber[3] != '1') {
        _isValid = phoneNumber.length == 12;
      } else {
        _isValid = false;
      }
    } else if (phoneNumber.startsWith('27')) {
      if (phoneNumber.startsWith('270')) {
        _isValid = phoneNumber.length == 12;
      } else if (phoneNumber[2] != '1') {
        _isValid = phoneNumber.length == 11;
      } else {
        _isValid = false;
      }
    } else if (phoneNumber[0] != '1') {
      _isValid = phoneNumber.length == 9;
    } else {
      _isValid = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }
}
