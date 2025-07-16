import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';

class PaymentRoute extends StatelessWidget {
  const PaymentRoute({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.height20 * 4.5,
      height: Dimensions.height20 * 4.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radius30),
            topRight: Radius.circular(Dimensions.radius30)),
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card,
              color: AppColors.fontColor,
              size: Dimensions.iconSize26 * 1.2,
            ),
            SizedBox(
              height: Dimensions.height10,
            ),
            Text(
              'Checkout',
              style: TextStyle(
                  fontSize: Dimensions.font16 / 1.4,
                  fontFamily: 'Poppins',
                  color: AppColors.fontColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
