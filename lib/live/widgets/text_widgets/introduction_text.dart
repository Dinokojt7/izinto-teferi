import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';

class IntroductionText extends StatelessWidget {
  final String text;
  final double? textSize;
  final int? maxLines;
  final Color? color;
  const IntroductionText({
    super.key,
    required this.text,
    this.textSize,
    this.maxLines = 2,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: Dimensions.screenWidth - 40, // Account for padding
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          height: 1.2,
          fontSize: textSize ?? Dimensions.font26,
          fontFamily: 'Poppins',
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
