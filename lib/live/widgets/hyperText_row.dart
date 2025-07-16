import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

import '../../utils/dimensions.dart';
import '../utilities/colors.dart';

class HyperTextRow extends StatelessWidget {
  final String preText;
  final String firstLink;
  final String middleText;
  final String secondLink;

  const HyperTextRow({
    super.key,
    required this.preText,
    required this.firstLink,
    required this.middleText,
    required this.secondLink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          onTap: () {
            // Get.to(() => const TermsOfUse(),
            //     transition: Transition.rightToLeft,
            //     duration: Duration(milliseconds: 100));
          },
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
        GestureDetector(
          onTap: () {
            // Get.to(() => const TermsOfUse(),
            //     transition: Transition.rightToLeft,
            //     duration: Duration(milliseconds: 100));
          },
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
    );
  }
}
