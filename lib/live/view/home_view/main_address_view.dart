import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/live/auxiliery_classes/main_address.dart';
import 'package:izinto/live/auxiliery_classes/show_eta.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:izinto/live/view/address_view/saved_addresses.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/view/profile_view/profile_view.dart';
import 'package:izinto/pages/options/location_settings.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/recommended_specialty_controller.dart';
import '../../../models/user.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/skeletons.dart';
import '../../utilities/generic_snackbar.dart';
import '../../utilities/generic_system_navigation.dart';
import '../address_view/add_new_address.dart';
import '../auth_view/phone_auth_view.dart';
import '../profile_view/controller/profile_view_controller.dart';

class MainAddressView extends StatefulWidget {
  const MainAddressView({Key? key}) : super(key: key);

  @override
  State<MainAddressView> createState() => _MainAddressViewState();
}

class _MainAddressViewState extends State<MainAddressView> {
  @override
  void initState() {
    _loadGuestAddress();
    super.initState();
  }

  Future<void> _loadGuestAddress() async {
    final addressController = context.read<MainAddressViewController>();
    await addressController.loadGuestAddressFromLocalStorage();

    if (await addressController.hasGuestAddress()) {
      print('Guest address loaded: ${addressController.street}');
      // Force a rebuild after loading the address
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    return GetBuilder<RecommendedSpecialtyController>(
      builder: (recommendedSpecialties) {
        return Consumer<MainAddressViewController>(
          builder: (context, addressViewController, child) {
            // Also consume ProfileViewController for user addresses
            return Consumer<ProfileViewController>(
              builder: (context, _profileController, child) {
                /// Here's a list of addresses from the controller
                final List<dynamic> _addresses =
                    _profileController.savedAddresses;

                /// Here's the selection of currently active address///
                var selectedAddresses = _addresses
                    .where((address) => address['selected'] == true)
                    .toList();

                String street = '';

                if (user != null && selectedAddresses.isNotEmpty) {
                  street = selectedAddresses.first['street'] ?? '';
                } else if (addressViewController.hasData) {
                  street = addressViewController.street;
                } else {
                  street = 'Rivonia Blvd & Mutual Rd';
                }

                return GestureDetector(
                  onTap: () {
                    if (user == null) {
                      GenericSnackBar().showCustomSnackBar(() {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        homeViewController.onIndependentPageNavigation(
                            context, PhoneAuthView());
                      }, context, 'Please login to continue', false);
                    } else {
                      Get.to(
                        () => SavedAddresses(),
                        transition: Transition.circularReveal,
                        duration: Duration(milliseconds: 500),
                      );
                      Future.delayed(const Duration(milliseconds: 210),
                          () async {
                        setState(() {
                          SystemNavigation().applyCustomSystemChromeSettings(
                              Colors.white,
                              Brightness.dark,
                              Colors.white,
                              Brightness.dark);
                        });
                      });
                    }
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: Dimensions.width10),
                    child: Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
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
                                  ),
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
              },
            );
          },
        );
      },
    );
  }
}
