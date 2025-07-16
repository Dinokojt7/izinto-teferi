import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';
import '../text_widgets/heading_style_text.dart';

class MainActionButton extends StatelessWidget {
  final String text;
  final bool isActive;
  const MainActionButton({Key? key, required this.text, required this.isActive})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.5),
      ),
      child: Center(
        child: HeadingStyleText(
          size: Dimensions.font20 * 1.1,
          color: Colors.white,
          text: text,
          family: 'Poppins',
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
