import 'package:flutter/material.dart';

class SmallText extends StatelessWidget {
  Color? color;
  final String text;
  int maxLines;
  double size;
  double height;
  TextOverflow overFlow;
  FontWeight? fontWeight;
  String family;
  TextAlign? textAlign;
  bool? softWrap;
  SmallText(
      {Key? key,
      this.family = 'Poppins',
      this.color = const Color(0xFF000000),
      required this.text,
      this.maxLines = 2,
      this.overFlow = TextOverflow.ellipsis,
      this.fontWeight = FontWeight.w300,
      this.size = 14.0,
      this.height = 1.8,
      this.textAlign = TextAlign.start,
      this.softWrap = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overFlow,
      maxLines: maxLines,
      softWrap: softWrap,
      style: TextStyle(
        fontFamily: family,
        letterSpacing: 0.10,
        color: color,
        fontSize: size,
        height: height,
        fontWeight: fontWeight,
      ),
    );
  }
}
