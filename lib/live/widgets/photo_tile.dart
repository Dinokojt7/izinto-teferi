import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

/// Photo-led service tile for the Home bento grid — real asset image with a
/// gradient scrim and title/subtitle, replacing the design mockup's striped
/// placeholder now that real production art exists for every service.
class PhotoTile extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String? badge;
  final double titleSize;
  final bool leftGradient;
  final VoidCallback? onTap;

  const PhotoTile({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.badge,
    this.titleSize = 15,
    this.leftGradient = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradient = leftGradient
        ? LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              LiveColors.primary.withOpacity(0.88),
              LiveColors.primary.withOpacity(0.12),
            ],
          )
        : LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              LiveColors.primary.withOpacity(0.85),
              LiveColors.primary.withOpacity(0.03),
            ],
            stops: const [0.0, 0.62],
          );

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
            if (badge != null)
              Positioned(
                top: 12,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: LiveColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: HeadingStyleText(
                    text: badge!,
                    size: 8,
                    weight: FontWeight.w600,
                    color: LiveColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeadingStyleText(
                    text: title,
                    size: titleSize,
                    weight: FontWeight.w600,
                    color: LiveColors.whiteTextColor,
                  ),
                  const SizedBox(height: 2),
                  HeadingStyleText(
                    text: subtitle,
                    size: 10.5,
                    weight: FontWeight.w400,
                    color: LiveColors.whiteTextColor.withOpacity(0.82),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
