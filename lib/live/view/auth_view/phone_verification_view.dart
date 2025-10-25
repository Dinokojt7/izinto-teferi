import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/widgets/text_widgets/description_text.dart';
import 'package:izinto/live/view/auth_view/view_widgets/top_logo.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../utils/dimensions.dart';
import '../../widgets/text_widgets/introduction_text.dart';
import '../home_view/home_view.dart';
import 'controller/phone_auth_view_controller.dart';

class PhoneVerificationView extends StatefulWidget {
  final String phone;
  final String verificationId;
  const PhoneVerificationView({
    Key? key,
    required this.phone,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<PhoneVerificationView> createState() => _PhoneVerificationViewState();
}

class _PhoneVerificationViewState extends State<PhoneVerificationView> {
  bool _isVerifying = false;
  final CountdownController _countdownController =
      CountdownController(autoStart: true);
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  String? _appSignature;

  @override
  void initState() {
    super.initState();
    _getAppSignature();
    _listenForCode();
  }

  Future<void> _getAppSignature() async {
    try {
      _appSignature = await SmsAutoFill().getAppSignature;
      print('App Signature: $_appSignature');
    } catch (e) {
      print('Error getting app signature: $e');
    }
  }

  void _listenForCode() {
    SmsAutoFill().code.listen((code) {
      if (code != null && code.length == 6) {
        _pinPutController.text = code;
        _verifyOTP(code);
      }
    });
  }

  Future<void> _verifyOTP(String pin) async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: pin,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Get.offAll(() => HomeView());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        backgroundColor: Color(0xff9A9483),
        colorText: Colors.white,
      );
      // Clear the OTP field on error
      _pinPutController.clear();
      _pinPutFocusNode.requestFocus();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        backgroundColor: Color(0xff9A9483),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _resendOTP() {
    final controller =
        Provider.of<PhoneAuthViewController>(context, listen: false);
    controller.resendOTP(widget.phone, context);
    _countdownController.restart();
    Get.snackbar(
      'Success',
      'OTP has been resent',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
        fontSize: Dimensions.font20,
        fontFamily: 'Onest',
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(
          width: 1.5,
          color: Colors.grey[300]!,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimensions.width20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopLogo(),
              SizedBox(height: Dimensions.height45),

              // Responsive title
              IntroductionText(
                text: 'Verification code sent to',
                textSize: Dimensions.font20,
                maxLines: 2,
              ),

              IntroductionText(
                text: widget.phone,
                textSize: Dimensions.font20,
                maxLines: 2,
              ),

              SizedBox(height: Dimensions.height20),

              // Responsive description
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DescriptionText(
                    text: 'Enter verification code below.',
                    maxLines: 2,
                  ),
                  SizedBox(width: Dimensions.width10),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Change number',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontFamily: 'Poppins',
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Dimensions.height30),

              // OTP Input Field using Pinput
              Pinput(
                length: 6,
                controller: _pinPutController,
                focusNode: _pinPutFocusNode,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: Colors.blue),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: Colors.green[50],
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    border: Border.all(color: Colors.red),
                  ),
                ),
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (pin) => _verifyOTP(pin),
                onChanged: (value) {
                  // Auto-submit when 6 digits are entered
                  if (value.length == 6) {
                    _verifyOTP(value);
                  }
                },
              ),

              // SMS Autofill hint
              Padding(
                padding: EdgeInsets.only(top: Dimensions.height10),
                child: Text(
                  'Make sure SMS read permission is enabled for auto-fill',
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.2,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: Dimensions.height30),

              // Continue Button
              SaveButton(
                isActive: _pinPutController.text.length == 6 && !_isVerifying,
                isLoading: _isVerifying,
                description: _isVerifying ? 'Verifying...' : 'Continue',
                isAuthScreen: false,
                onTap: () {
                  if (_pinPutController.text.length == 6) {
                    _verifyOTP(_pinPutController.text);
                  }
                },
              ),

              SizedBox(height: Dimensions.height20),

              // Countdown Timer with Resend
              _buildCountdownTimer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Center(
      child: Countdown(
        controller: _countdownController,
        seconds: 60,
        build: (BuildContext context, double time) {
          return Column(
            children: [
              Text(
                '${time.toInt()} seconds',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: Dimensions.height10),
              if (time == 0)
                TextButton(
                  onPressed: _resendOTP,
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
        },
        interval: Duration(seconds: 1),
        onFinished: () {
          setState(() {});
        },
      ),
    );
  }
}
