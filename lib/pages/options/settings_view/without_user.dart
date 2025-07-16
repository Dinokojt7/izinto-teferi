import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/pages/options/settings_view/settings_tiles.dart';

import '../../../utils/dimensions.dart';
import '../../../widgets/texts/big_text.dart';
import '../../auth/get_started.dart';
import 'get_help_popup.dart';
import '../../../widgets/texts/small_text.dart';
import 'terms_of_use.dart';
import '../../auth/email_sign_in.dart';
import '../../../live/wrapper.dart';

class SettingViewWithoutUser extends StatelessWidget {
  const SettingViewWithoutUser({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
                child: Column(
                  children: [
                    Row(
                      children: [
                        BigText(
                          size: Dimensions.height18 + Dimensions.height18,
                          text: 'Profile',
                          color: const Color(0Xff353839),
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: Dimensions.width10,
                    ),
                    const Divider(
                      color: Colors.black26,
                      height: 20,
                    ),
                    SizedBox(
                      width: Dimensions.width30,
                    ),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Log in to start planning your next laundry.',
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.04,
                              fontFamily: 'Hind',
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Wrapper()));
                          },
                          child: Container(
                            height: Dimensions.screenHeight / 14.5,
                            width: Dimensions.width30 * 4,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Color(0xffCFC5A5),
                                  Color(0xff9A9483),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                              // color: const Color(0xff8d7053),
                            ),
                            child: Center(
                              child: BigText(
                                text: 'Log in',
                                size: Dimensions.font20,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height30,
                    ),

                    //sign up page
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Don\'t have an account?',
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.2,
                              fontFamily: 'Hind',
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const GetStarted(),
                                transition: Transition.fade,
                                duration: Duration(milliseconds: 1100));
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: Dimensions.font16 / 1.2,
                                fontFamily: 'Hind',
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: Dimensions.width10,
                    ),
                  ],
                ),
              ),
              //Large divider
              Container(
                width: Dimensions.screenWidth,
                color: Colors.grey.withOpacity(0.11),
                height: 20,
              ),
              //Help
              GestureDetector(
                onTap: () {
                  Get.to(() => const GetHelpPopUp(),
                      transition: Transition.rightToLeft,
                      duration: Duration(milliseconds: 100));
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      left: Dimensions.width20,
                      top: Dimensions.height20,
                      bottom: Dimensions.height20 * 1.5),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help,
                        color: Color(0Xff353839),
                      ),
                      SizedBox(
                        width: Dimensions.width20,
                      ),
                      Text(
                        'Help',
                        style: TextStyle(
                            letterSpacing: 0.7,
                            fontSize: Dimensions.font16,
                            color: const Color(0Xff353839),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              //Terms of use
              GestureDetector(
                onTap: () {
                  Get.to(() => const TermsOfUse(),
                      transition: Transition.rightToLeft,
                      duration: Duration(milliseconds: 100));
                },
                child: SettingsTile(
                  icon: Icons.info,
                  title: 'Terms of use',
                ),
              ),
              Spacer(),
              //app version
              Padding(
                padding:
                    EdgeInsets.only(bottom: 10.0, left: Dimensions.width20),
                child: SmallText(text: 'App version: 1 . 0 . 0'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SizedBox(
                  width: Dimensions.width20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
