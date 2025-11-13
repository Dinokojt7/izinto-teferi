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
      height: Dimensions.height45 * 1.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onAddToCart,
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                color: Colors.black,
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              child: Center(
                child: Text(
                  '+',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font20,
                      fontFamily: 'Poppins'),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: hasSelection ? onClearSelection : null,
            child: Stack(
              children: [
                Image.asset(
                  'assets/icons/bucket.png',
                  width: 40.0,
                  height: 40.0,
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: HeadingStyleText(
                        size: Dimensions.font20 / 1.1,
                        color: Colors.white,
                        text: itemCount,
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
}
