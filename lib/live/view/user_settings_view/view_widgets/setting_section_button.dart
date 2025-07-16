import 'package:flutter/material.dart';
import 'package:izinto/live/view/address_view/view_widgets/list_tile_label.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../address_view/controller/address_dropdown_controller.dart';

class SettingsSectionButton extends StatelessWidget {
  final String selectedOption;

  const SettingsSectionButton({Key? key, required this.selectedOption})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          selectedOption,
          style: TextStyle(
            fontSize: Dimensions.font20 / 1.2,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        Icon(
          Icons.keyboard_arrow_right_outlined,
          color: Colors.black,
        ),
      ],
    );
  }
}
