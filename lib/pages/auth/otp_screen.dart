import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/pages/auth/sign_in.dart';
import 'package:izinto/services/firebase_auth_methods.dart';
import 'package:izinto/widgets/main_buttons/continue_button.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import '../../controllers/otp_controller.dart';
import '../../utils/dimensions.dart';

class OTPScreen extends StatefulWidget {
  final String? phone;
  const OTPScreen(this.phone);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var otp;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xff8E806A), size: 30),
        backgroundColor: const Color(0xfffefafa),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: Dimensions.screenHeight * 0.03),
                Container(
                  margin: EdgeInsets.only(left: Dimensions.width20),
                  width: double.maxFinite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimensions.screenHeight * 0.03),
                      Text(
                        'Verification code',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black45,
                            fontSize: Dimensions.font16 + 8,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: Dimensions.height10,
                      ),
                      Text(
                        'We have sent the verification code to',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font16 + 1,
                            color: Colors.grey[500]),
                      ),
                      SizedBox(height: Dimensions.screenHeight * 0.02),
                      RichText(
                        text: TextSpan(
                            text: ' ${widget.phone}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: Dimensions.font16 + 1,
                            ),
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Get.to(
                                        () => const SignIn(),
                                        transition:
                                            Transition.leftToRightWithFade,
                                      ),
                                text: ' Change phone number?',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff8E806A),
                                    fontSize: Dimensions.font20),
                              ),
                            ]),
                      ),
                      SizedBox(
                        height: Dimensions.screenHeight / 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Dimensions.screenHeight / 20,
                ),
                OTPTextField(
                  style: TextStyle(fontFamily: 'Poppins'),
                  otpFieldStyle: OtpFieldStyle(
                      backgroundColor: Colors.black.withOpacity(0.1),
                      focusBorderColor: Color(0xff8E806A)),
                  keyboardType: TextInputType.number,
                  length: 6,
                  fieldStyle: FieldStyle.box,
                  width: MediaQuery.of(context).size.width,
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldWidth: 45,
                  outlineBorderRadius: 15,
                  onCompleted: (pin) {
                    otp = pin;
                    OTPController().verifyOTP(otp);
                  },
                ),
                SizedBox(
                  height: Dimensions.screenHeight / 20,
                ),
                GestureDetector(
                  onTap: () {
                    OTPController().verifyOTP(otp);
                  },
                  child: SizedBox(
                      width: double.infinity,
                      child: ContinueButton(
                          isLoading: isLoading, cto: 'Continue')),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
