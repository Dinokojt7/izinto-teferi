import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/auth_view/view_widgets/otp_screen.dart';
import 'package:izinto/live/widgets/text_widgets/description_text.dart';
import 'package:izinto/live/view/auth_view/view_widgets/top_logo.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../../../controllers/otp_controller.dart';
import '../../../pages/auth/get_started.dart';
import '../../../pages/notifications/inbox_view.dart';
import '../../../utils/dimensions.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/text_widgets/introduction_text.dart';
import '../home_view/home_view.dart';
import 'controller/phone_auth_view_controller.dart';

class PhoneVerificationView extends StatelessWidget {
  final String phone;
  final String? verificationId;
  const PhoneVerificationView(
      {Key? key, required this.phone, this.verificationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SystemNavigation()
    //     .applyCustomSystemChromeSettings(Colors.white, Brightness.dark);
    return Consumer<PhoneAuthViewController>(
        builder: (context, controller, child) {
      Future<void> _verifyOTP(String pin) async {
        try {
          await FirebaseAuth.instance
              .signInWithCredential(PhoneAuthProvider.credential(
            verificationId: controller.verificationCode,
            smsCode: pin,
          ))
              .then((value) async {
            if (value.user != null) {
              print('pass to home');
              // Use GetX navigation instead of Navigator
              Get.offAll(() => HomeView());
            }
          });
        } catch (e) {
          // Show proper snackbar
          Get.snackbar(
            'Error',
            'Invalid OTP',
            backgroundColor: Color(0xff9A9483),
            colorText: Colors.white,
          );
        }
      }

      String otp = '';
      String _verificationCode = controller.verificationCode;
      String phoneNumber = controller.phoneNumberController.text;
      final CountdownController _controller =
          new CountdownController(autoStart: true);
      final TextEditingController _pinPutController = TextEditingController();
      final FocusNode _pinPutFocusNode = FocusNode();
      final defaultPinTheme = PinTheme(
        width: 50,
        height: 40,
        margin: EdgeInsets.symmetric(horizontal: Dimensions.screenWidth / 100),
        textStyle: const TextStyle(
          fontSize: 20,
          fontFamily: 'Onest',
          color: Colors.black87,
        ),
        decoration: BoxDecoration(
          color: Colors.black12.withOpacity(0.001),
          borderRadius: BorderRadius.circular(Dimensions.radius15 / 1.5),
          border: Border.all(
            width: 0.5,
            color: Colors.black54.withOpacity(0.5),
          ),
        ),
      );
      return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.97),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: Padding(
          padding: EdgeInsets.only(
              left: 26.0, top: Dimensions.height15, right: 26.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopLogo(),
              SizedBox(height: Dimensions.height45 * 1.6),
              IntroductionText(text: 'Verification code  sent to'),
              IntroductionText(text: '$phoneNumber'),
              SizedBox(
                height: Dimensions.height20,
              ),
              Row(
                children: [
                  DescriptionText(
                    text: 'Enter verification code bellow.',
                  ),
                  SizedBox(
                    width: Dimensions.width10 / 1.5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Change number',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: Dimensions.font20 / 1.5,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: Dimensions.height30 * 1.2,
              ),
              Directionality(
                // Specify direction if desired
                textDirection: TextDirection.ltr,
                child: Pinput(
                  length: 6,
                  controller: _pinPutController,
                  focusNode: _pinPutFocusNode,
                  // Remove these deprecated lines:
                  // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                  // listenForMultipleSmsOnAndroid: true,
                  defaultPinTheme: defaultPinTheme,
                  onCompleted: (pin) {
                    otp = pin;
                    // Add auto-verification here
                    _verifyOTP(pin);
                  },
                  // Remove the deprecated onSubmitted for OTP
                  // onSubmitted: (pin) async {
                  //   await _verifyOTP(pin);
                  // },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                      ),
                    ],
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: Colors.black12.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border: Border.all(color: Colors.redAccent),
                  ),
                ),
              ),
              SizedBox(
                height: Dimensions.screenHeight / 20,
              ),
              SaveButton(
                isActive: false,
                description: 'Continue',
                isAuthScreen: false,
                onTap: () {
                  if (_pinPutController.text.length == 6) {
                    _verifyOTP(_pinPutController.text);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter 6-digit OTP',
                      backgroundColor: Color(0xff9A9483),
                      colorText: Colors.white,
                    );
                  }
                },
              ),
              SizedBox(
                height: Dimensions.screenHeight * 0.03,
              ),
              OTPCountdown(
                controller: _controller,
                phone: phone,
              )
            ],
          ),
        ),
      );
    });
  }
}
