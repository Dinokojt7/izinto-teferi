import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../services/firebase_auth_methods.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/big_text.dart';
import 'login.dart';

class ForgotPassword extends StatefulWidget {
  static String id = 'forgot-password';

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final FirebaseAuthMethods _auth = FirebaseAuthMethods();
  bool isLoading = false;
  String email = '';
  String error = '';
  final _formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: Dimensions.screenHeight / 20),
              child: Center(
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(
                            bottom: Dimensions.screenHeight / 30),
                        child: Image(
                          image: AssetImage('assets/image/artwork.png'),
                          height: Dimensions.height20 * 3,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.screenHeight / 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            indent: Dimensions.width15 * 2,
                            endIndent: 10,
                            color: Colors.black26,
                            height: 20,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'FORGOT PASSWORD',
                            style: TextStyle(
                                color: Colors.black38,
                                fontSize: Dimensions.font26 / 1.8),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            indent: 10,
                            endIndent: Dimensions.width15 * 2,
                            color: Colors.black26,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.screenHeight / 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Enter your email address, and we\'ll send you a link to reset your password.',
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.black54.withOpacity(0.5),
                          fontSize: Dimensions.font16,
                          fontFamily: 'Hind',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.006,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: Dimensions.screenHeight * 0.03),
                          Padding(
                            padding: EdgeInsets.only(
                                left: Dimensions.screenWidth / 28,
                                bottom: Dimensions.screenWidth / 80),
                            child: Row(
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                      fontSize: Dimensions.font16,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: Dimensions.screenHeight / 14,
                            width: Dimensions.width30 * 15,
                            margin: EdgeInsets.only(
                                left: Dimensions.height15,
                                right: Dimensions.height15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Dimensions.radius15)),
                            ),
                            child: TextFormField(
                              validator: (val) =>
                                  val!.isEmpty ? "Enter email address" : null,
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
                              },
                              keyboardType: TextInputType.text,
                              obscureText: false,
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                    fontSize: Dimensions.font20,
                                    color: Colors.black26),

                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radius15),
                                    borderSide: const BorderSide(
                                      width: 1.0,
                                      color: Color(0xff9A9483),
                                    )),
                                //enabled border
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Dimensions.radius15)),
                                  borderSide: const BorderSide(
                                    width: 1.0,
                                    color: Color(0xff9A9483),
                                  ),
                                ),
                                //border
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radius15),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Dimensions.screenHeight * 0.01),
                          Text(
                            error,
                            style: TextStyle(
                                color: Colors.red, fontSize: Dimensions.font16),
                          ),
                          SizedBox(height: Dimensions.screenHeight * 0.01),

                          SizedBox(height: Dimensions.screenHeight * 0.035),

                          //password
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            height: Dimensions.bottomHeightBar / 1.3,
            decoration: BoxDecoration(
              border: Border.all(width: 0.1),
              //color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radius20 * 2),
                topRight: Radius.circular(Dimensions.radius20 * 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: Dimensions.bottomHeightBar,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BigText(
                              size: Dimensions.font20,
                              color: Color(0xff9A9483),
                              weight: FontWeight.w600,
                              text: 'Cancel',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                VerticalDivider(color: Color(0xff9A9483).withOpacity(0.7)),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (emailController.text !=
                          emailController.text.isEmail) {
                        setState(() {
                          isLoading = true;
                          error = 'Not a valid email address';
                        });

                        setState(() {
                          isLoading = false;
                        });
                      }
                      dynamic result = await _auth.passwordReset(
                          emailController.text, context);

                      if (result == null) {
                        setState(() {
                          error = 'Email or password you entered is invalid.';
                          isLoading = false;
                        });
                      }

                      if (result != null) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius20),
                      ),
                      height: Dimensions.bottomHeightBar,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BigText(
                              text: 'Reset password',
                              size: Dimensions.font20,
                              weight: FontWeight.w600,
                              color: Color(0xff9A9483),
                            ),
                            SizedBox(
                              width: Dimensions.width10,
                            ),
                            Icon(
                              Icons.arrow_right_alt_rounded,
                              color: Color(0xff9A9483),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                child: Center(
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Center(
                            child: SpinKitChasingDots(
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
