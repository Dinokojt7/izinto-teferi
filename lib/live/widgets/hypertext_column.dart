import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

import '../../utils/dimensions.dart';
import '../utilities/colors.dart';

class HyperTextColumn extends StatelessWidget {
  final String preText;
  final String firstLink;
  final String middleText;
  final String secondLink;
  final VoidCallback? onFirstLinkTap;
  final VoidCallback? onSecondLinkTap;

  const HyperTextColumn({
    super.key,
    required this.preText,
    required this.firstLink,
    required this.middleText,
    required this.secondLink,
    this.onFirstLinkTap,
    this.onSecondLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HeadingStyleText(
              text: preText,
              size: Dimensions.font20 / 1.8,
              family: 'Poppins',
              weight: FontWeight.w300,
              color: Colors.black,
            ),
            SizedBox(
              width: Dimensions.width10 / 2,
            ),
            GestureDetector(
              onTap: onFirstLinkTap,
              child: HeadingStyleText(
                text: firstLink,
                size: Dimensions.font20 / 1.8,
                family: 'Poppins',
                weight: FontWeight.w600,
                color: LiveColors.standardBlue,
              ),
            ),
            SizedBox(
              width: Dimensions.width10 / 2,
            ),
            HeadingStyleText(
              text: middleText,
              size: Dimensions.font20 / 1.8,
              family: 'Poppins',
              weight: FontWeight.w300,
              color: Colors.black,
            ),
            SizedBox(
              width: Dimensions.width10 / 2,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onSecondLinkTap,
              child: HeadingStyleText(
                text: secondLink,
                size: Dimensions.font20 / 1.8,
                family: 'Poppins',
                weight: FontWeight.w600,
                color: LiveColors.standardBlue,
              ),
            ),
            HeadingStyleText(
              text: '.',
              size: Dimensions.font20 / 1.8,
              family: 'Poppins',
              weight: FontWeight.w300,
              color: Colors.black,
            ),
          ],
        ),
      ],
    );
  }
}
