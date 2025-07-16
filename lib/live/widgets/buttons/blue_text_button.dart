import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

import '../../../utils/dimensions.dart';
import '../../utilities/colors.dart';

class BlueTextButton extends StatelessWidget {
  final String text;
  final double horizontalPadding;
  final double? textSize;
  final bool? isLoading;
  final VoidCallback onTap;
  const BlueTextButton(
      {Key? key,
      required this.text,
      this.horizontalPadding = 10.0,
      this.textSize,
      this.isLoading = false,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color contentColor = LiveColors.standardBlue.withOpacity(0.8);
    return Container(
        decoration: BoxDecoration(
          color: LiveColors.standardBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(Dimensions.radius15),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            onTap: onTap,
            child: Padding(
              padding: isLoading!
                  ? EdgeInsets.symmetric(horizontal: 19.0, vertical: 5)
                  : EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: 3),
              child: isLoading!
                  ? SizedBox(
                      width: 15.0,
                      height: 15.0,
                      child: CircularCappedProgressIndicator(
                          //   value: _foregroundAnimation.value,
                          color: contentColor,
                          strokeWidth: 2.0,
                          strokeCap: StrokeCap.round),
                    )
                  : HeadingStyleText(
                      size: textSize ?? Dimensions.font20 / 1.5,
                      color: contentColor,
                      text: text,
                      family: 'Poppins',
                      weight: FontWeight.w600,
                    ),
            ),
          ),
        ));
  }
}
