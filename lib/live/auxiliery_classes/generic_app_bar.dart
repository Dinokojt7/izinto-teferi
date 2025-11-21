import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';
import '../widgets/icons/back_arrow.dart';
import '../widgets/text_widgets/heading_style_text.dart';

class GenericAppBar extends StatelessWidget {
  final String? heading;
  final Color? textColor;
  final Color? backgroundColor;
  final double? elevation;
  final String? imagePath;
  final bool? removeLeading;
  final bool hasMissingProfileData;
  final BuildContext? scaffoldContext;
  final VoidCallback? onTap;
  const GenericAppBar({
    super.key,
    this.heading,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.elevation = 2.0,
    this.imagePath,
    this.removeLeading = false,
    this.hasMissingProfileData = false,
    this.scaffoldContext,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation!,
      shadowColor: Colors.black54,
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.only(
            left: removeLeading! ? 30.0 : 20.0, top: 16.0, bottom: 14.0),
        child: removeLeading!
            ? Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: HeadingStyleText(
                      family: 'Poppins',
                      text: heading!,
                      color: textColor,
                      weight: FontWeight.w600,
                    ),
                  )
                ],
              )
            : Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BackArrow(
                      iconColor: textColor,
                      onTap: onTap ??
                          () {
                            Navigator.of(context).pop();
                          },
                    ),
                  ),
                  SizedBox(
                    width: Dimensions.width10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: HeadingStyleText(
                      family: 'Poppins',
                      text: heading!,
                      color: textColor,
                      weight: FontWeight.w600,
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
