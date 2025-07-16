import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class CheckoutPageAddress extends StatelessWidget {
  final String street;
  final String zip;
  final String suburb;
  const CheckoutPageAddress({
    super.key,
    required this.street,
    required this.zip,
    required this.suburb,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Image.asset(
            'assets/image/pin.png', // Image path from item list
            width: 22.0,
            height: 22.0,
          ),
        ),
        SizedBox(
          width: Dimensions.width20,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeadingStyleText(
                text: street,
                size: Dimensions.font20 / 1.3,
                family: 'Poppins',
                weight: FontWeight.w600,
              ),
              HeadingStyleText(
                text: '${zip} ${suburb}',
                size: Dimensions.font20 / 1.3,
                family: 'Poppins',
                weight: FontWeight.w300,
                color: Colors.black,
              )
            ],
          ),
        )
      ],
    );
  }
}
