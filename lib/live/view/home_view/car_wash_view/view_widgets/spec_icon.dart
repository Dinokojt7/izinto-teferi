import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

class SpecIcon extends StatelessWidget {
  final String image;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final double? weight;
  final BoxBorder? boxBorder;
  SpecIcon(
      {Key? key,
      required this.image,
      this.backgroundColor = const Color(0xFFfcf4e4),
      this.iconColor = const Color(0xFF000000),
      this.size = 40,
      this.iconSize = 18,
      this.weight,
      this.boxBorder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            border: boxBorder,
            borderRadius: BorderRadius.circular(size / 2),
            color: backgroundColor),
        child: Image.asset(
          image,
          // Image path from item list
          width: 28.0,
          height: 20.0,
        ));
  }
}
