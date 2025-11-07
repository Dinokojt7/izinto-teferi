import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/generic_snackbar.dart';
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
import '../../widgets/text_widgets/heading_style_text.dart';
import '../profile_view/controller/profile_view_controller.dart';
import '../profile_view/view_widgets/text_input_container.dart';

class EditAddress extends StatefulWidget {
  final int index;
  const EditAddress({Key? key, required this.index}) : super(key: key);

  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  @override
  void dispose() {
    // Close dropdown when leaving the page
    final dropdownController =
        Provider.of<MainAddressViewController>(context, listen: false);
    if (dropdownController.isDropdownOpen) {
      dropdownController.clearLabel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainAddressViewController>(
        builder: (context, _dropdownController, child) {
      final _isDropdownOpen = _dropdownController.isDropdownOpen;
      return Consumer<ProfileViewController>(
          builder: (context, _profileController, child) {
        ///Here's a list of addresses from the controller///
        final List<dynamic> _addresses = _profileController.savedAddresses;

        // FIX: Check if index is still valid after deletion
        if (widget.index >= _addresses.length) {
          // If index is invalid, navigate back and return empty container
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return Container();
        }

        final selectedAddress = _addresses[widget.index];

        ///Show fields for a specific address///
        final List<String> area = [
          selectedAddress['zip'],
          selectedAddress['suburb'],
        ];
        final String suburb = area.join(' ');
        final List<String?> items = [
          selectedAddress['street'],
          suburb,
          selectedAddress['Town'],
          selectedAddress['Country'],
        ];
        final String fullAddress = items.join(', ');

        ///Show additional address details///
        final String defaultText = _profileController.defaultAdditionalInfoText;
        final String additionalInfo =
            selectedAddress['additional info'] ?? defaultText;

        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_isDropdownOpen) {
                  _dropdownController.selectLabel();
                } else {
                  null;
                }
              },
              child: Scaffold(
                backgroundColor: Colors.white,
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
                            elevation: 1.5,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            heading: 'Edit address',
                          )
                        ],
                      ),
                      Expanded(
                        child: Container(
                          height: double.maxFinite,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 24.0, top: 25.0, right: 24.0),
                            child: Column(
                              children: [
                                GenericTextField(
                                  textField: TextFormField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    validator: (val) => val!.isEmpty ||
                                            val.toString() == 'First Name'
                                        ? "Required"
                                        : null,
                                    onChanged: (val) {
                                      // setState(() {
                                      //   // _firstName = val;
                                      // });
                                    },
                                    keyboardType: TextInputType.text,
                                    obscureText: false,
                                    cursorColor: Colors.black,
                                    decoration:
                                        buildInputDecoration(fullAddress, true),
                                    style: buildTextStyle(),
                                  ),
                                ),
                                SizedBox(
                                  height: Dimensions.height45 / 1.2,
                                ),
                                GenericTextField(
                                  textField: Expanded(
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      validator: (val) => val!.isEmpty ||
                                              val.toString() == 'First Name'
                                          ? "Required"
                                          : null,
                                      onChanged: (val) {
                                        // setState(() {
                                        //   // _firstName = val;
                                        // });
                                      },
                                      keyboardType: TextInputType.text,
                                      obscureText: false,
                                      cursorColor: Colors.black,
                                      decoration: buildInputDecoration(
                                          additionalInfo, false),
                                      style: buildTextStyle(),
                                    ),
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
                    ],
                  ),
                ),
                bottomNavigationBar: Container(
                  color: Colors.transparent,
                  height: Dimensions.bottomHeightBar * 1.3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SaveButton(
                          isActive: true,
                          description: 'Save address',
                          isAuthScreen: false,
                          onTap: () {
                            _saveEditedAddress(context, widget.index);
                          },
                        ),
                        SizedBox(
                          height: Dimensions.height20 * 1.2,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showDeleteConfirmation(context, widget.index);
                          },
                          child: HeadingStyleText(
                            text: 'Delete address',
                            size: Dimensions.font16,
                            family: 'Poppins',
                            weight: FontWeight.w600,
                            color: LiveColors.standardRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isDropdownOpen)
              AddressLabelOptions(
                isEditAddressChild: true,
              ),
          ],
        );
      });
    });
  }

  void _saveEditedAddress(BuildContext context, int index) {
    final profileController =
        Provider.of<ProfileViewController>(context, listen: false);
    final addressController =
        Provider.of<MainAddressViewController>(context, listen: false);

    // Get the current address data
    final List<dynamic> addresses = profileController.savedAddresses;
    final selectedAddress = addresses[index];

    // Create updated address with new values
    final updatedAddress = {
      'street': selectedAddress[
          'street'], // You might want to make these editable too
      'zip': selectedAddress['zip'],
      'suburb': selectedAddress['suburb'],
      'Town': selectedAddress['Town'],
      'Country': selectedAddress['Country'],
      'label': addressController.label.isNotEmpty
          ? addressController.label
          : selectedAddress['label'],
      'selected': selectedAddress['selected'],
      'additional info':
          addressController.additionalInfo != addressController.additionalInfo
              ? addressController.additionalInfo
              : selectedAddress['additional info'],
    };

    // Save the updated address
    profileController.updateAddress(index, updatedAddress).then((_) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Address updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.of(context).pop();
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update address'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

// Also update the delete method to use the controller:
  void _deleteAddress(BuildContext context, int index) {
    final profileController =
        Provider.of<ProfileViewController>(context, listen: false);

    profileController.deleteAddress(index).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Address deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Go back to addresses list
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete address'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

// Add this method to EditAddress class
  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: HeadingStyleText(
            text: 'Delete Address?',
            weight: FontWeight.w600,
          ),
          content: Text(
              'This address will be permanently removed from your saved addresses.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text('CANCEL', style: TextStyle(color: Colors.grey.shade600)),
            ),
            TextButton(
              onPressed: () {
                _deleteAddress(context, index);
                Navigator.of(context).pop();
              },
              child: Text('DELETE',
                  style: TextStyle(color: LiveColors.standardRed)),
            ),
          ],
        );
      },
    );
  }
}

TextStyle buildTextStyle() {
  return TextStyle(
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w500,
      color: Colors.black,
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
