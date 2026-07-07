import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

/// Reserved strictly for delete / remove / logout — the only place the red
/// CTA color should appear in the redesigned screens.
class DestructiveButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool filled;
  const DestructiveButton({
    Key? key,
    required this.text,
    this.icon,
    this.onTap,
    this.filled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: Dimensions.bottomHeightBar / 2.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          color: filled ? LiveColors.standardRed : LiveColors.standardRed.withOpacity(0.08),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: filled ? Colors.white : LiveColors.standardRed),
              SizedBox(width: Dimensions.width10),
            ],
            HeadingStyleText(
              size: Dimensions.font16,
              color: filled ? Colors.white : LiveColors.standardRed,
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
