import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/utilities/generic_system_navigation.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:izinto/live/view/address_view/view_widgets/address_label.dart';
import 'package:izinto/live/view/address_view/view_widgets/address_label_options.dart';
import 'package:izinto/live/widgets/generic_text_field.dart';
import 'package:izinto/live/view/address_view/view_widgets/list_tile_label.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/generic_white_container.dart';
import 'package:izinto/live/widgets/buttons/delete_widget.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../utilities/colors.dart';
import '../../widgets/icons/back_arrow.dart';
import '../../widgets/lock_screen.dart';
import '../../widgets/text_widgets/description_text.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../../widgets/text_widgets/introduction_text.dart';
import '../../wrapper.dart';
import '../home_view/home_view.dart';
import '../profile_view/controller/profile_view_controller.dart';
import '../profile_view/view_widgets/text_input_container.dart';

class SaveAddress extends StatefulWidget {
  final String addressLabel;
  const SaveAddress({Key? key, required this.addressLabel}) : super(key: key);

  @override
  State<SaveAddress> createState() => _SaveAddressState();
}

class _SaveAddressState extends State<SaveAddress> {
  Color _statusBarColor = Colors.white.withOpacity(0.05);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewController>(
        builder: (context, _profileController, child) {
      return Consumer<MainAddressViewController>(
          builder: (context, _addressController, child) {
        final String fullAddress = widget.addressLabel;
        final _isDropdownOpen = _addressController.isDropdownOpen;
        //final _newAddress = _addressController.newAddress;

        ///Button loader
        var _isLoading = _addressController.isSaveAddressButtonLoading;

        ///Show additional address details///
        final String defaultText = _profileController.defaultAdditionalInfoText;
        final String additionalInfo = defaultText;

        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_isDropdownOpen) {
                  _addressController.selectLabel();
                } else {
                  null;
                }
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: _statusBarColor,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 0,
                ),
                body: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      buildHeader(context, true),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Container(
                            height: double.maxFinite,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 24.0, top: 35.0, right: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntroductionText(
                                      text: 'We can deliver to you \u{1F680}'),
                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),
                                  DescriptionText(
                                      text:
                                          'Save and label this address for future orders - you can add more addresses later, too!'),
                                  SizedBox(
                                    height: Dimensions.height20 * 1.8,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Stack(
                                      children: [
                                        GenericTextField(
                                          textField: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            keyboardType: TextInputType.text,
                                            obscureText: false,
                                            cursorColor: Colors.black,
                                            decoration: buildInputDecoration(
                                                fullAddress, true),
                                            style: buildTextStyle(),
                                          ),
                                        ),
                                        GenericWhiteContainer(
                                          leftPadding: 0.0,
                                          rightPadding: 0.0,
                                          bottomPadding: 0.0,
                                          color: Colors.transparent,
                                          child: Container(
                                            height: Dimensions.height45 * 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height45 / 1.1,
                                  ),
                                  GenericTextField(
                                    textField: TextFormField(
                                      controller: _addressController
                                          .additionalDetailsController,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      onChanged: (val) {
                                        _addressController
                                            .captureAddressDetails();
                                      },
                                      keyboardType: TextInputType.text,
                                      obscureText: false,
                                      cursorColor: Colors.black,
                                      decoration: buildInputDecoration(
                                          additionalInfo, false),
                                      style: buildTextStyle(),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height45 / 1.2,
                                  ),
                                  GenericWhiteContainer(
                                    isSelected: _isDropdownOpen,
                                    topPadding: Dimensions.height10,
                                    bottomPadding: Dimensions.height20 / 2,
                                    leftPadding: Dimensions.width10 / 1.5,
                                    color: Colors.black12.withOpacity(0.04),
                                    child: AddressLabel(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Container(
                  color: Colors.transparent,
                  height: Dimensions.bottomHeightBar / 1.2,
                  child: Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SaveButton(
                          isLoading:
                              _addressController.isSaveAddressButtonLoading,
                          isActive: true,
                          description: 'Save address',
                          isAuthScreen: false,
                          onTap: () async {
                            await _addressController.saveSelectedAddress();
                            await _profileController
                                .saveNewAddress(_addressController.newAddress);
                            Future.delayed(const Duration(seconds: 2),
                                () async {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Wrapper()),
                                  (route) => false);
                              setState(() {
                                _statusBarColor =
                                    Colors.black.withOpacity(0.002);
                                Future.delayed(const Duration(seconds: 1),
                                    () async {
                                  setState(() {
                                    SystemNavigation()
                                        .applyCustomSystemChromeSettings(
                                            Colors.black,
                                            Brightness.light,
                                            Colors.black,
                                            Brightness.light);
                                  });
                                });
                              });
                            });
                          },
                        ),
                        SizedBox(
                          height: Dimensions.height20 * 1.2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isDropdownOpen)
              AddressLabelOptions(
                isEditAddressChild: false,
              ),
            if (_isLoading) LockScreen()
          ],
        );
      });
    });
  }

  Padding buildHeader(BuildContext context, bool isFromWhiteThemeParent) {
    final _addressController =
        Provider.of<MainAddressViewController>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width20,
          top: Dimensions.height20,
          right: Dimensions.width20,
          bottom: 0.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: BackArrow(
                  iconColor: Colors.black45,
                  onTap: () {
                    _addressController.clearLabel();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logos/retro-logo.png', // Image path from item list
                width: 30.0,
                height: 30.0, alignment: Alignment.topCenter,
              )
            ],
          )
        ],
      ),
    );
  }
}

TextStyle buildTextStyle() {
  return TextStyle(
      fontSize: Dimensions.font20 / 1.2,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w500,
      color: Colors.black,
      decorationThickness: 0.0,
      fontFamily: 'Poppins');
}

InputDecoration buildInputDecoration(
    String addressShowing, bool isAddressField) {
  return InputDecoration(
    border: InputBorder.none, // Removes the underline in its default state
    enabledBorder: InputBorder.none, // Removes the underline when not focused
    focusedBorder: InputBorder.none,
    labelText: isAddressField ? 'Address' : null,
    labelStyle: TextStyle(
      fontFamily: 'Poppins',
      color: Colors.black,
      fontSize: Dimensions.font20 / 1.42,
      fontWeight: FontWeight.w300,
    ),
    contentPadding: EdgeInsets.only(
        bottom: isAddressField ? Dimensions.height10 : Dimensions.height20,
        left: 20),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintText: addressShowing,
    hintStyle: TextStyle(
      decoration: TextDecoration.none,
      fontSize: Dimensions.font20 / 1.38,
      fontFamily: 'Poppins',
      color: isAddressField ? Colors.black : Colors.black.withOpacity(0.8),
      fontWeight: isAddressField ? FontWeight.w500 : FontWeight.w300,
    ),
  );
}
