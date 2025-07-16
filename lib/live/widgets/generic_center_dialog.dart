import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

import '../../utils/dimensions.dart';
import 'buttons/save_button.dart';

class GenericCenterDialog extends StatelessWidget {
  final String emoji;
  final String heading;
  final String description;
  final String buttonText;
  final VoidCallback callBack;
  const GenericCenterDialog({
    super.key,
    required this.emoji,
    required this.heading,
    required this.description,
    required this.buttonText,
    required this.callBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20 * 1.1),
        child: Container(
          height: Dimensions.screenHeight / 2.8,
          width: Dimensions.screenWidth,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.1), // Slightly more opaque shadow color
                spreadRadius: 1, // Spread the shadow more evenly
                blurRadius: 0.7, // Increase blur for a smoother shadow
                offset:
                    Offset(0, 1.7), // Offset downward to remove the top shadow
              ),
            ],
            border: Border.all(
              width: 0.5,
              color: Colors.black.withOpacity(0.04),
            ),
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width30 * 1.2,
                vertical: Dimensions.height20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: TextStyle(fontSize: Dimensions.font26),
                ),
                HeadingStyleText(
                  text: heading,
                  weight: FontWeight.w600,
                  size: Dimensions.font26 / 1.2,
                ),
                HeadingStyleText(
                  text: description,
                  size: Dimensions.font20 / 1.3,
                  family: 'Poppins',
                  weight: FontWeight.w300,
                  align: TextAlign.center,
                ),
                SaveButton(
                  isActive: true,
                  description: buttonText,
                  isAuthScreen: false,
                  onTap: callBack!,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
