import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

class FlexibleFont extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  String font;
  double? height;
  TextOverflow overFlow;
  FontWeight? weight;
  int? maxLines;
  TextAlign? align;
  FlexibleFont(
      {Key? key,
      this.color = const Color(0xFF707070),
      required this.text,
      this.weight,
      this.height,
      this.align,
      required this.font,
      this.maxLines,
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
        fontWeight: weight,
      ),
    );
  }
}
