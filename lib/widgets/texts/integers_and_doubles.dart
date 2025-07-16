import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

class IntegerText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double? height;
  String? font;
  TextOverflow overFlow;
  FontWeight? fontWeight;
  TextDecoration? decoration;
  int? maxLines;
  TextAlign? align;
  IntegerText(
      {Key? key,
      this.color = const Color(0xFF707070),
      required this.text,
      this.fontWeight,
      this.height,
      this.align,
      this.decoration,
      this.maxLines,
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
        height: height,
        fontFamily: font,
        color: color,
        decoration: decoration,
        fontSize: size == 0 ? Dimensions.font20 : size,
        fontWeight: fontWeight,
      ),
    );
  }
}
