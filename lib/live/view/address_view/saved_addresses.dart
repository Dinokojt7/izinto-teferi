import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/address_view/add_new_address.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:izinto/live/view/address_view/view_widgets/saved_address_widget.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/generic_white_container.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/buttons/main_action_button.dart';

class SavedAddresses extends StatefulWidget {
  const SavedAddresses({Key? key}) : super(key: key);

  @override
  State<SavedAddresses> createState() => _SavedAddressesState();
}

class _SavedAddressesState extends State<SavedAddresses> {
  void _applySystemChromeSettings() {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.white.withOpacity(0.95),
          Brightness.dark,
          Colors.white,
          Brightness.dark);
    });
  }

  void _onTap() {
    _applySystemChromeSettings();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final addressViewController =
        Provider.of<MainAddressViewController>(context, listen: false);
    final _controller = Provider.of<ProfileViewController>(context);
    final List items = _controller.savedAddresses;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _applySystemChromeSettings();
          Navigator.of(context).pop();
        }
      },
      child: Builder(builder: (context) {
        return Scaffold(
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
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      heading: 'Your addresses',
                      onTap: _onTap,
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                    height: double.maxFinite,
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 24.0, top: 25.0, right: 24.0),
                      child:
// In your SavedAddresses widget build method, update the ListView.builder:
// In your SavedAddresses widget build method, update the ListView.builder:
                          ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          // Safe address field access
                          final street =
                              item['street']?.toString() ?? 'No street address';
                          final zip = item['zip']?.toString() ?? '';
                          final suburb = item['suburb']?.toString() ?? '';
                          final isSelected = item['selected'] == true;

                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: Dimensions.height20 * 1.4),
                            child: GestureDetector(
                              onTap: () {
                                _controller.updateSelectedAddress(street);
                                _controller
                                    .updateSelectedAddressInFirebase(street);
                              },
                              child: GenericWhiteContainer(
                                bottomPadding: Dimensions.height15,
                                isSelected: isSelected,
                                child: SavedAddressWidget(
                                  streetNumber: street,
                                  zipCode: zip,
                                  suburb: suburb,
                                  index: index,
                                  // Pass the isLastAddress information to the widget
                                  isLastAddress: items.length <= 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: Container(
            height: Dimensions.bottomHeightBar / 1.1,
            color: Colors.transparent,
            child: Padding(
                padding: EdgeInsets.only(
                    left: 24.0, top: 15.0, right: 24.0, bottom: 15.0),
                child: SaveButton(
                  isActive: true,
                  description: 'Add new address',
                  isAuthScreen: false,
                  onTap: () {
                    addressViewController.setNavigationSource('regular');

                    addressViewController.disposeDialog();
                    Get.to(
                        () => AddNewAddress(
                              shouldReturnDarkStatus: true,
                            ),
                        transition: Transition.fade,
                        duration: Duration(seconds: 1));
                  },
                )),
          ),
        );
      }),
    );
  }
}
