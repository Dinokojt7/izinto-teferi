import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:izinto/live/view/auth_view/phone_verification_view.dart';

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

  // Function to handle isInitialize state
  Future<void> onConfirmButtonTapped(BuildContext widgetContext) async {
    if (_isGoogleAuth) {
      await loginWithGoogleAccount(widgetContext);
      _isInitialized = false;
    } else {
      if (_isValid) {
        await onShowTermsDialog();
        _isInitialized = true;
        String phoneNumber = phoneNumberController.text;
        // await _verifyPhone(widgetContext);
        Future.delayed(const Duration(seconds: 4), () async {
          await Navigator.of(widgetContext).push(
            MaterialPageRoute(
              builder: (context) => PhoneVerificationView(
                phone: phoneNumber,
                verificationId: _verificationCode,
              ),
            ),
          );
          _isInitialized = false;
          notifyListeners();
        });
      }
    }

    notifyListeners();
  }

  Future<void> loginWithGoogleAccount(BuildContext? context) async {
    await onShowTermsDialog();
    _isInitialized = true;
    await FirebaseAuthMethods().signInWithGoogle(context!);
    //_isInitialized = false;
    notifyListeners();
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

  _verifyPhone(context) async {
    String phoneNumber = phoneNumberController.text;
    print('let\'s verify $phoneNumber');
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+27${phoneNumber}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => HomeView()));
            }
          });
        },
        codeSent: (String verificationID, int? resendToken) {
          _verificationCode = verificationID;
        },
        verificationFailed: (FirebaseAuthException error) {
          print(error.message);
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          _verificationCode = verificationID;
        },
        timeout: Duration(seconds: 60));

    notifyListeners();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    //loginWithGoogleAccount(null);
    super.dispose();
  }
}
