import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';

class CashPay extends StatelessWidget {
  const CashPay({
    Key? key,
    required this.paymentMethod,
    required this.price,
  }) : super(key: key);

  final String? paymentMethod;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenWidth / 3.9,
      width: Dimensions.screenWidth / 3.4,
      padding: EdgeInsets.only(
          left: Dimensions.screenWidth / 30,
          right: Dimensions.screenWidth / 25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: paymentMethod == "Cash"
            ? Border.all(width: 1.5, color: const Color(0xFFB09B71))
            : Border.all(
                width: 1,
                color: Color(0xff9A9484).withOpacity(0.4),
              ),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.5,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.payments,
              size: Dimensions.height10 * 3,
              color: paymentMethod == "Cash"
                  ? const Color(0xFFB09B71)
                  : Colors.grey.withOpacity(0.5),
            ),
            Text(
              price,
              style: TextStyle(
                  fontSize: Dimensions.font16 / 0.9,
                  fontFamily: 'Poppins',
                  color: paymentMethod == "Cash"
                      ? const Color(0xFFB09B71)
                      : Colors.grey.withOpacity(0.5),
                  fontWeight: FontWeight.w600),
            ),
            Text(
              'Cash Payment',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font16 / 1.2,
                fontFamily: 'Hind',
                color: paymentMethod == "Cash"
                    ? const Color(0xFFB09B71)
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
