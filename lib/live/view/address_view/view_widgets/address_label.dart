import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../controller/address_dropdown_controller.dart';

class AddressLabel extends StatelessWidget {
  const AddressLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainAddressViewController>(
      builder: (context, _addressController, child) {
        bool _isDropdownOpen = _addressController.isDropdownOpen;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
            color: _isDropdownOpen ? Colors.grey.shade50 : Colors.transparent,
          ),
          child: GestureDetector(
            onTap: () {
              _addressController.selectLabel();
            },
            child: Container(
              height: Dimensions.height45,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: Dimensions.height10 / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: _isDropdownOpen
                          ? Dimensions.font16 / 1.5
                          : Dimensions.font20 / 1.38,
                      fontFamily: 'Poppins',
                      fontWeight:
                          _isDropdownOpen ? FontWeight.w500 : FontWeight.w300,
                      color:
                          Colors.black.withOpacity(_isDropdownOpen ? 0.9 : 0.8),
                    ),
                    child: Text(
                      _addressController.label.trim().isNotEmpty
                          ? _addressController.label
                          : 'Add new label...',
                    ),
                  ),
                  AnimatedRotation(
                    duration: Duration(milliseconds: 300),
                    turns: _isDropdownOpen ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
