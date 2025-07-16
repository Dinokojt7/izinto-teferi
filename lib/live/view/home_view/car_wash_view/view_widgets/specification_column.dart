import 'package:flutter/material.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/spec_icon.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../../widgets/texts/small_text.dart';

class SpecificationColumn extends StatelessWidget {
  final String text;
  final String image;
  final Color backgroundColor;
  const SpecificationColumn(
      {Key? key,
      required this.text,
      required this.image,
      required this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SpecIcon(
          image: image,
          size: 50,
          backgroundColor: backgroundColor,
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        Center(
          child: SmallText(
            overFlow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            size: Dimensions.font20 / 1.8,
            family: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.black,
            text: text,
            softWrap: true, // Allow text to wrap
            // Text can overflow normally
          ),
        ),
      ],
    );
  }
}
