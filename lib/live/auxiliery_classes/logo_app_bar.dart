import 'package:flutter/material.dart';

import '../widgets/icons/back_arrow.dart';
import '../widgets/text_widgets/heading_style_text.dart';
import '../widgets/text_widgets/primary_style_text.dart';

class LogoAppBar extends StatelessWidget {
  final Color? textColor;
  final Color? backgroundColor;
  final double? elevation;
  final String? imagePath;
  const LogoAppBar({
    super.key,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.elevation = 2.0,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation!,
      shadowColor: Colors.black54,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(left: 26.0, top: 16.0, bottom: 14.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BackArrow(
                iconColor: textColor,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              top: 0,
              child: Image.asset(
                imagePath!, // Image path from item list
                width: 120.0,
                height: 120.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
