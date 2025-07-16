import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/pages/home/home_page.dart';
import 'package:izinto/pages/on_boarding/location_access.dart';
import 'package:izinto/pages/options/profile_settings.dart';
import 'package:izinto/services/firebase_auth_methods.dart';
import '../../base/custom_loader.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firebase_storage_service.dart';
import '../../services/location_manager.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/big_text.dart';
import '../../widgets/main_buttons/email_sign_in_button.dart';

class EmailSignIn extends StatefulWidget {
  const EmailSignIn({Key? key}) : super(key: key);

  @override
  State<EmailSignIn> createState() => _EmailSignInState();
}

@override
class _EmailSignInState extends State<EmailSignIn> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;
  bool _passwordVisible = true;
  final FirebaseAuthMethods _auth = FirebaseAuthMethods();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  String password = '';
  String name = '';
  String surname = '';
  String phone = '';

  int? orderHistory;
  String? subStatus;
  String error = '';
  String errorPassword = '';
  bool borderError = false;
  bool passwordBorder = false;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.text = '';
    emailController.addListener(() {
      setState(() {}); // setState every time text changes
    });
    passwordController.text = '';
    passwordController.addListener(() {
      setState(() {}); // setState every time text changes
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0.3,
            title: Text(
              'Register',
              style: TextStyle(
                  color: Color(0Xff353839), fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Color(0Xff353839), size: 30),
            backgroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: Dimensions.screenHeight * 0.02),
                child: GetBuilder<AuthController>(
                  builder: (_authController) {
                    return !_authController.isLoading
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Center(
                              child: Stack(
                                children: [
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                            height:
                                                Dimensions.screenHeight * 0.03),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Container(
                                            height:
                                                Dimensions.screenHeight / 14,
                                            width: Dimensions.width30 * 15,
                                            margin: EdgeInsets.only(
                                                left: Dimensions.height15,
                                                right: Dimensions.height15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      Dimensions.radius15)),
                                            ),
                                            child: TextFormField(
                                              validator: (val) => val!.isEmpty
                                                  ? "Enter your email"
                                                  : null,
                                              onChanged: (val) {
                                                setState(() {
                                                  email = val;
                                                  if (val == '') {
                                                    setState(() {
                                                      borderError = false;
                                                      error = '';
                                                    });
                                                  }
                                                });
                                              },
                                              keyboardType: TextInputType.text,
                                              cursorColor: Color(0xffB09B71),
                                              obscureText: false,
                                              controller: emailController,
                                              decoration: InputDecoration(
                                                labelText: 'Email',
                                                suffixIcon: IconButton(
                                                  color: emailController
                                                          .text.isNotEmpty
                                                      ? Color(0xff9A9483)
                                                      : Colors.transparent,
                                                  iconSize:
                                                      Dimensions.iconSize16,
                                                  onPressed:
                                                      emailController.clear,
                                                  icon: Icon(Icons.clear),
                                                ),
                                                floatingLabelStyle: TextStyle(
                                                  color: borderError
                                                      ? Colors.red
                                                      : Color(0xffB09B71),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                    bottom: 2, left: 20),

                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior.auto,

                                                focusColor: Colors.white,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                  borderSide: BorderSide(
                                                    width: 1.5,
                                                    color: borderError
                                                        ? Colors.red
                                                        : Color(0xffB09B71),
                                                  ),
                                                ), //enabled border
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                          Dimensions.radius15)),
                                                  borderSide: BorderSide(
                                                    width: 1.0,
                                                    color: borderError
                                                        // passwordController
                                                        //             .text.length <
                                                        //         6
                                                        ? Colors.red
                                                        : Color(0xff9A9483),
                                                  ),
                                                ),
                                                //border
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        Text(
                                          error,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize:
                                                  Dimensions.font16 / 1.1),
                                        ),
                                        SizedBox(
                                            height:
                                                Dimensions.screenHeight * 0.01),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Container(
                                            height:
                                                Dimensions.screenHeight / 14,
                                            width: Dimensions.width30 * 15,
                                            margin: EdgeInsets.only(
                                                left: Dimensions.height15,
                                                right: Dimensions.height15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      Dimensions.radius15)),
                                            ),
                                            child: TextFormField(
                                              onChanged: (val) {
                                                setState(() {
                                                  password = val;
                                                  if (val == '') {
                                                    setState(() {
                                                      passwordBorder = false;
                                                      errorPassword = '';
                                                    });
                                                  }
                                                });
                                              },
                                              cursorColor: Color(0xffB09B71),
                                              keyboardType: TextInputType.text,
                                              obscureText: _passwordVisible,
                                              controller: passwordController,
                                              decoration: InputDecoration(
                                                labelText: 'Password',
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    // Based on passwordVisible state choose the icon
                                                    _passwordVisible
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                    color: Color(0xff9A9483),
                                                  ),
                                                  onPressed: () {
                                                    // Update the state i.e. toogle the state of passwordVisible variable
                                                    setState(() {
                                                      _passwordVisible =
                                                          !_passwordVisible;
                                                    });
                                                  },
                                                ),

                                                floatingLabelStyle: TextStyle(
                                                  color: passwordBorder
                                                      ? Colors.red
                                                      : Color(0xffB09B71),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                    bottom: 2, left: 20),

                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior.auto,

                                                focusColor: Colors.white,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                  borderSide: BorderSide(
                                                    width: 1.5,
                                                    color: passwordBorder
                                                        ? Colors.red
                                                        : Color(0xffB09B71),
                                                  ),
                                                ), //enabled border
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                          Dimensions.radius15)),
                                                  borderSide: BorderSide(
                                                    width: 1.0,
                                                    color: passwordBorder
                                                        ? Colors.red
                                                        : Color(0xff9A9483),
                                                  ),
                                                ),
                                                //border
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          errorPassword,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize:
                                                  Dimensions.font16 / 1.1),
                                        ),
                                        SizedBox(
                                            height: Dimensions.screenHeight *
                                                0.035),

                                        SizedBox(
                                            height: Dimensions.screenHeight *
                                                0.035),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const CustomLoader();
                  },
                ),
              ),
              GestureDetector(   onTap: () async {
                FocusScope.of(context).unfocus();
                User? user = await _firebaseAuth.currentUser;
                new TextEditingController().clear();

                if (passwordController.text.length > 6 &&
                    emailController.text.isEmail) {
                  setState(() {
                    isLoading = true;
                    borderError = false;
                  });
                  setState(() {
                    errorPassword = '';
                    error = '';
                  });
                  dynamic result = await _auth.signUpWithEmail(
                      email: email, password: password, context: context);

                  if (result == null) {
                    setState(() {
                      errorPassword =
                      'Email or password you entered is invalid.';
                      isLoading = false;
                    });
                  }

                  if (result != null) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                LocationAccess()));
                  }
                }

                if (passwordController.text.isEmpty) {
                  setState(() {
                    errorPassword = '';
                    passwordBorder = false;
                    error = '';
                    borderError = false;
                  });
                  ;
                }
                if (!emailController.text.isEmail) {
                  setState(() {
                    error = 'Email is invalid';
                    borderError = true;
                    errorPassword = '';
                    passwordBorder = false;
                  });
                } else {
                  setState(() {
                    error = '';
                    borderError = false;
                  });
                }
              },
                child: EmailSignInButton(passwordController: passwordController, emailController: emailController, isLoading: isLoading),
              )
            ],
          ),

          //password,
        ),
      ],
    );
  }
}


