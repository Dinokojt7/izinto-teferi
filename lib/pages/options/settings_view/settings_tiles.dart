import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';

class SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  const SettingsTile({Key? key, required this.icon, required this.title})
      : super(key: key);

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  bool _isTouching = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width10 / 2,
          top: Dimensions.height10 / 2,
          right: Dimensions.width10 / 2,
          bottom: Dimensions.height20 / 4),
      child: Listener(
        onPointerDown: (event) => setState(() {
          _isTouching = true;
        }),
        onPointerUp: (event) => setState(() {
          _isTouching = false;
        }),
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.only(
              right: Dimensions.width20,
              left: Dimensions.width20,
              top: Dimensions.height15,
              bottom: Dimensions.height15),
          color: _isTouching
              ? Colors.black12.withOpacity(0.08)
              : Colors.transparent,
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: Color(0Xff353839),
              ),
              SizedBox(
                width: Dimensions.width20,
              ),
              Text(
                widget.title,
                style: TextStyle(
                    letterSpacing: 0.7,
                    fontSize: Dimensions.font16,
                    color: const Color(0Xff353839),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
