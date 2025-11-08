import 'package:flutter/material.dart';
import 'package:izinto/live/auxiliery_classes/live_progress_indicator.dart';
import 'package:izinto/live/utilities/generic_snackbar.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:izinto/live/view/address_view/view_widgets/address_label.dart';
import 'package:izinto/live/view/address_view/view_widgets/address_label_options.dart';
import 'package:izinto/live/widgets/generic_text_field.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/generic_white_container.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../utilities/colors.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../profile_view/controller/profile_view_controller.dart';

class EditAddress extends StatefulWidget {
  final int index;
  final bool isLastAddress;

  const EditAddress({Key? key, required this.index, this.isLastAddress = false})
      : super(key: key);

  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  late TextEditingController _additionalInfoController;
  late TextEditingController _labelController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profileController =
        Provider.of<ProfileViewController>(context, listen: false);
    final addressController =
        Provider.of<MainAddressViewController>(context, listen: false);

    // Check if index is valid
    if (widget.index < profileController.savedAddresses.length) {
      final selectedAddress = profileController.savedAddresses[widget.index];

      // Initialize controllers with current values
      _additionalInfoController = TextEditingController(
          text: selectedAddress['additional info']?.toString() ?? '');
      _labelController = TextEditingController(
          text: selectedAddress['label']?.toString() ?? 'Home');

      // Set the current label in the dropdown controller
      addressController.setAddressLabel(
          selectedAddress['label']?.toString() ?? 'Home', false);

      // Set the current additional info in the address controller
      addressController.additionalDetailsController.text =
          selectedAddress['additional info']?.toString() ?? '';
    } else {
      // Default values if index is invalid
      _additionalInfoController = TextEditingController();
      _labelController = TextEditingController(text: 'Home');
    }
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    _labelController.dispose();

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
            /// Here's a list of addresses from the controller
            final List<dynamic> _addresses = _profileController.savedAddresses;

            // Check if index is still valid
            if (widget.index >= _addresses.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
              return _buildErrorState();
            }

            final selectedAddress = _addresses[widget.index];

            /// Show fields for a specific address
            final String fullAddress = _buildFullAddress(selectedAddress);

            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isDropdownOpen) {
                      _dropdownController.selectLabel();
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
                                    // Address Display (Read-only)
                                    _buildAddressDisplay(fullAddress),
                                    SizedBox(
                                      height: Dimensions.height45 / 1.2,
                                    ),
                                    // Additional Info Field (Editable) - Your original design
                                    GenericTextField(
                                      textField: Expanded(
                                        child: TextFormField(
                                          controller: _additionalInfoController,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          onChanged: (val) {
                                            // Update the address controller with the new additional info
                                            final addressController = Provider
                                                .of<MainAddressViewController>(
                                                    context,
                                                    listen: false);
                                            addressController
                                                .additionalDetailsController
                                                .text = val;
                                            addressController
                                                .captureAddressDetails();
                                          },
                                          keyboardType: TextInputType.text,
                                          obscureText: false,
                                          cursorColor: Colors.black,
                                          decoration:
                                              buildInputDecoration(false),
                                          style: buildTextStyle(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: Dimensions.height45 / 1.2,
                                    ),
                                    // Label Selection (Editable) - Your original design
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
                    bottomNavigationBar: _buildBottomNavigationBar(
                        context, widget.isLastAddress),
                  ),
                ),
                if (_isDropdownOpen)
                  AddressLabelOptions(
                    isEditAddressChild: true,
                  ),
                if (_isSaving)
                  LiveProgressIndicator(
                    color: Colors.black,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            HeadingStyleText(
              text: 'Address Not Found',
              size: Dimensions.font20,
              weight: FontWeight.w600,
            ),
            SizedBox(height: 8),
            Text(
              'The address you\'re trying to edit no longer exists.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDisplay(String fullAddress) {
    return GenericWhiteContainer(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadingStyleText(
              text: 'Address',
              size: Dimensions.font16,
              weight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            SizedBox(height: 8),
            HeadingStyleText(
              text: fullAddress,
              size: Dimensions.font16,
              weight: FontWeight.w500,
            ),
            SizedBox(height: 4),
            Text(
              'This address cannot be edited here',
              style: TextStyle(
                fontSize: Dimensions.font16 / 1.1,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isLastAddress) {
    return Container(
      color: Colors.transparent,
      height: Dimensions.bottomHeightBar * 1.3,
      child: Padding(
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SaveButton(
              isLoading: _isSaving,
              isActive: true,
              description: 'Save Changes',
              isAuthScreen: false,
              onTap: () async {
                await _saveEditedAddress(context, widget.index);
                Navigator.of(context).pop();
              },
            ),
            SizedBox(height: Dimensions.height20 * 1.2),
            GestureDetector(
              onTap: () {
                if (isLastAddress) {
                  GenericSnackBar().showCustomSnackBar(null, context,
                      'You cannot delete your only address', false);
                } else {
                  _showDeleteConfirmation(context, widget.index);
                }
              },
              child: HeadingStyleText(
                text: 'Delete address',
                size: Dimensions.font16,
                family: 'Poppins',
                weight: FontWeight.w600,
                color: isLastAddress
                    ? Colors.grey.shade400
                    : LiveColors.standardRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LiveColors.cartBlue),
        ),
      ),
    );
  }

  String _buildFullAddress(Map<String, dynamic> address) {
    final List<String?> items = [
      address['street']?.toString(),
      address['zip']?.toString(),
      address['suburb']?.toString(),
      address['Town']?.toString(),
      address['Country']?.toString(),
    ];

    // Remove null or empty values and join
    return items.where((item) => item != null && item!.isNotEmpty).join(', ');
  }

  Future<void> _saveEditedAddress(BuildContext context, int index) async {
    if (_isSaving) return;

    final profileController =
        Provider.of<ProfileViewController>(context, listen: false);
    final addressController =
        Provider.of<MainAddressViewController>(context, listen: false);

    setState(() {
      _isSaving = true;
    });

    try {
      final List<dynamic> addresses = profileController.savedAddresses;

      if (index >= addresses.length) {
        return;
      }

      final selectedAddress = addresses[index];

      // PROPERLY CAPTURE CURRENT VALUES FROM CONTROLLERS
      final String currentLabel = addressController.label.isNotEmpty
          ? addressController.label
          : selectedAddress['label']?.toString() ?? 'Home';

      final String currentAdditionalInfo =
          _additionalInfoController.text.isNotEmpty
              ? _additionalInfoController.text
              : selectedAddress['additional info']?.toString() ?? '';

      // Create updated address with new values
      final Map<String, dynamic> updatedAddress = {
        'street': selectedAddress['street']?.toString() ?? '',
        'zip': selectedAddress['zip']?.toString() ?? '',
        'suburb': selectedAddress['suburb']?.toString() ?? '',
        'Town': selectedAddress['Town']?.toString() ?? '',
        'Country': selectedAddress['Country']?.toString() ?? 'South Africa',
        'label': currentLabel, // Use the captured label
        'selected': selectedAddress['selected'] == true,
        'additional info':
            currentAdditionalInfo, // Use the captured additional info
        // Keep the document ID if it exists for Firebase operations
        if (selectedAddress['id'] != null)
          'id': selectedAddress['id']?.toString(),
      };

      // Save the updated address
      await profileController.updateAddress(index, updatedAddress);

      // Show success message
      GenericSnackBar().showCustomSnackBar(
          null, context, 'Address updated successfully', true);

      Navigator.of(context).pop();
    } catch (error) {
      print('Error updating address: $error');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteAddress(BuildContext context, int index) async {
    final profileController =
        Provider.of<ProfileViewController>(context, listen: false);

    try {
      await profileController.deleteAddress(index, context: context);

      Navigator.of(context).pop();
      Navigator.of(context).pop(); // Close edit screen
    } catch (error) {
      print('Error deleting address: $error');
    }
  }

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
            'This address will be permanently removed from your saved addresses.',
            style: TextStyle(fontSize: Dimensions.font16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteAddress(context, index);
              },
              child: Text(
                'DELETE',
                style: TextStyle(
                  color: LiveColors.standardRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
    fontFamily: 'Poppins',
  );
}

InputDecoration buildInputDecoration(bool isAddressField) {
  return InputDecoration(
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: EdgeInsets.only(
      bottom: isAddressField ? Dimensions.height10 : Dimensions.height20,
      left: 20,
    ),
    hintText: 'Additional info (building, floor...)',
    hintStyle: TextStyle(
      decoration: TextDecoration.none,
      fontSize: Dimensions.font20 / 1.38,
      fontFamily: 'Poppins',
      color: isAddressField ? Colors.black : Colors.black.withOpacity(0.8),
      fontWeight: isAddressField ? FontWeight.w500 : FontWeight.w300,
    ),
  );
}
