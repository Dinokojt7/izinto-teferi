import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback onTap;
  const GoogleAuthButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.bottomHeightBar / 2.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.1), // Slightly more opaque shadow color
            spreadRadius: 1, // Spread the shadow more evenly
            blurRadius: 2, // Increase blur for a smoother shadow
            offset: Offset(0, 2.5), // Offset downward to remove the top shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/image/g.png', // Image path from item list
                  width: 35.0,
                  height: 35.0, alignment: Alignment.topCenter,
                ),
                SizedBox(
                  width: Dimensions.width20 / 1.2,
                ),
                HeadingStyleText(
                  size: Dimensions.font16 / 1.1,
                  color: Colors.grey.shade600,
                  text: 'Continue with Google',
                  family: 'Poppins',
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
