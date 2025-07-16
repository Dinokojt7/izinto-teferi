import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

class SmallWhiteText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double? height;
  String? font;
  TextOverflow overFlow;
  FontWeight? fontWeight;
  int? maxLines;
  TextAlign? align;
  SmallWhiteText(
      {Key? key,
      this.color = const Color(0xFFf7f6f4),
      required this.text,
      this.fontWeight,
      this.height,
      this.align,
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
        fontSize: size == 0 ? Dimensions.font20 : size,
        fontWeight: fontWeight,
      ),
    );
  }
}
