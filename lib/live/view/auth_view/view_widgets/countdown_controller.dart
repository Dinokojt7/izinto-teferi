import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/auth_view/view_widgets/otp_screen.dart';
import 'package:izinto/pages/home/home_page.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../../../../base/show_snackbar.dart';
import '../../../../models/user.dart';
import '../../../../pages/auth/sign_in.dart';
import '../../../../pages/auth/get_started.dart';
import '../../../wrapper.dart';
import '../../../../pages/on_boarding/location_access.dart';
import '../../../../pages/options/profile_settings.dart';
import '../../../../services/firebase_auth_methods.dart';
import '../../../../services/firebase_storage_service.dart';
import '../../../../services/phone_auth_methods.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/main_buttons/otp_verify_button.dart';
import '../../../../controllers/otp_controller.dart';
import '../../../../controllers/auth/auth_provider.dart';

class OTPAutoFill extends StatefulWidget {
  final String phone;
  final String? verificationId;
  final bool? isExistingUser;

  const OTPAutoFill(
      {Key? key, required this.phone, this.verificationId, this.isExistingUser})
      : super(key: key);

  @override
  State<OTPAutoFill> createState() => _OTPAutoFillState();
}

class _OTPAutoFillState extends State<OTPAutoFill> with CodeAutoFill {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  var verificationId = ''.obs;
  String? appSignature;
  String? otpCode;
  bool _isVerified = false;
  var otpController = TextEditingController();
  bool _isLoading = false;
  final CountdownController _controller =
      new CountdownController(autoStart: true);
  TextEditingController textEditingController = TextEditingController();

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code!;
    });
  }

  @override
  void initState() {
    super.initState();
    listenForCode();
    print('WE ARE ON THIS ROUTE');
  }

  @override
  void dispose() {
    super.dispose();
    cancel();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    // final isLoading =
    //     Provider.of<AuthProvider>(context, listen: true).isLoading;
    const textStyle = TextStyle(fontSize: 18);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: Image(
          image: AssetImage('assets/image/asset.png'),
          height: Dimensions.height20 * 2,
        ),
        iconTheme: const IconThemeData(color: Colors.black, size: 30),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageInfo(
                  phone: widget.phone,
                ),
                PinFieldAutoFill(
                    textInputAction: TextInputAction.done,
                    decoration: UnderlineDecoration(
                      textStyle: TextStyle(
                          fontSize: Dimensions.font16,
                          color: AppColors.paraColor),
                      colorBuilder:
                          FixedColorBuilder(Color(0xff8E806A).withOpacity(0.6)),
                      bgColorBuilder: FixedColorBuilder(Colors.white),
                    ),
                    onCodeSubmitted: (code) {
                      setState(() {
                        otpCode = code;
                      });
                      _controller.pause();
                      //_verifyOtp(context, otpCode!, widget.phone);
                    },
                    controller: textEditingController,
                    currentCode: otpCode,
                    onCodeChanged: (code) async {
                      otpCode = await code!;

                      _controller.pause();
                      try {
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: GetStarted.verify,
                                smsCode: code);
                        await _auth.signInWithCredential(credential);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                            (route) => false);
                      } on FirebaseAuthException catch (e) {
                        showSnackBar(context, e.message!);
                      }
                    }
                    //controller.countdownController.dispose();
                    ),
                SizedBox(
                  height: Dimensions.height45,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Builder(
                      builder: (_) {
                        if (otpCode != null) {
                          return OTPCountdown(
                            controller: _controller,
                            phone: widget.phone,
                          );
                        }
                        return Text("Something went wrong.", style: textStyle);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: Dimensions.height45),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (otpCode != null) {
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Enter 6-Digit OTP code'),
                        ),
                      );
                    }
                  },
                  child: OTPVerifyButton(
                    phoneController: otpController,
                    isLoading: _isLoading,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResendCodeButton extends StatelessWidget {
  const ResendCodeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
      padding: EdgeInsets.only(
          left: Dimensions.width20 * 1.2, right: Dimensions.width15 * 1.2),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Padding(
        padding: EdgeInsets.only(
          top: Dimensions.height20 / 1.8,
          bottom: Dimensions.height20 / 1.8,
        ),
        child: Center(
          child: Text(
            'Resend code',
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: Dimensions.font20 / 1.4,
              fontFamily: 'Poppins',
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class PageInfo extends StatelessWidget {
  final String phone;
  const PageInfo({Key? key, required this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Dimensions.screenHeight * 0.08),
        RichText(
          text: TextSpan(
              text: 'Verification code sent to\n',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black87,
                fontSize: Dimensions.font26,
              ),
              children: [
                TextSpan(
                  text: phone,
                  style: TextStyle(
                      letterSpacing: 0.9,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      fontSize: Dimensions.font26),
                ),
              ]),
        ),
        SizedBox(height: Dimensions.screenHeight * 0.02),
        SizedBox(
          height: Dimensions.screenHeight / 20,
        ),
      ],
    );
  }
}
