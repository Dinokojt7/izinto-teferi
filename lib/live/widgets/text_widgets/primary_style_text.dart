import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

class PrimaryStyleText extends StatelessWidget {
  Color? color;
  final String text;
  double? size;
  double? height;
  TextOverflow overFlow;
  FontWeight? weight;
  int? maxLines;
  TextAlign? align;
  String family;
  PrimaryStyleText(
      {Key? key,
      this.color = const Color(0xfF000000),
      required this.text,
      this.weight = FontWeight.w500,
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
        height: height,
        fontFamily: family,
        color: color != null ? color : color?.withOpacity(0.85),
        fontSize: size == 0 ? Dimensions.font16 : size,
        fontWeight: weight,
      ),
    );
  }
}
