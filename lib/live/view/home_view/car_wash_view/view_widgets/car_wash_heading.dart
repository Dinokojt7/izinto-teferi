import 'package:flutter/material.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../../widgets/texts/small_text.dart';

class CarWashHeading extends StatelessWidget {
  final String text;
  const CarWashHeading({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SmallText(
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            size: Dimensions.font16 / 1.1,
            text: text),
      ],
    );
  }
}
