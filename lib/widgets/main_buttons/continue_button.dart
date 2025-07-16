import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../texts/big_text.dart';
import '../texts/integers_and_doubles.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    Key? key,
    this.isLoading,
    required this.cto,
  }) : super(key: key);

  final bool? isLoading;
  final String cto;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenHeight / 14,
      width: Dimensions.screenWidth / 2.6,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topRight,
        //   end: Alignment.bottomLeft,
        //   colors: [
        //     Color(0xffCFC5A5),
        //     Color(0xff9A9483),
        //   ],
        // ),
        border: Border.all(
          width: 1,
          color: Colors.black12,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(Dimensions.radius20 * 3),
        ),
        color: Colors.white,
      ),
      child: isLoading!
          ? Transform.scale(
              scale: 0.5,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: AppColors.fontColor,
                ),
              ),
            )
          : Center(
              child: IntegerText(
                text: cto,
                size: Dimensions.font16,
                fontWeight: FontWeight.w600,
                color: AppColors.fontColor.withOpacity(0.8),
              ),
            ),
    );
  }
}
