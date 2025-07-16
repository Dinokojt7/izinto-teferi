import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';
import 'main_action_button.dart';
import '../text_widgets/heading_style_text.dart';

class CartActionButton extends StatelessWidget {
  final bool isActive;
  final String description;
  final Color? backgroundColor;
  final bool? isCartCheckoutButton;
  final VoidCallback onTap;
  const CartActionButton({
    super.key,
    required this.isActive,
    required this.description,
    this.backgroundColor = Colors.black,
    this.isCartCheckoutButton = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          top: Dimensions.height10 / 4,
        ),
        child: Container(
          height:
              isCartCheckoutButton! ? Dimensions.bottomHeightBar / 1.9 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
            color:
                isActive ? backgroundColor : Colors.black12.withOpacity(0.17),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: Dimensions.height15,
                    horizontal: Dimensions.width30),
                child: Center(
                  child: isCartCheckoutButton!
                      ? Row(
                          children: [
                            HeadingStyleText(
                              size: Dimensions.font16,
                              color: Colors.white,
                              text: description,
                              family: 'Poppins',
                              weight: FontWeight.w600,
                            ),
                            SizedBox(
                              width: Dimensions.width10 / 2,
                            ),
                            Icon(
                              Icons.arrow_forward_outlined,
                              // weight: weight,
                              color: Colors.white,
                              size: 16,
                            )
                          ],
                        )
                      : HeadingStyleText(
                          size: Dimensions.font16,
                          color: Colors.white,
                          text: description,
                          family: 'Poppins',
                          weight: FontWeight.w600,
                        ),
                ),
              ),
            ),
          ),
        ));
  }
}
