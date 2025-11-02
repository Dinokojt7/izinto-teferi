import 'package:flutter/material.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/setting_section_button.dart';

import '../../../../utils/dimensions.dart';
import '../../checkout_view/view_widgets/generic_white_container.dart';

class settingsSection extends StatefulWidget {
  final void Function() onTap;
  final String subHeading;
  const settingsSection({
    super.key,
    required this.subHeading,
    required this.onTap,
  });

  @override
  State<settingsSection> createState() => _settingsSectionState();
}

class _settingsSectionState extends State<settingsSection> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    void _handleTap() {
      setState(() {
        _isTapped = true;
      });
      widget.onTap(); // FIX: Added parentheses to actually call the function

      // Optional: Reset border visibility after a short delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _isTapped = false;
          });
        }
      });
    }

    return Container(
      height: Dimensions.height45 * 1.4,
      width: double.maxFinite,
      margin:
          EdgeInsets.only(left: Dimensions.width15, right: Dimensions.width15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
        color: _isTapped ? Colors.grey.shade200 : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // splashColor: Colors.purple,
          // highlightColor: Colors.brown,
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          onTap: _handleTap,
          child: Padding(
            padding: EdgeInsets.only(
              left: Dimensions.width10 / 1.5,
              top: Dimensions.height10,
              right: 15.0,
              bottom: Dimensions.height10,
            ),
            child: SettingsSectionButton(
              selectedOption: widget.subHeading,
            ),
          ),
        ),
      ),
    );
    // return GestureDetector(
    //   onTap: onTap,
    //   child: GenericWhiteContainer(
    //     isSelected: false,
    //     topPadding: Dimensions.height10,
    //     bottomPadding: Dimensions.height20 / 2,
    //     leftPadding: Dimensions.width10 / 1.5,
    //     color: Colors.white,
    //     child: SettingsSectionButton(
    //       selectedOption: subHeading,
    //     ),
    //   ),
    // );
  }
}
