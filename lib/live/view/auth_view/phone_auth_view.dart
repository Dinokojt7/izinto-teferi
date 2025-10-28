import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/auxiliery_classes/live_progress_indicator.dart';
import 'package:izinto/live/auxiliery_classes/mini_circular_progress_indicator.dart';
import 'package:izinto/live/view/auth_view/view_widgets/view_as_guest.dart';
import 'package:izinto/live/view/home_view/guest_access.dart';
import 'package:izinto/live/widgets/text_widgets/description_text.dart';
import 'package:izinto/live/view/auth_view/view_widgets/country_code_selector.dart';
import 'package:izinto/live/view/auth_view/view_widgets/terms_dialog.dart';
import 'package:izinto/live/widgets/text_widgets/introduction_text.dart';
import 'package:izinto/live/view/auth_view/view_widgets/google_auth_button.dart';
import 'package:izinto/live/view/auth_view/view_widgets/section_divider.dart';
import 'package:izinto/live/view/auth_view/view_widgets/top_logo.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:provider/provider.dart';

import '../../../services/firebase_auth_methods.dart';
import '../../../utils/dimensions.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/generic_text_field.dart';
import '../address_view/controller/address_dropdown_controller.dart';
import '../home_view/controller/home_view_controller.dart';
import '../home_view/home_view.dart';
import 'controller/phone_auth_view_controller.dart';

class PhoneAuthView extends StatefulWidget {
  const PhoneAuthView({Key? key}) : super(key: key);

  @override
  State<PhoneAuthView> createState() => _PhoneAuthViewState();
}

class _PhoneAuthViewState extends State<PhoneAuthView> {
  @override
  void initState() {
    setState(() {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.white, Brightness.dark, Colors.white, Brightness.dark);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext widgetContext) {
    final addressController =
        Provider.of<MainAddressViewController>(context, listen: false);
    late bool _isInitialized;
    late bool _showTermsDialog;
    return Consumer<PhoneAuthViewController>(
        builder: (context, controller, child) {
      _isInitialized = controller.isInitialized;
      _showTermsDialog = controller.showTermsDialog;

      return Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: _isInitialized
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.2),
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
            ),
            body: Padding(
              padding: EdgeInsets.only(
                  left: 26.0, top: Dimensions.height15, right: 26.0),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopLogo(),
                    SizedBox(height: Dimensions.height45 * 1.6),
                    IntroductionText(
                        text: 'Hi! Let\'s start with your phone number'),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    DescriptionText(
                        text:
                            'Enter your number to log in, or to sign up for an account if your\'re new here.'),
                    SizedBox(
                      height: Dimensions.height20 * 1.5,
                    ),
                    Row(
                      children: [
                        CountryCodeSelector(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: Dimensions.width20),
                            child: GenericTextField(
                              textField: TextFormField(
                                maxLength: 13,
                                controller: controller.phoneNumberController,
                                keyboardType: TextInputType
                                    .number, // Set input type to numbers
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only digits
                                ],
                                validator: (val) => val!.isEmpty ||
                                        val.toString() == 'Phone number'
                                    ? "Required"
                                    : null,
                                onChanged: (val) {
                                  controller
                                      .validatePhoneNumber(); // Validate the input
                                },
                                obscureText: false,
                                cursorColor: Colors.black,
                                decoration: buildInputDecoration(),
                                style: buildTextStyle(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height30 * 1.2,
                    ),
                    SaveButton(
                      isActive: controller.isValid && controller.isActive,
                      isLoading: controller.isValid ? _isInitialized : false,
                      description: 'Continue',
                      isAuthScreen: true,
                      onTap: () async {
                        if (controller.isValid) {
                          FocusScope.of(context).unfocus();
                          await controller.resetAuthContext();
                          controller.displayTermsDialog();
                        }
                      },
                    ),
                    SizedBox(
                      height: Dimensions.height20 / 1.4,
                    ),
                    SectionDivider(),
                    SizedBox(
                      height: Dimensions.height30 / 2,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: Dimensions.height10,
                      ),
                      child: GoogleAuthButton(
                        onTap: () async {
                          await controller.setAuthContextToGoogle();
                          controller.displayTermsDialog();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            bottomNavigationBar: ViewAsGuestText(
              onTap: () {
                addressController.restartLoader();
                Get.to(() => GuestAccess(),
                    transition: Transition.fade,
                    duration: Duration(seconds: 1));
              },
            ),
          ),
          if (_isInitialized && !controller.isValid)
            MiniCircularProgressIndicator(
              color: Colors.black87,
              hasOwnDialog: false,
            ),
          if (_showTermsDialog)
            TermsDialog(
              widgetContext: widgetContext,
            ),
        ],
      );
    });
  }
}

class DividerSection {}

// Reusable input decoration for text fields
InputDecoration buildInputDecoration() {
  return InputDecoration(
    counterText: "",
    border: InputBorder.none, // Removes the underline in its default state
    enabledBorder: InputBorder.none, // Removes the underline when not focused
    focusedBorder: InputBorder.none,
    contentPadding: EdgeInsets.only(
        bottom: Dimensions.height20 / 1.1, left: Dimensions.width10),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintText: 'Phone number',
    hintStyle: TextStyle(
      decoration: TextDecoration.none,
      fontSize: Dimensions.font16 / 1.1,
      fontFamily: 'Poppins',
      color: Colors.black,
      fontWeight: FontWeight.w300,
    ),
  );
}

TextStyle buildTextStyle() {
  return TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: Dimensions.font16,
    color: Colors.black,
  );
}
