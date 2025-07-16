import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';
import '../texts/big_text.dart';

class SuccessToOrderButton extends StatelessWidget {
  const SuccessToOrderButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: Dimensions.height18,
          bottom: Dimensions.height15,
          left: Dimensions.width20,
          right: Dimensions.width20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radius20 * 2),
          topRight: Radius.circular(Dimensions.radius20 * 2),
        ),
      ),
      child: Container(
        height: Dimensions.screenHeight / 16,
        width: Dimensions.width30 * 12,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xffCFC5A5),
              Color(0xff9A9483),
            ],
          ),

          borderRadius: BorderRadius.all(
            Radius.circular(Dimensions.radius20 * 3),
          ),
          // color: const Color(0xff8d7053),
        ),
        child: Center(
          child: BigText(
            text: 'Track Order',
            size: Dimensions.font16,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
