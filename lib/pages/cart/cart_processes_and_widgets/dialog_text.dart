import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../../utils/colors.dart';
import '../../../widgets/texts/integers_and_doubles.dart';

class dialogText extends StatelessWidget {
  const dialogText({
    super.key,
    required this.text,
    this.weight = FontWeight.w500,
    this.color = Colors.black87,
    required this.size,
  });
  final String text;
  final FontWeight? weight;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IntegerText(
      align: TextAlign.center,
      maxLines: 10,
      overFlow: TextOverflow.ellipsis,
      text: text,
      color: color,
      fontWeight: weight,
      size: size,
    );
  }
}

class dialogLocalButton extends StatelessWidget {
  const dialogLocalButton({
    super.key,
    required this.text,
    required this.callAction,
    required this.color,
    this.index,
  });

  final String text;
  final int callAction;
  final Color color;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenHeight / 15.5,
      width: Dimensions.screenWidth / 1.5,
      // width: Dimensions.screenWidth / 2.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            callAction == 1 ? AppColors.six : Colors.grey.withOpacity(0.1),
            callAction == 1
                ? Color(0xff9A9483)
                : Colors.black12.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(Dimensions.radius20 * 3),
        ),
      ),

      child: Center(
        child: IntegerText(
          text: text,
          size: Dimensions.font16 / 1.1,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
