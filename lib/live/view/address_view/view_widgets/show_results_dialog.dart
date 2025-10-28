import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/address_view/edit_address.dart';
import 'package:izinto/live/view/address_view/save_address.dart';
import 'package:izinto/live/view/user_settings_view/opening_hours.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../utilities/generic_system_navigation.dart';
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
      return Padding(
        padding: EdgeInsets.fromLTRB(
            Dimensions.width20 * 1.2,
            Dimensions.height10,
            Dimensions.width20 * 1.2,
            Dimensions.height45 / 1.1),
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
              color: Colors.white),
          child: Padding(
            padding: EdgeInsets.fromLTRB(15.0, 16.0, 15.0, 16.0),
            child: Container(
              height: Dimensions.bottomHeightBar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadingStyleText(
                    text: ' $_searchStatusText',
                    weight: FontWeight.w600,
                    size: Dimensions.font20 / 1.35,
                  ),
                  SizedBox(
                    height: Dimensions.height10 / 2.5,
                  ),
                  HeadingStyleText(
                    text: ' $_street',
                    weight: FontWeight.w300,
                    size: Dimensions.font20 / 1.3,
                  ),
                  SizedBox(
                    height: Dimensions.height10 / 2.5,
                  ),
                  HeadingStyleText(
                    text: '$_zipCode $_town, $_country',
                    weight: FontWeight.w300,
                    size: Dimensions.font20 / 1.3,
                  ),
                  SizedBox(
                    height: Dimensions.height10 * 1.2,
                  ),
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
                        onTap: () async {
                          if (_isWithinRadius) {
                            await controller.setSaveButtonLoaderOff();
                          } else {
                            await controller.setIsLoading();
                            await Get.to(() => OpeningHours(),
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
}
