import 'package:flutter/material.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../widgets/text_widgets/heading_style_text.dart';

class AddCarButton extends StatelessWidget {
  const AddCarButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: Dimensions.height10 / 2, horizontal: Dimensions.width30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(Dimensions.radius15),
            bottomLeft: Radius.circular(Dimensions.radius15),
            topLeft: Radius.circular(Dimensions.radius15),
            bottomRight: Radius.circular(Dimensions.radius15)),
        color: Colors.black.withOpacity(0.4),
      ),
      child: Center(
        child: HeadingStyleText(
          size: Dimensions.font16 / 1.15,
          color: Colors.white,
          text: 'Select',
          family: 'Poppins',
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
