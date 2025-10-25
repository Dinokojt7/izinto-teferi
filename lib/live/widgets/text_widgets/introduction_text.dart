import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';

class IntroductionText extends StatelessWidget {
  final String text;
  final double? textSize;
  final int? maxLines;
  final Color? color;
  const IntroductionText(
      {super.key,
      required this.text,
      this.textSize,
      this.maxLines = 2,
      this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        text,
        maxLines: maxLines,
        style: TextStyle(
          height: 1.2,
          overflow: TextOverflow.ellipsis,
          fontSize: textSize ?? Dimensions.font26,
          fontFamily: 'Poppins',
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
