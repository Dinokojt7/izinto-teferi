import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

class HeadingStyleText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double? height;
  TextOverflow overFlow;
  FontWeight? weight;
  int? maxLines;
  TextAlign? align;
  String family;
  double? letterSpacing;
  bool isCancelled;
  HeadingStyleText(
      {Key? key,
      this.letterSpacing = 0.0,
      this.color = const Color(0xfF000000),
      required this.text,
      this.isCancelled = false,
      this.weight = FontWeight.w400,
      this.height,
      this.align,
      this.family = 'Poppins',
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
        letterSpacing: letterSpacing,
        decoration:
            isCancelled ? TextDecoration.lineThrough : TextDecoration.none,
        height: height,
        fontFamily: family,
        color: color ?? color?.withOpacity(0.85),
        fontSize: size == 0 ? Dimensions.font26 / 1.225 : size,
        fontWeight: weight,
      ),
    );
  }
}
