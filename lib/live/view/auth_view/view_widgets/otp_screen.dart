import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:izinto/pages/home/home_page.dart';
import 'package:pinput/pinput.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../../../../base/show_snackbar.dart';
import '../../../../pages/auth/get_started.dart';
import '../../../../pages/on_boarding/location_access.dart';
import '../../../../services/firebase_auth_methods.dart';
import '../../../../services/firebase_storage_service.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/main_buttons/otp_verify_button.dart';
import '../../../utilities/generic_snackbar.dart';
import '../../../widgets/text_widgets/description_text.dart';
import 'countdown_controller.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String? verificationId;
  const OtpScreen({Key? key, required this.phone, required this.verificationId})
      : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  bool _isLoading = false;
  String? otpCode;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var otpController = TextEditingController();

  final CountdownController _controller =
      new CountdownController(autoStart: true);

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

  Future<void> _initializeUser(PhoneAuthCredential credential) async {
    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    if (userCredential.user != null) {
      //await _auth.currentUser?.delete(); print('delete passed');
      if (userCredential.additionalUserInfo!.isNewUser) {
        User? user = userCredential.user;

        // create a new document for the user with the uid
        print('new user created');
        await DatabaseService(uid: user?.uid)
            .updateUserData('', '', widget.phone, '', 'Subscribe', 0, '');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => LocationAccess()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));
        print('this is not a new user');
        //sa02HmiOZ0VmUkB7nQSx214KOn43
      }
    }
    // Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(builder: (context) => const HomePage()),
    //     (route) => false);
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  height: Dimensions.height20,
                ),
                Pinput(
                  useNativeKeyboard: true,
                  keyboardAppearance: Brightness.light,
                  defaultPinTheme: PinTheme(
                    width: Dimensions.height45 * 3,
                    height: Dimensions.height45 * 1.3,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 2,
                            offset: Offset(2, 2),
                            color: AppColors.mainBlackColor.withOpacity(0.01),
                          ),
                          BoxShadow(
                            blurRadius: 3,
                            offset: Offset(-5, -5),
                            color: AppColors.iconColor1.withOpacity(0.01),
                          ),
                        ],
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
                        border: Border.all(
                            width: 1,
                            color: const Color(0xffB09B71).withOpacity(0.4)),
                        color: Colors.transparent),
                  ),
                  length: 6,
                  showCursor: true,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      otpCode = value;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      otpCode = value;
                    });
                  },
                  onCompleted: (value) {
                    setState(() {
                      otpCode = value;
                    });
                  },
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),
                // PinFieldAutoFill(
                //     textInputAction: TextInputAction.done,
                //     decoration: UnderlineDecoration(
                //       textStyle: TextStyle(
                //           fontSize: Dimensions.font16,
                //           color: AppColors.paraColor),
                //       colorBuilder:
                //           FixedColorBuilder(Color(0xff8E806A).withOpacity(0.6)),
                //       bgColorBuilder: FixedColorBuilder(Colors.white),
                //     ),
                //     onCodeSubmitted: (code) {
                //       setState(() {
                //         otpCode = code;
                //       });
                //       _controller.pause();
                //     },
                //     controller: textEditingController,
                //     currentCode: otpCode,
                //     onCodeChanged: (code) async {
                //       otpCode = await code!;
                //
                //       try {
                //         PhoneAuthCredential credential =
                //             PhoneAuthProvider.credential(
                //                 verificationId: SignUpPage.verify,
                //                 smsCode: code);
                //
                //         await _initializeUser(credential);
                //         _controller.pause();
                //       } on FirebaseAuthException catch (e) {
                //         showSnackBar(context, e.message!);
                //       }
                //     }
                //     //controller.countdownController.dispose();
                //     ),
                SizedBox(
                  height: Dimensions.height45,
                ),
                Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: OTPCountdown(
                        controller: _controller,
                        phone: widget.phone,
                      )
                      // Builder(
                      //   builder: (_) {
                      //     if (otpCode != null) {
                      //       return OTPCountdown(
                      //         controller: _controller,
                      //         phone: widget.phone,
                      //       );
                      //     }
                      //     return Text("Something went wrong.",
                      //         style: TextStyle(fontSize: 18));
                      //   },
                      // ),
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
                  onTap: () async {
                    FocusScope.of(context).unfocus();

                    print('this is the code currently ${otpCode}');
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                              verificationId: GetStarted.verify,
                              smsCode: otpCode!);

                      _initializeUser(credential);
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        _isLoading = false;
                      });
                      showSnackBar(context, e.message!);
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

class OTPCountdown extends StatelessWidget {
  const OTPCountdown({
    Key? key,
    required CountdownController controller,
    required this.phone,
  })  : _controller = controller,
        super(key: key);

  final CountdownController _controller;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Countdown(
      controller: _controller,
      seconds: 60,
      build: (_, double time) {
        // Convert the time to an integer number of seconds left
        int secondsLeft = time.toInt();

        // Calculate the minutes and remaining seconds
        int minutes = secondsLeft ~/ 60;
        int seconds = secondsLeft % 60;

        // Format the time as a string
        String countdownText = '$minutes:${seconds.toString().padLeft(2, '0')}';

        return countdownText == '0:00'
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _controller.restart();
                      FirebaseAuthMethods().ResendOtp(context, phone);
                    },
                    child: ResendCodeButton(),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DescriptionText(
                    text: 'Resend code after ',
                  ),
                  DescriptionText(
                    text: countdownText,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              );
      },
      interval: Duration(milliseconds: 100),
      onFinished: () {
        GenericSnackBar()
            .showCustomSnackBar(null, context, 'Please try again', false);
      },
    );
  }
}
