import 'package:flutter/material.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';

import '../../utils/dimensions.dart';
import '../texts/big_text.dart';

class PaymentCheckoutButton extends StatelessWidget {
  const PaymentCheckoutButton({
    Key? key,
    required this.instructionsController,
    required this.paymentMethod,
    required this.totalOrderAmount,
    required this.isLoading,
  }) : super(key: key);

  final TextEditingController instructionsController;
  final String? paymentMethod;
  final String totalOrderAmount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Dimensions.bottomHeightBar / 1.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              (!instructionsController.text.isEmpty || paymentMethod == '')
                  ? Colors.black12
                  : Color(0xff9A9483),
              (!instructionsController.text.isEmpty || paymentMethod == '')
                  ? Colors.black12
                  : Color(0xffCFC5A5),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radius20 * 2),
            topRight: Radius.circular(Dimensions.radius20 * 2),
          ),
        ),
        child: isLoading
            ? Transform.scale(
                scale: 0.5,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(right: Dimensions.screenWidth / 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IntegerText(
                      overFlow: TextOverflow.ellipsis,
                      size: Dimensions.font26 / 1.2,
                      text: 'R ' + totalOrderAmount + '.00 | CHECKOUT',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )
                  ],
                ),
              ));
  }
}

// 'R ' +
// $totalOrderAmount  +
// '.00 '
