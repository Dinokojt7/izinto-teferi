import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

class SmallBlackText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double? height;
  String? font;
  TextOverflow overFlow;
  FontWeight? fontWeight;
  int? maxLines;
  TextAlign? align;
  TextDecoration? decoration;
  SmallBlackText(
      {Key? key,
      this.color = const Color(0xFF000000),
      required this.text,
      this.fontWeight = FontWeight.w600,
      this.height,
      this.align,
      this.maxLines,
      this.decoration,
      this.font = 'Poppins',
      this.overFlow = TextOverflow.clip,
      this.size = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overFlow,
      style: TextStyle(
        decoration: decoration,
        height: height,
        fontFamily: font,
        color: color,
        fontSize: size == 0 ? Dimensions.font20 / 1.3 : size,
        fontWeight: fontWeight,
      ),
    );
  }
}
