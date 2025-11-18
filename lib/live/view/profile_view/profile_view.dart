import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.white.withOpacity(0.95),
          Brightness.dark,
          Colors.white,
          Brightness.dark);
    });

    _loadUserDataImmediately();
  }

  Future<void> _loadUserDataImmediately() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          final controller =
              Provider.of<ProfileViewController>(context, listen: false);
          controller.updateNewUser(
              userData['name'] ?? '',
              userData['surname'] ?? '',
              userData['email'] ?? '',
              userData['phone'] ?? '',
              userData['telephoneSurveyConsent'] ?? false,
              userData['emailMarketingConsent'] ?? false,
              userData['wallet'] ?? 0);
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  void _applySystemChromeSettings() {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);
  }

  void _handleBackNavigation() {
    final controller =
        Provider.of<ProfileViewController>(context, listen: false);
    final hasMissingFields = controller.hasMissingFields;
    final isNewUser = controller.isNewUser;

    if (hasMissingFields || isNewUser) {
      controller.showExitConfirmationDialog(context);
    } else {
      _applySystemChromeSettings();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewController>(
        builder: (context, controller, child) {
      return PopScope(
        canPop: false, // We handle popping manually due to complex checks
        onPopInvoked: (didPop) {
          if (!didPop) {
            final focus = FocusScope.of(context);

            // Handle keyboard first
            if (!focus.hasPrimaryFocus && focus.focusedChild != null) {
              focus.unfocus();
              // Don't return here - let the back button press continue
              // The user will press back again to actually navigate
              return;
            }

            // If keyboard is already dismissed, handle navigation with system settings
            _handleBackNavigation();
          } else {
            // This runs after pop has completed (though with canPop: false, this won't trigger naturally)
            _applySystemChromeSettings();
          }
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
                          onTap: () {
                            if (controller.isNewUser) {
                              GenericSnackBar().showCustomSnackBar(
                                  null,
                                  context,
                                  'Please provide all the required fields.',
                                  false);
                            } else {
                              _handleBackNavigation(); // Uses the same method that applies system settings
                            }
                          },
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          heading: 'Edit profile',
                          hasMissingProfileData: controller.hasMissingFields,
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
                                              'First name',
                                              controller.firstName),
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
                                              'Last name', controller.lastName),
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
                                              'Phone number',
                                              controller.phoneNumber),
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
                                              'Email Address',
                                              controller.emailAddress),
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
                                        description:
                                            controller.emailMarketingText,
                                        fontWeight: FontWeight.w300,
                                        isEmailMarketing: true,
                                      ),
                                      SizedBox(
                                        height: Dimensions.height18,
                                      ),
                                      MarketingConsentForm(
                                        description:
                                            controller.telephoneSurveyText,
                                        fontWeight: FontWeight.w300,
                                        isEmailMarketing: false,
                                      ),
                                      SizedBox(
                                        height: Dimensions.height45 / 1.3,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          controller
                                              .confirmDeleteAccount(context);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: Dimensions.width30),
                                          child: DeleteWidget(
                                            description: 'Delete account',
                                            imagePath: 'assets/image/trash.png',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 24.0, right: 24.0),
                                  child: SaveButton(
                                    isLoading: controller.isLoading,
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
            if (controller.isLoading)
              LiveProgressIndicator(
                color: Colors.black,
                hasOwnDialog: true,
              ),
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
