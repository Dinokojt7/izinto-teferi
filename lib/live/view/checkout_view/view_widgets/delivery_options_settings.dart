import 'package:flutter/material.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class DeliveryOptionsSettings extends StatefulWidget {
  DeliveryOptionsSettings({
    Key? key,
  }) : super(key: key);

  @override
  State<DeliveryOptionsSettings> createState() =>
      _DeliveryOptionsSettingsState();
}

class _DeliveryOptionsSettingsState extends State<DeliveryOptionsSettings> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutViewController>(
        builder: (context, checkout, child) {
      bool shouldLeaveAtTheDoor = checkout.shouldLeaveAtTheDoor;
      bool shouldRingBell = checkout.isBellAllowed;
      bool shouldCall = checkout.shouldCallWhenArrive;
      return Column(
        children: [
          Stack(
            children: [
              OptionLayout(
                icon: Icons.door_front_door_outlined,
                settingDescription: 'Leave at the door',
                isSelected: shouldLeaveAtTheDoor,
              ),
              Container(
                height: Dimensions.height45,
                color: Colors.white.withOpacity(0.6),
              )
            ],
          ),
          SizedBox(
            height: Dimensions.height10 / 5,
          ),
          OptionLayout(
            icon: MdiIcons.bellCancelOutline,
            settingDescription: 'Don\'t ring the bell',
            isSelected: shouldRingBell,
          ),
          SizedBox(
            height: Dimensions.height10 / 5,
          ),
          OptionLayout(
            icon: Icons.call_outlined,
            settingDescription: 'Call when you arrive',
            isSelected: shouldCall,
          ),
        ],
      );
    });
  }
}

class OptionLayout extends StatefulWidget {
  final IconData icon;
  final String settingDescription;
  bool isSelected;
  OptionLayout(
      {super.key,
      required this.icon,
      required this.settingDescription,
      required this.isSelected});

  @override
  State<OptionLayout> createState() => _OptionLayoutState();
}

class _OptionLayoutState extends State<OptionLayout> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(widget.icon, size: 24.0), // Your icon
        SizedBox(width: Dimensions.width20), // Space between icon and text
        Expanded(
          child: HeadingStyleText(
            text: widget.settingDescription,
            size: Dimensions.font20 / 1.3,
            family: 'Poppins',
            weight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        Transform.scale(
          scale: 1.1,
          child: Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.black, // Darker border color
              checkboxTheme: CheckboxThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0), // Square shape
                  side: BorderSide(
                      color: Colors.black, width: 1.0), // Darker border
                ),
              ),
            ),
            child: Checkbox(
              value: widget.isSelected,
              onChanged: (bool? value) {
                setState(() {
                  widget.isSelected = value ?? false;
                });
                Provider.of<CheckoutViewController>(context, listen: false)
                    .selectOption();
              },
            ),
          ),
        )
      ],
    );
  }
}
