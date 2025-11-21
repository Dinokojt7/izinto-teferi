import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';

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
