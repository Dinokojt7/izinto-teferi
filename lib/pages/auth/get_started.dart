import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'package:izinto/base/custom_loader.dart';
import 'package:izinto/base/show_custom_snackbar.dart';
import 'package:izinto/controllers/auth_controller.dart';
import 'package:izinto/models/sign_up_body_model.dart';
import 'package:izinto/routes/route_helper.dart';
import 'package:izinto/services/firebase_auth_methods.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/texts/big_text.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_provider.dart';
import '../../live/view/auth_view/view_widgets/countdown_controller.dart';
import '../../live/view/auth_view/view_widgets/otp_screen.dart';
import '../../utils/colors.dart';
import '../../widgets/main_buttons/login_button.dart';
import '../../widgets/main_buttons/phone_auth_button.dart';
import '../../widgets/texts/app_text_field.dart';
import '../notifications/inbox_view.dart';
import '../options/settings_view/terms_of_use.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({Key? key, this.pageId}) : super(key: key);

  static String verify = '';
  final String? pageId;

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  var phoneController = TextEditingController();
  Color _containerColor = Colors.white.withOpacity(0.5);
  bool isChecked = false;
  bool isTextChanged = false;
  bool isProcessing = false;
  @override
  void initState() {
    super.initState();
    changeStatusColor(Color(0xff9A9483).withOpacity(0.6), true);
    phoneController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    phoneController.dispose();
    if (widget.pageId == 'splash') {
      changeStatusColor(Color(0xFFCFC5A5).withOpacity(0.3), true);
    } else {
      changeStatusColor(Colors.transparent, false);
    }
    super.dispose();
  }

  bool? _useWhiteStatusBarForeground;

  bool? _useWhiteNavigationBarForeground;

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_useWhiteStatusBarForeground != null)
        FlutterStatusbarcolor.setStatusBarWhiteForeground(
            _useWhiteStatusBarForeground!);
      if (_useWhiteNavigationBarForeground != null)
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(
            _useWhiteNavigationBarForeground!);
    }
  }

  changeStatusColor(Color color, bool useWhiteForeground) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
      if (useWhiteForeground) {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
        _useWhiteStatusBarForeground = false;
        _useWhiteNavigationBarForeground = true;
      } else {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
        _useWhiteStatusBarForeground = false;
        _useWhiteNavigationBarForeground = false;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  changeNavigationColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setNavigationBarColor(color, animate: true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onTextChanged() {
    // Check if there is any text in the TextField
    if (phoneController.text.isNotEmpty) {
      setState(() {
        // Change the color when there is text
        //_containerColor = Colors.transparent;
        isTextChanged = true;
      });
    } else {
      setState(() {
        // Reset the color when there is no text
        //_containerColor = Colors.white.withOpacity(0.5);
        isTextChanged = false;
      });
    }
  }

  phoneSignIn() async {
    try {
      final user = await FirebaseAuthMethods()
          .phoneAuthLogin(context, '+27${phoneController.text}')
          .then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(value.user.uid)
            .set({'phoneNumber': value.user.phoneController.text});
      });
      if (user != null) {

        Get.toNamed(RouteHelper.getInitial());
      }
    } catch (e) {

    }
  }

  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    ap.signIinWithPhone(context, phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    void validateAndModifyPhone(String phone) {
      if (phone.isEmpty || phone == 'Phone') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number is required'),
          ),
        );
      } else if (phone.startsWith('+27')) {
        // Already has country code, do nothing
        if (phone.length > 12 || phone.length < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid phone number format'),
            ),
          );
        } else {
          setState(() {
            isLoading = true;
          });
        }
      } else if (phone.startsWith('0')) {
        // Modify phone with country code
        if (phone.length > 12 || phone.length < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              elevation: 0,
              backgroundColor: Color(0xff9A9484).withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              content: Text('Invalid phone number format'),
            ),
          );
        } else {
          phoneController.text = '+27' + phone.substring(1);
          setState(() {
            isLoading = true;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            elevation: 0,
            backgroundColor: Color(0xff9A9484).withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            content: Text('Invalid phone number format'),
          ),
        );
      }
    }

    double logicalPixels = 640.0;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallestDevice = screenHeight <= logicalPixels;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          false, // Set this to true to allow resizing when the keyboard appears
      body: GetBuilder<AuthController>(builder: (_authController) {
        return Stack(
          children: [
            Stack(
              children: [
                Center(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Spacer(),
                          SizedBox(
                            height: Dimensions.height30,
                          ),
                          Image(
                            image: AssetImage('assets/image/artwork.png'),
                            height: Dimensions.height20 * 2.5,
                          ),
                          Spacer(),
                          SizedBox(
                            height: Dimensions.height10,
                          ),

                          Text(
                            'Sign in',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: Dimensions.font16 * 1.5,
                                color: AppColors.fontColor),
                          ),
                          Spacer(),
                          //Main text fields
                          //phone
                          TextFormField(
                            controller: phoneController,
                            validator: (val) {
                              validateAndModifyPhone(val!);
                              return null; // Validation will be done via the Snackbar
                            },
                            keyboardType: TextInputType.phone,
                            obscureText: false,
                            cursorColor: Color(0xffCFC5A5),
                            decoration: InputDecoration(
                              labelText: 'Mobile',
                              floatingLabelStyle: TextStyle(
                                  color: AppColors.secondary,
                                  fontFamily: 'Poppins'),
                              contentPadding:
                                  EdgeInsets.only(bottom: 2, left: 20),

                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              hintText: 'Enter phone number',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font16 / 1.2,
                                fontWeight: FontWeight.w500,
                                color: AppColors.fontColor.withOpacity(0.7),
                              ),

                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(Dimensions.radius15),
                                  ),
                                  borderSide: BorderSide(
                                      width: 0.7, color: AppColors.secondary)),
                              //enabled border
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(Dimensions.radius15),
                                ),
                                borderSide: BorderSide(
                                    width: 0.6,
                                    color: Colors.grey.withOpacity(0.7)),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(Dimensions.radius15),
                                ),
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          RichText(
                            text: TextSpan(
                              text:
                                  'We\'ll send OTP to this number for verification',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.fontColor,
                                  fontSize: Dimensions.font16 / 1.2),
                            ),
                          ),
                          SizedBox(
                            height: Dimensions.height30,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  if (isChecked) {
                                    //  await _signUpWithPhone();
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isProcessing = true;
                                      });
                                      await FirebaseAuth.instance
                                          .verifyPhoneNumber(
                                              phoneNumber:
                                                  phoneController.text.trim(),
                                              verificationCompleted:
                                                  (PhoneAuthCredential
                                                      credential) {},
                                              verificationFailed:
                                                  (FirebaseAuthException e) {},
                                              codeSent: (String verificationId,
                                                  int? resendToken) {
                                                GetStarted.verify =
                                                    verificationId;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OtpScreen(
                                                      phone: phoneController
                                                          .text
                                                          .trim(),
                                                      verificationId:
                                                          verificationId,
                                                    ),
                                                  ),
                                                );
                                                setState(() {
                                                  isLoading = false;
                                                  isProcessing = false;
                                                });
                                              },
                                              codeAutoRetrievalTimeout:
                                                  (String verificationId) {});
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(seconds: 2),
                                        elevation: 0,
                                        backgroundColor:
                                            Color(0xff9A9484).withOpacity(0.9),
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                            'Please accept the terms of service'),
                                      ),
                                    );
                                  }
                                },
                                child: PhoneAuthButton(
                                  phoneController: phoneController,
                                  isLoading: isLoading,
                                  hasAcceptedTerms: isChecked,
                                ),
                              ),
                              !isTextChanged
                                  ? Container(
                                      height: Dimensions.screenHeight / 14,
                                      width: Dimensions.width30 * 15,
                                      decoration:
                                          BoxDecoration(color: _containerColor),
                                    )
                                  : Container()
                            ],
                          ),
                          Spacer(),
                          Spacer(), Spacer(), Spacer()
                          //name

                          //phone
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(bottom: Dimensions.height30, left: 15),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isChecked = !isChecked;
                            });
                          },
                          child: Container(
                            height: Dimensions.height20 * 1.25,
                            width: Dimensions.height20 * 1.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radius15 / 1.5),
                              border: Border.all(
                                width: 0.9,
                                color: AppColors.titleColor
                                    .withOpacity(0.7), // Border color
                              ),
                            ),
                            child: Checkbox(
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  // Update the boolean variable when the checkbox is clicked
                                  isChecked = value!;
                                });
                              },
                              side: BorderSide.none,
                              checkColor: Colors.black, // Checkmark color
                              activeColor: Colors.transparent,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Dimensions.width10,
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.titleColor.withOpacity(0.7),
                                  fontSize: Dimensions.font16 / 1.3),
                            ),
                          ]),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const TermsOfUse(),
                                transition: Transition.rightToLeft,
                                duration: Duration(milliseconds: 100));
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Terms of Service ',
                              style: TextStyle(
                                  color: AppColors.secondary,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: Dimensions.font16 / 1.3),
                            ),
                          ),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'and ',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.titleColor.withOpacity(0.7),
                                  fontSize: Dimensions.font16 / 1.3),
                            ),
                          ]),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const TermsOfUse(),
                                transition: Transition.rightToLeft,
                                duration: Duration(milliseconds: 100));
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                  color: AppColors.secondary,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: Dimensions.font16 / 1.3),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isProcessing
                ? Container(
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  )
                : Container()
          ],
        );
      }),
    );
  }
}
