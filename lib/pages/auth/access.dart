import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:izinto/pages/auth/get_started.dart';
import 'package:izinto/services/location/location_model.dart';
import 'package:izinto/widgets/texts/small_text.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/pages/auth/email_sign_in.dart';
import 'package:izinto/pages/auth/login.dart';
import 'package:izinto/pages/auth/sign_in.dart';
import 'package:provider/provider.dart';
import '../../live/view/auth_view/view_widgets/countdown_controller.dart';
import '../../models/user.dart';
import '../../services/firebase_auth_methods.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/dialogs/subscription_dialogs/subscription_dialog.dart';
import '../../widgets/main_buttons/payment_checkout_button.dart';
import '../../widgets/dialogs/main_dialog.dart';
import '../../widgets/texts/big_text.dart';
import '../../widgets/texts/integers_and_doubles.dart';
import '../on_boarding/location_access.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';

import '../options/profile_settings.dart';
import '../options/settings_view/terms_of_use.dart';
import 'bottom_access_buttons/continue_with_google.dart';
import 'bottom_access_buttons/login_later.dart';

class Access extends StatefulWidget {
  const Access({Key? key}) : super(key: key);

  @override
  State<Access> createState() => _AccessState();
}

class _AccessState extends State<Access> {
  Color _randomStatusColor = Colors.white;

  Color _randomNavigationColor = Colors.white;

  bool? _useWhiteStatusBarForeground;

  bool? _useWhiteNavigationBarForeground;

  @override
  initState() {
    super.initState();
    changeStatusColor(Colors.black54);
  }

  @override
  dispose() {
    super.dispose();
  }

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

  changeStatusColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
      if (useWhiteForeground(color)) {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
        _useWhiteStatusBarForeground = true;
        _useWhiteNavigationBarForeground = true;
      } else {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double logicalPixels = 680.0;
      double screenHeight = MediaQuery.of(context).size.height;
      bool isSmallestDevice = screenHeight <= logicalPixels;
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(
                    Dimensions.screenHeight / 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Get.to(() => const EmailSignIn(),
                          //     transition: Transition.fade,
                          //     duration: Duration(seconds: 1));
                        },
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.only(
                                bottom: Dimensions.screenHeight / 30),
                            child: Image(
                              image: AssetImage('assets/image/asset.png'),
                              height: Dimensions.height20 * 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Dimensions.screenHeight / 25,
                      ),
                      if (!isSmallestDevice) IntroText(),
                      if (isSmallestDevice)
                        SizedBox(
                          height: Dimensions.screenHeight / 30,
                        ),
                      if (!isSmallestDevice)
                        SizedBox(
                          height: Dimensions.screenHeight / 20,
                        ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Get.to(() => const GetStarted(),
                              transition: Transition.fade,
                              duration: Duration(seconds: 1));
                        },
                        child: SignInBox(
                          icon: Icons.person,
                          text: 'Get Started',
                        ),
                      ),
                      SizedBox(
                        height: Dimensions.screenHeight / 30,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Get.to(() => const GetStarted(),
                              transition: Transition.fade,
                              duration: Duration(seconds: 1));
                        },
                        child:
                            SignInBox(icon: Icons.login_rounded, text: 'Login'),
                      ),
                      SizedBox(
                        height: Dimensions.screenHeight / 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ContinueWithGoogle(),
                          SizedBox(
                            width: Dimensions.width20,
                          ),
                          LoginLater(),
                        ],
                      ),
                      SizedBox(
                        height: Dimensions.screenHeight / 50,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Stack(
          children: [
            Container(
              height: Dimensions.bottomHeightBar / 1.7,
              decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                  image: const AssetImage('assets/image/wallpaper.jpeg'),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xff9A9483).withOpacity(0.2),
                    Color(0xffCFC5A5).withOpacity(0.2),
                  ],
                ),
              ),
            ),
            Container(
              height: Dimensions.bottomHeightBar / 1.7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.transparent
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const TermsOfUse(),
                          transition: Transition.rightToLeft,
                          duration: Duration(milliseconds: 100));
                    },
                    child: IntegerText(
                      text: 'Terms & Conditions',
                      size: Dimensions.font16 / 1.2,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}

class IntroText extends StatelessWidget {
  const IntroText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Welcome, let\'s get\n',
          style: TextStyle(
            fontSize: Dimensions.font26 * 1.1,
            fontFamily: 'Poppins',
            color: AppColors.mainBlackColor,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
              text: 'you started quickly',
              style: TextStyle(
                fontSize: Dimensions.font26 * 1.1,
                fontFamily: 'Poppins',
                color: AppColors.mainBlackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInBox extends StatelessWidget {
  const SignInBox({Key? key, required this.icon, required this.text})
      : super(key: key);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          width: 1.5,
          color: Colors.grey.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(Dimensions.radius20 * 1.5),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.width15 * 2.3,
              //  horizontal: Dimensions.width15 / 1.2
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  //register
                  child: IntegerText(
                    text: text,
                    size: Dimensions.font20 / 1.1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fontColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: Dimensions.width20,
            top: Dimensions.width20,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.5,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(Dimensions.radius20 * 3),
                  ),
                  color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  icon,
                  size: Dimensions.height15 * 1.4,
                  color: Color(0xff9A9483),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
