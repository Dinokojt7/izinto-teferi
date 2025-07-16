import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

class AppIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final double? weight;
  final BoxBorder? boxBorder;
  AppIcon(
      {Key? key,
      required this.icon,
      this.backgroundColor = const Color(0xFFfcf4e4),
      this.iconColor = const Color(0xFF000000),
      this.size = 40,
      this.iconSize = 16,
      this.weight,
      this.boxBorder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          border: boxBorder,
          borderRadius: BorderRadius.circular(size / 2),
          color: backgroundColor),
      child: Icon(
        icon,
        weight: weight,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}
