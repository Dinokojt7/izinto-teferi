import 'package:flutter/material.dart';

import '../../utilities/live_dimensions.dart';
import '../text_widgets/primary_style_text.dart';

class HeaderTextButton extends StatelessWidget {
  final String text;
  final FontWeight? weight;
  const HeaderTextButton({Key? key, required this.text, this.weight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LiveDimensions.height45 / 1.2,
      child: Padding(
        padding: EdgeInsets.only(
            top: LiveDimensions.width10 / 5, left: 14.0, right: 14.0),
        child: PrimaryStyleText(
          text: text,
          weight: FontWeight.w600,
          size: LiveDimensions.font26,
          color: Colors.white,
        ),
      ),
    );
  }
}
