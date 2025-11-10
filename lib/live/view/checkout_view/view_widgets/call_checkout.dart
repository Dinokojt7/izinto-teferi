import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/utilities/generic_snackbar.dart';
import 'package:izinto/live/view/checkout_view/checkout_page.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/buttons/cart_action_button.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/text_widgets/introduction_text.dart';

class CallCheckout extends StatelessWidget {
  final int totalCartAmount;
  final VoidCallback onTap;
  const CallCheckout({
    super.key,
    required this.totalCartAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMinimumMet = totalCartAmount >= 150;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 2.0),
          child: Container(
            color: Colors.transparent,
            child: GenericHeaderRow(
              headingChild: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: IntroductionText(
                    text: 'R${totalCartAmount.toString()},00*'),
              ),
              actionButtonChild: CartActionButton(
                isCartCheckoutButton: true,
                backgroundColor: isMinimumMet
                    ? LiveColors.cartBlue
                    : LiveColors.standardBlue.withOpacity(0.05),
                isActive: isMinimumMet,
                description: 'Checkout',
                onTap: isMinimumMet
                    ? onTap
                    : () {
                        GenericSnackBar().showCustomSnackBar(null, context,
                            'Basket total must be at least R150.00', false);
                      },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
