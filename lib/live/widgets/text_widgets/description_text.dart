import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';
import 'heading_style_text.dart';

class DescriptionText extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;
  final int? maxLines;
  const DescriptionText(
      {super.key,
      required this.text,
      this.fontWeight = FontWeight.w300,
      this.maxLines = 2});

  @override
  Widget build(BuildContext context) {
    return HeadingStyleText(
      maxLines: maxLines,
      text: text,
      size: Dimensions.font20 / 1.3,
      weight: fontWeight,
      color: Colors.black,
    );
  }
}
