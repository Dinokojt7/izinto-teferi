import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class SelectPaymentPending extends StatelessWidget {
  const SelectPaymentPending({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: Dimensions.width10, top: Dimensions.height10 / 2),
          child: Container(
            height: Dimensions.height45 * 1.1,
            width: Dimensions.width30 * 2.3,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius20 / 2),
              border: Border.all(
                color: Colors.grey.shade300, // Light grey color for the border
                width: 1.5, // Thin border width
              ),
            ),
            child: Image.asset(
              'assets/image/payment-method.png', // Image path from item list
              width: 30.0,
              height: 30.0,
            ),
          ),
        ),
        SizedBox(
          width: Dimensions.width20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Dimensions.height10 / 2.5,
            ),
            HeadingStyleText(
              text: 'Select payment method',
              size: Dimensions.font20 / 1.3,
              family: 'Poppins',
              weight: FontWeight.w500,
              color: Colors.black,
            ),
            SizedBox(
              height: Dimensions.height10 / 2,
            ),
            HeadingStyleText(
              text: 'Nothing selected yet',
              size: Dimensions.font20 / 1.3,
              family: 'Poppins',
              weight: FontWeight.w400,
              color: Colors.black.withOpacity(0.8),
            ),
          ],
        )
      ],
    );
  }
}
