import '../../miscellaneous/app_icon.dart';
import 'package:flutter/material.dart';

class SubColumnGesture extends StatelessWidget {
  const SubColumnGesture({
    Key? key,
    required this.closeSubView,
    required this.icon,
  }) : super(key: key);

  final void Function() closeSubView;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: closeSubView,
        child: AppIcon(
          size: 22,
          backgroundColor: Color(0xFFCFC5A5),
          weight: 20,
          icon: icon,
          iconColor: Colors.white,
          iconSize: 20,
        ),
      ),
    );
  }
}
