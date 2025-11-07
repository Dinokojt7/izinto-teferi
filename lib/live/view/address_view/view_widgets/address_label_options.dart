// Updated AddressLabelOptions with animation
import 'package:flutter/material.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import 'add_new_label.dart';
import 'list_tile_label.dart';

class AddressLabelOptions extends StatelessWidget {
  final bool isEditAddressChild;
  const AddressLabelOptions({
    super.key,
    required this.isEditAddressChild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MainAddressViewController>(
      builder: (context, addressController, child) {
        return AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: addressController.isDropdownOpen
              ? (isEditAddressChild
                  ? Dimensions.screenHeight / 2.25
                  : Dimensions.screenHeight / 4)
              : -300, // Move off-screen when closed
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 250),
            opacity: addressController.isDropdownOpen ? 1.0 : 0.0,
            child: Padding(
              padding: EdgeInsets.only(left: 24.0, top: 25.0, right: 24.0),
              child: Material(
                elevation: 2.0,
                borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radius15 * 1.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 3,
                        blurRadius: 12,
                        offset: Offset(0, isEditAddressChild ? -3 : 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTileLabel(
                        imagePath: 'assets/image/hut.png',
                        description: 'Home',
                        index: 0,
                        onTap: () => _handleLabelSelection(context, 'Home'),
                      ),
                      Divider(
                        thickness: 0.4,
                        color: Colors.grey.shade400,
                        height: 1,
                      ),
                      ListTileLabel(
                        imagePath: 'assets/image/office.png',
                        description: 'Office',
                        index: 1,
                        onTap: () => _handleLabelSelection(context, 'Office'),
                      ),
                      Divider(
                        thickness: 0.4,
                        color: Colors.grey.shade400,
                        height: 1,
                      ),
                      AddNewLabel(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLabelSelection(BuildContext context, String label) {
    final addressController =
        Provider.of<MainAddressViewController>(context, listen: false);
    addressController.setAddressLabel(label, false);
    addressController.clearLabel(); // Close dropdown after selection
  }
}
