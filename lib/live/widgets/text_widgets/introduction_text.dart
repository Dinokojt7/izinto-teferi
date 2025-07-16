import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';

class IntroductionText extends StatelessWidget {
  final String text;
  final double? textSize;
  const IntroductionText({
    super.key,
    required this.text,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        text,
        maxLines: 2,
        style: TextStyle(
          height: 1.2,
          overflow: TextOverflow.ellipsis,
          fontSize: textSize ?? Dimensions.font26,
          fontFamily: 'Poppins',
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
