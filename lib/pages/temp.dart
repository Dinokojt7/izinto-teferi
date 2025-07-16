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
import '../widgets/texts/big_text.dart';
import '../widgets/texts/small_text.dart';

class Temp extends StatefulWidget {
  const Temp({Key? key}) : super(key: key);

  @override
  State<Temp> createState() => _TempState();
}

@override
class _TempState extends State<Temp> {
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
            backgroundColor: Color(0xff2a303b),
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: null,
                  icon: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Icon(Icons.clear, color: Color(0xff414d5b)),
                  ),
                )
              ],
              automaticallyImplyLeading: false,
              elevation: 0,
              iconTheme:
                  const IconThemeData(color: Color(0xff414d5b), size: 25),
              backgroundColor: Color(0xff2a303b),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: Dimensions.height30 * 6.5),
                  child: Column(
                    children: [
                      Icon(
                        Icons.do_not_disturb,
                        color: Color(0xffb22222),
                        size: 70,
                      ),
                      SizedBox(
                        height: Dimensions.height30,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: Center(
                          child: Text(
                            'Your account has been blocked due to irregular/suspicious activities. Your account '
                            'is blocked until 2024-06-30 00:01',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                height: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: Dimensions.bottomHeightBar / 1.2,
                    padding: EdgeInsets.only(
                        top: Dimensions.height18,
                        bottom: Dimensions.height15,
                        left: Dimensions.width20,
                        right: Dimensions.width20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radius20 * 2),
                        topRight: Radius.circular(Dimensions.radius20 * 2),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () async {
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
                              email: email,
                              password: password,
                              context: context);

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
                      child: Container(
                        height: Dimensions.screenHeight / 14,
                        width: Dimensions.width30 * 15,
                        decoration: BoxDecoration(
                          color: Color(0xff414d5b),

                          borderRadius: BorderRadius.all(
                            Radius.circular(Dimensions.radius20 * 3),
                          ),
                          // color: const Color(0xff8d7053),
                        ),
                        child: isLoading
                            ? Transform.scale(
                                scale: 0.5,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 6,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Center(
                                child: BigText(
                                  text: 'Close',
                                  size: Dimensions.font26 / 1.15,
                                  weight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
