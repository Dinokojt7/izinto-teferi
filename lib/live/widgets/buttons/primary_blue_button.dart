import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

/// Full-width primary CTA — solid deep-blue background, white text. This is
/// the same visual spec as the existing car-wash CTAButton, generalized for
/// reuse across the redesigned screens instead of the red CTA color.
class PrimaryBlueButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  const PrimaryBlueButton({
    Key? key,
    required this.text,
    this.icon,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: Dimensions.bottomHeightBar / 2.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          color: LiveColors.cartBlue,
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularCappedProgressIndicator(
                    color: Colors.white70,
                    strokeWidth: 3.0,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: Colors.white),
                    SizedBox(width: Dimensions.width10),
                  ],
                  HeadingStyleText(
                    size: Dimensions.font16,
                    color: Colors.white,
                    text: text,
                    family: 'Poppins',
                    weight: FontWeight.w500,
                  ),
                ],
              ),
      ),
    );
  }
}
