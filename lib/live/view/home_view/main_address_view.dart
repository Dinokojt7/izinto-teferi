import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/live/auxiliery_classes/main_address.dart';
import 'package:izinto/live/auxiliery_classes/show_eta.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:izinto/live/view/address_view/saved_addresses.dart';
import 'package:izinto/live/view/profile_view/profile_view.dart';
import 'package:izinto/pages/options/location_settings.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/recommended_specialty_controller.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/skeletons.dart';
import '../../utilities/generic_system_navigation.dart';
import '../address_view/add_new_address.dart';
import '../profile_view/controller/profile_view_controller.dart';

class MainAddressView extends StatefulWidget {
  const MainAddressView({Key? key}) : super(key: key);

  @override
  State<MainAddressView> createState() => _MainAddressViewState();
}

class _MainAddressViewState extends State<MainAddressView> {
  @override
  Widget build(BuildContext context) {
    final addressViewController =
        Provider.of<MainAddressViewController>(context, listen: false);

    ///Here's a list of addresses from the controller
    final _profileController =
        Provider.of<ProfileViewController>(context, listen: false);
    final List<dynamic> _addresses = _profileController.savedAddresses;

    ///Here's the selection of currently active address///
    var selectedAddresses =
        _addresses.where((address) => address['selected'] == true).toList();

    var street = '';
    // Iterate over the filtered addresses and use their values
    for (var address in selectedAddresses) {
      street = address['street'];
    }
    return GetBuilder<RecommendedSpecialtyController>(
        builder: (recommendedSpecialties) {
      return GestureDetector(
        onTap: () async {
          await addressViewController.initiateSearch(false);
          addressViewController.disposeDialog();
          Get.to(
              () => AddNewAddress(
                    shouldReturnDarkStatus: true,
                  ),
              transition: Transition.fade,
              duration: Duration(seconds: 1));
          Future.delayed(const Duration(milliseconds: 410), () async {
            setState(() {
              SystemNavigation().applyCustomSystemChromeSettings(
                  Colors.white, Brightness.dark, Colors.white, Brightness.dark);
            });
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
          child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.white,
              //  border: Border.all(width: 3.5, color: Colors.white),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 1,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10, vertical: 8.0),
              child: Row(
                children: [
                  recommendedSpecialties.isLoaded
                      ? Icon(
                          size: Dimensions.iconSize24 * 1.3,
                          Icons.location_on_rounded,
                          color: Colors.black,
                        )
                      : Icon(
                          size: Dimensions.iconSize24 * 1.3,
                          Icons.location_on_rounded,
                          color: Colors.black,
                        )
                  // Padding(
                  //             padding: const EdgeInsets.all(6.0),
                  //             child: TuneIconSkeleton(),
                  //           ),
                  ,
                  SizedBox(
                    width: Dimensions.width20,
                  ),
                  Expanded(
                    child: MainAddress(
                      street: street,
                    ),
                  ),
                  ShowEta()
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
