import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/pages/auth/sign_in.dart';
import 'package:izinto/pages/auth/get_started.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:izinto/pages/home/home_page.dart';
import 'package:izinto/pages/home/main_components/main_specialty_page.dart';
import 'package:izinto/pages/home/specialty_page_body.dart';
import 'package:izinto/live/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import '../../controllers/otp_controller.dart';
import '../../models/user.dart';
import '../../routes/route_helper.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/big_text.dart';
import 'package:pinput/pinput.dart';

import '../home/home_route.dart';

class PhoneAuth extends StatefulWidget {
  final String? phone;
  const PhoneAuth(this.phone);

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  late String uid;
  late String _verificationCode;
  bool isLoading = false;

  @override
  void dispose() {
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final focusedBorderColor = Colors.blueGrey[300];
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);
    String otp = '';
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      margin: EdgeInsets.symmetric(horizontal: Dimensions.screenWidth / 100),
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: borderColor),
      ),
    );

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
                            fontSize: Dimensions.font16 + 1,
                            color: Colors.grey[500]),
                      ),
                      SizedBox(height: Dimensions.screenHeight * 0.02),
                      RichText(
                        text: TextSpan(
                            text: ' ${widget.phone}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
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
                                    fontFamily: 'Onest',
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
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Directionality(
                        // Specify direction if desired
                        textDirection: TextDirection.ltr,
                        child: Pinput(
                          length: 6,
                          controller: _pinPutController,
                          focusNode: _pinPutFocusNode,
                          androidSmsAutofillMethod:
                              AndroidSmsAutofillMethod.smsUserConsentApi,
                          listenForMultipleSmsOnAndroid: true,
                          defaultPinTheme: defaultPinTheme,
                          onCompleted: (pin) {
                            otp = pin;
                          },
                          onSubmitted: (pin) async {
                            try {
                              await FirebaseAuth.instance
                                  .signInWithCredential(
                                      PhoneAuthProvider.credential(
                                          verificationId: _verificationCode,
                                          smsCode: pin))
                                  .then((value) async {
                                if (value.user != null) {
                                  print('pass to home');
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              HomePage()));
                                }
                              });
                            } catch (e) {
                              SnackBar(
                                margin: EdgeInsets.only(
                                    bottom: Dimensions.screenHeight / 20,
                                    right: Dimensions.screenHeight / 50,
                                    left: Dimensions.screenHeight / 50),
                                elevation: 8,
                                backgroundColor: Color(0xff9A9483),
                                behavior: SnackBarBehavior.floating,
                                content: const Text('Invalid otp'),
                              );
                            }
                          },
                          //validator: (value) {
                          // return value == '222222'
                          //     ? null
                          //     : 'Pin is incorrect';
                          //},
                          // onClipboardFound: (value) {
                          //   debugPrint('onClipboardFound: $value');
                          //   pinController.setText(value);
                          // },

                          hapticFeedbackType: HapticFeedbackType.lightImpact,

                          cursor: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 9),
                                width: 22,
                                height: 1,
                                color: focusedBorderColor,
                              ),
                            ],
                          ),
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                              border: Border.all(color: focusedBorderColor!),
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: fillColor,
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                              border: Border.all(color: focusedBorderColor),
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
                      GestureDetector(
                        onTap: () {
                          OTPController().verifyOTP(otp);
                          setState(() {
                            isLoading = true;
                          });
                        },
                        child: isLoading
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.screenWidth / 16),
                                child: Container(
                                    height: Dimensions.screenHeight / 14,
                                    width: Dimensions.width30 * 15,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Color(0xffCFC5A5),
                                          Color(0xff9A9483),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius15),
                                      // color: const Color(0xff8d7053),
                                    ),
                                    child: Center(
                                      child: Transform.scale(
                                          scale: 1,
                                          child: SimpleCircularProgressBar(
                                            size: 30,
                                            progressColors: const [
                                              Color(0xffCFC5A5)
                                            ],
                                            backColor: Colors.grey[300]!,
                                          )),
                                    )),
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.screenWidth / 16),
                                child: Container(
                                  height: Dimensions.screenHeight / 14,
                                  width: Dimensions.width30 * 15,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        Color(0xffCFC5A5),
                                        Color(0xff9A9483),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radius15),
                                    // color: const Color(0xff8d7053),
                                  ),
                                  child: Center(
                                    child: BigText(
                                      text: 'Validate',
                                      size: Dimensions.font20,
                                      weight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                      )
                    ],
                  ),
                ),
                //
                //
                //
                //
                SizedBox(
                  height: Dimensions.screenHeight * 0.03,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: 'Resend code after ',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: Dimensions.font16 + 1,
                          ),
                          children: [
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Get.to(
                                      () => const GetStarted(),
                                      transition:
                                          Transition.leftToRightWithFade,
                                    ),
                              text: ' 0:59',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff8E806A),
                                  fontSize: Dimensions.font20),
                            ),
                          ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+27${widget.phone!}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              print(
                  'Again user kwetin nantsi ${FirebaseAuth.instance.currentUser?.uid}');
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => HomePage()));
            }
          });
        },
        codeSent: (String verificationID, int? resendToken) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        verificationFailed: (FirebaseAuthException error) {
          print(error.message);
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 60));
  }

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }
}
