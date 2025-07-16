import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';
import '../texts/big_text.dart';
import '../texts/integers_and_doubles.dart';

class CartCheckoutButton extends StatelessWidget {
  const CartCheckoutButton({
    Key? key,
    required this.totalOrderAmount,
    required this.isProcessing,
    required this.isApplyDiscount,
    required this.isApplyCarWashSubscription,
    required this.totalCarWashDiscount,
    required this.totalDiscount,
  }) : super(key: key);

  final int? totalOrderAmount;
  final bool isProcessing;
  final bool isApplyDiscount;
  final bool isApplyCarWashSubscription;
  final int totalCarWashDiscount;
  final int totalDiscount;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Dimensions.bottomHeightBar / 1.52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xffA0937D),
              Color(0xff966C3B),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(right: Dimensions.screenWidth / 10),
          child: Row(
            mainAxisAlignment: totalOrderAmount == 0
                ? MainAxisAlignment.center
                : isProcessing
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.end,
            children: [
              isProcessing
                  ? Transform.scale(
                      scale: 0.5,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    )
                  : IntegerText(
                      size: Dimensions.font26 / 1.2,
                      text: isApplyDiscount && isApplyCarWashSubscription
                          ? 'R ${totalOrderAmount! - (totalCarWashDiscount + totalDiscount)} . 00 | Checkout'
                          : isApplyCarWashSubscription
                              ? 'R ${totalOrderAmount! - totalCarWashDiscount} . 00 | Checkout'
                              : isApplyDiscount
                                  ? 'R ${totalOrderAmount! - totalDiscount} . 00 | Checkout '
                                  : totalOrderAmount == 0
                                      ? 'Checkout'
                                      : 'R $totalOrderAmount.00 | Checkout ',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
            ],
          ),
        ));
  }
}
