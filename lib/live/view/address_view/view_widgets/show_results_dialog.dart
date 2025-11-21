import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/home_view/home_view.dart';
import 'package:izinto/live/view/home_view/view_widgets/operating_areas.dart';
import 'package:provider/provider.dart';

import '../../../../models/user.dart';
import '../../../../utils/dimensions.dart';
import '../../../widgets/buttons/blue_text_button.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../controller/address_dropdown_controller.dart';

class ShowResultsDialog extends StatelessWidget {
  const ShowResultsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MainAddressViewController>(
        builder: (context, controller, child) {
      final _street = controller.street;
      final _suburb = controller.suburb;
      final _zipCode = controller.zipCode;
      final _town = controller.town;
      final _country = controller.country;
      final _searchStatusText = controller.searchStatusText;
      final _isWithinRadius = controller.isValidAddress;
      var _isLoading = controller.isAddressDialogLoading;

      final user = Provider.of<UserModel?>(context);
      final _hasUser = user != null;

      return Padding(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20 * 1.2,
          Dimensions.height10,
          Dimensions.width20 * 1.2,
          Dimensions.height45 / 1.1,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          elevation: 4,
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              minHeight: Dimensions.bottomHeightBar, // Minimum height
              maxHeight: MediaQuery.of(context).size.height *
                  0.4, // Maximum height to prevent overflow
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.0, 16.0, 15.0, 16.0),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // This makes the column shrink-wrap its content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Status
                  HeadingStyleText(
                    text: ' $_searchStatusText',
                    weight: FontWeight.w600,
                    size: Dimensions.font20 / 1.35,
                  ),
                  SizedBox(height: Dimensions.height10 / 2.5),

                  // Street Address - Flexible to handle long text
                  Flexible(
                    child: HeadingStyleText(
                      text: ' $_street',
                      weight: FontWeight.w300,
                      size: Dimensions.font20 / 1.3,
                      maxLines: 2, // Limit to 2 lines max
                      overFlow:
                          TextOverflow.ellipsis, // Show ellipsis if too long
                    ),
                  ),
                  SizedBox(height: Dimensions.height10 / 2.5),

                  // Location Details - Flexible to handle long text
                  Flexible(
                    child: HeadingStyleText(
                      text: '$_town, $_country - $_zipCode',
                      weight: FontWeight.w300,
                      size: Dimensions.font20 / 1.3,
                      maxLines: 2, // Limit to 2 lines max
                      overFlow:
                          TextOverflow.ellipsis, // Show ellipsis if too long
                    ),
                  ),
                  SizedBox(height: Dimensions.height10 * 1.2),

                  // Button Row - Always at the bottom
                  Row(
                    mainAxisAlignment: _isWithinRadius
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      BlueTextButton(
                        isLoading: _isLoading,
                        horizontalPadding: 12.0,
                        textSize: Dimensions.font20 / 1.4,
                        text:
                            _isWithinRadius ? 'Next' : 'Browse available areas',
                        // In ShowResultsDialog, update the onTap handler:
                        onTap: () async {
                          if (_isWithinRadius && _hasUser) {
                            await controller.setSaveButtonLoaderOff(context);
                          } else if (_isWithinRadius) {
                            await controller.setIsLoading();

                            // Save address to persistent storage for guest users
                            await _saveAddress(context, controller);

                            await controller.disposeSearchAddressLoader();
                            await Get.to(() => HomeView());
                          } else {
                            await controller.setIsLoading();
                            await Get.to(() => ServiceAreas(),
                                transition: Transition.fade,
                                duration: Duration(seconds: 1));
                            controller.setIsLoading();
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _saveAddress(
      BuildContext context, MainAddressViewController addressController) async {
    try {
      // This should update local state immediately and then sync with Firebase
      await addressController.saveGuestAddress(context);
      // No need to call saveNewAddress separately - it's handled in saveSelectedAddress
    } catch (e) {

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
