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
                onChanged: (value) {
                  checkout.toggleLeaveAtDoor(value);
                },
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
            onChanged: (value) {
              checkout.toggleBellAllowed(value);
            },
          ),
          SizedBox(
            height: Dimensions.height10 / 5,
          ),
          OptionLayout(
            icon: Icons.call_outlined,
            settingDescription: 'Call when you arrive',
            isSelected: shouldCall,
            onChanged: (value) {
              checkout.toggleCallWhenArrive(value);
            },
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
  final Function(bool) onChanged;

  OptionLayout({
    super.key,
    required this.icon,
    required this.settingDescription,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  State<OptionLayout> createState() => _OptionLayoutState();
}

class _OptionLayoutState extends State<OptionLayout> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(widget.icon, size: 24.0),
        SizedBox(width: Dimensions.width20),
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
              unselectedWidgetColor: Colors.black,
              checkboxTheme: CheckboxThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                  side: BorderSide(color: Colors.black, width: 1.0),
                ),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.black; // Black when checked
                  }
                  return Colors.transparent;
                }),
                checkColor:
                    WidgetStateProperty.all(Colors.white), // White checkmark
                overlayColor:
                    WidgetStateProperty.all(Colors.black.withOpacity(0.1)),
                splashRadius: 0,
              ),
            ),
            child: Checkbox(
              value: widget.isSelected,
              onChanged: (bool? value) {
                setState(() {
                  widget.isSelected = value ?? false;
                });
                widget.onChanged(widget.isSelected);
              },
            ),
          ),
        )
      ],
    );
  }
}
