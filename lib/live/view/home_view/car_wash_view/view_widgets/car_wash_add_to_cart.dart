import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

class CarWashAddToCart extends StatelessWidget {
  final dynamic itemCount;
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
      height: Dimensions.height45 * 1.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Enhanced Add to Cart Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _triggerHapticFeedback(
                    HapticType.medium); // Choose feedback type
                onAddToCart();
              },
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              splashColor: LiveColors.accent.withOpacity(0.3),
              highlightColor: LiveColors.accent.withOpacity(0.1),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      spreadRadius: 1,
                      offset: Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // Bucket with Item Count
          GestureDetector(
            onTap: hasSelection ? onClearSelection : null,
            child: Stack(
              children: [
                Image.asset(
                  'assets/icons/bucket.png',
                  width: 40.0,
                  height: 40.0,
                ),
                if (itemCount > 0)
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: HeadingStyleText(
                          size: Dimensions.font20 / 1.1,
                          color: Colors.white,
                          text: '${itemCount}',
                          family: 'Poppins',
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _triggerHapticFeedback([HapticType type = HapticType.light]) {
    try {
      switch (type) {
        case HapticType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          HapticFeedback.selectionClick();
          break;
      }
    } catch (e) {
      print('Haptic feedback not available: $e');
    }
  }
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
}
