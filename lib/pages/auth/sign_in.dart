import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/pages/auth/phone_auth.dart';
import 'package:izinto/pages/home/home_page.dart';
import '../../routes/route_helper.dart';
import '../../services/firebase_auth_methods.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/app_text_field.dart';
import '../../widgets/texts/big_text.dart';
import '../../live/wrapper.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  TextEditingController phoneController = TextEditingController();

  Future<dynamic> phoneSignIn() async {
    try {
      Get.toNamed(RouteHelper.getPhoneAuth());
      await FirebaseAuthMethods()
          .phoneAuthLogin(context, '+27${phoneController.text}');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          //here
          FocusScope.of(context).unfocus();
          new TextEditingController().clear();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(Dimensions.screenHeight / 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Wrapper()));
                          },
                          child: Icon(
                            Icons.close,
                            size: Dimensions.iconSize26,
                            color: Colors.black38,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        HomePage()));
                          },
                          child: Text(
                            'Later',
                            style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w500,
                                fontSize: Dimensions.font16 * 1.19),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.height30,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            BigText(
                              size: Dimensions.font16 + Dimensions.font16,
                              color: Colors.blueGrey[800],
                              weight: FontWeight.w600,
                              text: 'Login',
                            ),
                            SizedBox(height: Dimensions.screenHeight * 0.01),
                            Text(
                              'Access account',
                              textAlign: TextAlign.start,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: Dimensions.font20,
                                fontFamily: 'Hind',
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: Dimensions.screenHeight * 0.05),

                            Padding(
                              padding: EdgeInsets.only(
                                  left: Dimensions.screenWidth / 11),
                              child: Row(
                                children: [
                                  Text(
                                    'Enter your phone number to login',
                                    textAlign: TextAlign.start,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: Dimensions.font20,
                                      fontFamily: 'Hind',
                                      color: AppColors.titleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //email
                            AppTextField(
                              isObscure: false,
                              hintText: 'Phone number',
                              textController: phoneController,
                              inputType: TextInputType.phone,
                              textMaxLength: 10,
                              // maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            ),
                            const Divider(
                              indent: 36,
                              endIndent: 23,
                              color: Color(0xff8E806A),
                              thickness: 1.4,
                              height: 10,
                            ),
                            SizedBox(
                              height: Dimensions.height30,
                            ),
                            RichText(
                              text: TextSpan(
                                text:
                                    'We\'ll send OTP to this number for verification',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: Dimensions.font16 - 1),
                              ),
                            ),
                            SizedBox(
                              height: Dimensions.height30,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () async {
                              if (phoneController.text.length == 10 &&
                                  phoneController.text[0] == '0') {
                                setState(() {
                                  isLoading = true;
                                });
                                FocusScope.of(context).unfocus();
                                new TextEditingController().clear();
                                Future.delayed(const Duration(seconds: 2),
                                    () async {
                                  await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PhoneAuth(phoneController.text)));
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: EdgeInsets.only(
                                        bottom: Dimensions.screenHeight / 20,
                                        right: Dimensions.screenHeight / 50,
                                        left: Dimensions.screenHeight / 50),
                                    elevation: 8,
                                    backgroundColor: Color(0xff9A9483),
                                    behavior: SnackBarBehavior.floating,
                                    content: const Text(
                                        'Please enter a valid phone number'),
                                  ),
                                );
                              }
                            },
                            child: isLoading
                                ? Container(
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
                                        child: CircularProgressIndicator(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
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
                                        text: 'Continue',
                                        size: Dimensions.font20,
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: Dimensions.height30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
