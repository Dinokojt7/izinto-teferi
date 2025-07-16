import 'package:flutter/material.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/generic_white_container.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

import '../../../../utils/dimensions.dart';

class PromoContainer extends StatelessWidget {
  final String promoCode;
  const PromoContainer({
    super.key,
    required this.promoCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: Dimensions.height45 * 3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
        image: DecorationImage(
          image: AssetImage(
            'assets/image/wallpaper.jpeg',
          ),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Stack(
        children: [
          Container(
            width: double.maxFinite,
            height: Dimensions.height45 * 3,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(
                  0.2), // Adjust the opacity for the overlay effect
              borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 16.0, top: 16.0, right: 16.0, bottom: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenericWhiteContainer(
                  color: Colors.black,
                  isExpanded: false,
                  child: HeadingStyleText(
                    text: 'YOUR CODE: ${promoCode}',
                    color: Colors.white,
                    size: Dimensions.font20 / 1.2,
                  ),
                ),
                HeadingStyleText(
                  text: 'Invite a friend and earn R50!',
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
