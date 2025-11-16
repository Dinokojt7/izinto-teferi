import 'package:flutter/material.dart';

import '../../utilities/colors.dart';
import '../../utilities/live_dimensions.dart';
import '../text_widgets/primary_style_text.dart';

class HighlightButton extends StatelessWidget {
  final String text;
  final FontWeight? weight;
  final double? fontSize;
  bool? isViewing = true;
  HighlightButton(
      {Key? key,
      required this.text,
      this.weight,
      required this.isViewing,
      this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LiveDimensions.height45 / 1.2,
      decoration: isViewing!
          ? BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey.withOpacity(0.1),
              ),
              color: LiveColors.accent.withOpacity(0.5),
              borderRadius: BorderRadius.circular(LiveDimensions.radius30 * 2),
              // border: Border.all(
              //   width: 0.5,
              //   color: Colors.white,
              // ),
            )
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: LiveDimensions.width10 / 1.8,
          horizontal: LiveDimensions.width15,
        ),
        child: Center(
          child: PrimaryStyleText(
            text: text,
            weight: weight,
            size: fontSize,
          ),
        ),
      ),
    );
  }
}
