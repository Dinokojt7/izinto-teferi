import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/generic_white_container.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/widgets/buttons/delete_widget.dart';
import 'package:izinto/live/view/profile_view/view_widgets/marketing_consent_form.dart';
import 'package:izinto/live/view/profile_view/view_widgets/text_input_container.dart';
import 'package:izinto/live/widgets/buttons/main_action_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../auxiliery_classes/live_progress_indicator.dart';
import '../../utilities/generic_snackbar.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/buttons/save_button.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late String _firstName;
  late String _lastName;
  late String _phoneNumber;
  late String _emailAddress;
  late bool _hasMissingFields;

  void _onTap() {
    if (_hasMissingFields) {
      GenericSnackBar().showCustomSnackBar(
          null, context, 'Please provide all the required fields.', false);
    } else {
      Future.delayed(const Duration(milliseconds: 200), () async {
        setState(() {
          SystemNavigation().applyCustomSystemChromeSettings(
              Colors.black, Brightness.light, Colors.black, Brightness.light);
        });
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    //Set the system navigation bar background to white
    return Consumer<ProfileViewController>(
        builder: (context, controller, child) {
      _firstName = controller.firstName;
      _lastName = controller.lastName;
      _phoneNumber = controller.phoneNumber;
      _emailAddress = controller.emailAddress;
      final emailMarketingText = controller.emailMarketingText;
      final telephoneSurveyText = controller.telephoneSurveyText;
      _hasMissingFields = controller.isUserinfoIncomplete;
      return WillPopScope(
        onWillPop: () async {
          if (_hasMissingFields) {
            GenericSnackBar().showCustomSnackBar(null, context,
                'Please provide all the required fields.', false);
            return false;
          }
          Future.delayed(const Duration(milliseconds: 200), () async {
            setState(() {
              SystemNavigation().applyCustomSystemChromeSettings(Colors.black,
                  Brightness.light, Colors.black, Brightness.light);
            });
          });
          return true;
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white.withOpacity(0.97),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                toolbarHeight: 0,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GenericAppBar(
                          onTap: _onTap,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          heading: 'Edit profile',
                          hasMissingProfileData: _hasMissingFields,
                        )
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 24.0, top: 25.0, right: 24.0),
                                  child: Column(
                                    children: [
                                      TextInputContainer(
                                        textField: TextFormField(
                                          controller:
                                              controller.firstNameController,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          validator: (val) => val!.isEmpty ||
                                                  val.toString() == 'First Name'
                                              ? "Required"
                                              : null,
                                          onChanged: (val) {
                                            controller.enableChanges();
                                          },
                                          keyboardType: TextInputType.text,
                                          obscureText: false,
                                          cursorColor: Colors.black,
                                          decoration: buildInputDecoration(
                                              'First name', _firstName),
                                          style: buildTextStyle(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dimensions.height45 / 1.2,
                                      ),
                                      TextInputContainer(
                                        textField: TextFormField(
                                          controller:
                                              controller.lastNameController,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          validator: (val) => val!.isEmpty ||
                                                  val.toString() == 'Last Name'
                                              ? "Required"
                                              : null,
                                          onChanged: (val) {
                                            controller.enableChanges();
                                          },
                                          keyboardType: TextInputType.text,
                                          obscureText: false,
                                          cursorColor: Colors.black,
                                          decoration: buildInputDecoration(
                                              'Last name', _lastName),
                                          style: buildTextStyle(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dimensions.height45 / 1.2,
                                      ),
                                      TextInputContainer(
                                        textField: TextFormField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller:
                                              controller.phoneNumberController,
                                          validator: (val) => val!.isEmpty ||
                                                  val.toString() ==
                                                      'Phone number'
                                              ? "Required"
                                              : null,
                                          onChanged: (val) {
                                            controller.enableChanges();
                                          },
                                          keyboardType: TextInputType.phone,
                                          obscureText: false,
                                          cursorColor: Colors.black,
                                          decoration: buildInputDecoration(
                                              'Phone number', _phoneNumber),
                                          style: buildTextStyle(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dimensions.height45 / 1.2,
                                      ),
                                      TextInputContainer(
                                        textField: TextFormField(
                                          controller:
                                              controller.emailController,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          validator: (val) => val!.isEmpty ||
                                                  val.toString() ==
                                                      'Email address'
                                              ? "Required"
                                              : null,
                                          onChanged: (val) {
                                            controller.enableChanges();
                                          },
                                          keyboardType: TextInputType.text,
                                          obscureText: false,
                                          cursorColor: Colors.black,
                                          decoration: buildInputDecoration(
                                              'Email Address', _emailAddress),
                                          style: buildTextStyle(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dimensions.height45 / 1.3,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 10.0, right: 24.0),
                                  child: Column(
                                    children: [
                                      MarketingConsentForm(
                                        description: emailMarketingText,
                                        isSelected: false,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      SizedBox(
                                        height: Dimensions.height18,
                                      ),
                                      MarketingConsentForm(
                                        description: telephoneSurveyText,
                                        isSelected: false,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      SizedBox(
                                        height: Dimensions.height45 / 1.3,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: Dimensions.width30),
                                        child: DeleteWidget(
                                          description: 'Delete account',
                                          imagePath: 'assets/image/trash.png',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 24.0, right: 24.0),
                                  child: SaveButton(
                                    isActive: controller.isValid,
                                    description: 'Save changes',
                                    isAuthScreen: false,
                                    onTap: () {
                                      controller.updateUserData(context);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: Dimensions.height10,
                                ),
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isLoading) LiveProgressIndicator(),
          ],
        ),
      );
    });
  }

  TextStyle buildTextStyle() {
    return TextStyle(
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        fontFamily: 'Poppins');
  }

  InputDecoration buildInputDecoration(String labelText, String hintText) {
    return InputDecoration(
      border: InputBorder.none, // Removes the underline in its default state
      enabledBorder: InputBorder.none, // Removes the underline when not focused
      focusedBorder: InputBorder.none,
      labelText: labelText,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        color: Colors.black,
        fontSize: Dimensions.font20 / 1.38,
        fontWeight: FontWeight.w300,
      ),
      contentPadding: EdgeInsets.only(bottom: 12, left: 20),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hintText,
      hintStyle: TextStyle(
        letterSpacing: -0.5,
        decoration: TextDecoration.none,
        fontSize: Dimensions.font16 / 1.08,
        fontFamily: 'Poppins',
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
