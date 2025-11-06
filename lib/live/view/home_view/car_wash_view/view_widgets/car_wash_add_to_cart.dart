import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

class CarWashAddToCart extends StatelessWidget {
  final String itemCount;
  final VoidCallback onAddToCart;
  final VoidCallback onClearSelection;
  final bool hasSelection;
  final bool isActive;
  final bool isLoading;

  const CarWashAddToCart({
    Key? key,
    required this.onAddToCart,
    required this.onClearSelection,
    required this.hasSelection,
    required this.isActive,
    this.isLoading = false,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height45 * 1.2,
      child: Row(
        children: [
          GestureDetector(
            onTap: isActive && !isLoading ? onAddToCart : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                color: isActive && !isLoading ? Colors.black : Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: Dimensions.height20,
                        height: Dimensions.height20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : HeadingStyleText(
                        text: 'Add to Cart',
                        size: Dimensions.font20 / 1.5,
                        family: 'Poppins',
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
          GestureDetector(
            onTap: hasSelection ? onClearSelection : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20 / 2),
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radius15),
                  bottomLeft: Radius.circular(Dimensions.radius15),
                  topRight: Radius.circular(Dimensions.radius20 * 3),
                  bottomRight: Radius.circular(Dimensions.radius20 * 3),
                ),
                border: Border.all(color: Colors.black12, width: 2),
                color: Colors.black,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: Dimensions.height45 / 1.2,
                  height: Dimensions.height45 / 1.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HeadingStyleText(
                      text: itemCount,
                      size: Dimensions.font20 / 1.5,
                      family: 'Poppins',
                      weight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
