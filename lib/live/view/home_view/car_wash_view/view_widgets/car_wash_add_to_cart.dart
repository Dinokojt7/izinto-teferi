import 'package:flutter/material.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../utilities/colors.dart';
import '../../../../widgets/text_widgets/heading_style_text.dart';

class CarWashAddToCart extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onClearSelection;
  final bool hasSelection;

  const CarWashAddToCart({
    Key? key,
    required this.onAddToCart,
    required this.onClearSelection,
    required this.hasSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height45 * 1.4,
      width: double.maxFinite,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onAddToCart,
              child: Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: Colors.white, width: 3),
                  color: hasSelection
                      ? LiveColors.accent.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                ),
                child: Center(
                  child: HeadingStyleText(
                    text: 'Add to Cart',
                    size: Dimensions.font20 / 1.5,
                    family: 'Poppins',
                    weight: FontWeight.w400,
                    color: hasSelection ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onClearSelection,
              child: Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: Colors.white, width: 3),
                  color: LiveColors.accent.withOpacity(0.05),
                ),
                child: Center(
                  child: HeadingStyleText(
                    text: 'Clear Selection',
                    size: Dimensions.font20 / 1.5,
                    family: 'Poppins',
                    weight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
