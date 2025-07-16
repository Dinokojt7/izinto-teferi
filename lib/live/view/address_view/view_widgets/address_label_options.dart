import 'package:flutter/material.dart';

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
    return Positioned(
      top: isEditAddressChild
          ? Dimensions.screenHeight / 2.25
          : Dimensions.screenHeight /
              4, // Adjust this based on the height of your dropdown container
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.only(left: 24.0, top: 25.0, right: 24.0),
        child: Material(
          elevation: 2.0,
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey
                      .withOpacity(0.4), // Slightly more opaque shadow color
                  spreadRadius: 3, // Increase spread to cover more area
                  blurRadius: 12, // Increase blur for smoother shadow
                  offset: Offset(
                      0, isEditAddressChild ? -3 : 3), // Slight upward shadow
                ),
              ],
            ),
            child: Column(
              children: [
                ListTileLabel(
                  imagePath: 'assets/image/hut.png',
                  description: 'Home',
                  index: 0,
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
                ),
                Divider(
                  thickness: 0.4,
                  color: Colors.grey.shade400,
                  height: 1,
                ),
                GestureDetector(
                  onTap: () {
                    // setState(() {
                    //   // isDropdownOpen = false;
                    // });
                    // _showAddNewLabelDialog();
                  },
                  child: AddNewLabel(),

                  // ListTileLabel(
                  //   imagePath: 'assets/image/plus.png',
                  //   description: 'Add new label...',
                  //   index: 2,
                  // ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
