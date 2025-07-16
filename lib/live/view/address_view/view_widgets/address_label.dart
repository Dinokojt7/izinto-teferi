import 'package:flutter/material.dart';
import 'package:izinto/live/view/address_view/view_widgets/list_tile_label.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../controller/address_dropdown_controller.dart';

class AddressLabel extends StatelessWidget {
  const AddressLabel({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<MainAddressViewController>(
        builder: (context, _addressController, child) {
      bool _isDropdownOpen = _addressController.isDropdownOpen;
      return GestureDetector(
        onTap: () {
          _addressController.selectLabel();
        },
        child: Container(
          height: Dimensions.height45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: 16.0, vertical: Dimensions.height10 / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _addressController.label.trim().length != 0
                    ? _addressController.label
                    : 'Add new label...',
                style: TextStyle(
                  fontSize: _isDropdownOpen
                      ? Dimensions.font16 / 1.5
                      : Dimensions.font20 / 1.38,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              Icon(
                _isDropdownOpen
                    ? Icons.keyboard_arrow_up_outlined
                    : Icons.keyboard_arrow_down_outlined,
                color: Colors.black,
              ),
            ],
          ),
        ),
      );
    });
  }
}
