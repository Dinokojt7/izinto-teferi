import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 0.6,
            color: Colors.grey.shade400,
            endIndent: Dimensions.width20,
          ),
        ),
        HeadingStyleText(
          text: 'O',
          letterSpacing: 0.1,
          size: Dimensions.font20 / 1.2,
          weight: FontWeight.w400,
          color: Colors.black,
        ),
        HeadingStyleText(
          text: 'r',
          letterSpacing: 0.1,
          family: 'Onest',
          size: Dimensions.font20 / 1.3,
          weight: FontWeight.w400,
          color: Colors.black,
        ),
        Expanded(
          child: Divider(
            thickness: 0.6,
            color: Colors.grey.shade400,
            indent: Dimensions.width20,
          ),
        ),
      ],
    );
  }
}
