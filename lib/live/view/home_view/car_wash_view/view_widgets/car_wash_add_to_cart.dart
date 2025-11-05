import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

class CarWashAddToCart extends StatelessWidget {
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height45 * 1.4,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isActive && !isLoading ? onAddToCart : null,
              child: Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: Colors.white, width: 3),
                  color: isActive && !isLoading
                      ? LiveColors.accent.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
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
                          weight: FontWeight.w400,
                          color: isActive ? Colors.black : Colors.grey,
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: hasSelection ? onClearSelection : null,
              child: Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: Colors.white, width: 3),
                  color: hasSelection
                      ? LiveColors.accent.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1),
                ),
                child: Center(
                  child: HeadingStyleText(
                    text: 'Clear Selection',
                    size: Dimensions.font20 / 1.5,
                    family: 'Poppins',
                    weight: FontWeight.w400,
                    color: hasSelection ? Colors.black : Colors.grey,
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
