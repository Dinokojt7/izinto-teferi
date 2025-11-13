import 'package:flutter/material.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/top_nortch.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/buttons/save_button.dart';

// Update PaymentMethodSelector to properly show wallet balance:

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutViewController>(
      builder: (context, controller, child) {
        final hasWalletBalance = controller.availableWalletBalance > 0;

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width30,
            vertical: Dimensions.width15,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              TopNotch(color: Colors.black.withOpacity(0.1)),
              SizedBox(height: Dimensions.height20),
              HeadingStyleText(
                text: 'Select Payment Method',
                weight: FontWeight.w600,
                size: Dimensions.font26 / 1.2,
                align: TextAlign.center,
              ),
              SizedBox(height: Dimensions.height20),
              Divider(color: Colors.black26, height: 20),
              SizedBox(height: Dimensions.height20),

              // Wallet Balance Button - FIXED
              if (hasWalletBalance)
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.toggleWalletUsage();
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: Dimensions.height15),
                        padding: EdgeInsets.all(Dimensions.width15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15),
                          border: Border.all(
                            color: controller.isWalletApplied
                                ? Colors.black
                                : Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HeadingStyleText(
                                  text: 'Wallet',
                                  weight: FontWeight.w600,
                                  size: Dimensions.font20 / 1.2,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${controller.isWalletApplied && controller.walletDiscount > 0 ? 'Applied Discount' : 'Available'}: R${controller.availableWalletBalance},00',
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 / 1.2,
                                    color: controller.isWalletApplied &&
                                            controller.walletDiscount > 0
                                        ? Colors.green
                                        : Colors.grey.shade600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width10,
                                vertical: Dimensions.height10 / 2,
                              ),
                              decoration: BoxDecoration(
                                color: controller.isWalletApplied
                                    ? Colors.black
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                controller.isWalletApplied ? 'ON' : 'OFF',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 / 1.3,
                                  color: controller.isWalletApplied
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 / 2),
                  ],
                ),
              // In PaymentMethodSelector, add this to the wallet section:
              if (controller.isWalletCoveringFullAmount)
                Padding(
                  padding: EdgeInsets.only(bottom: Dimensions.height10),
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.width10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            'Wallet covers full amount - no additional payment needed',
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.2,
                              color: Colors.green,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: Dimensions.height10 / 2),

              Expanded(
                child: ListView.builder(
                  itemCount: controller.paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = controller.paymentMethods[index];
                    final isSelected =
                        controller.selectedPaymentMethod == method['type'];
                    final isCashMethod = method['type'] == 'cash';
                    final isDisabled = !isCashMethod;

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () =>
                              controller.selectPaymentMethod(method['type']),
                      child: Opacity(
                        opacity: isDisabled ? 0.5 : 1.0,
                        child: Container(
                          margin: EdgeInsets.only(bottom: Dimensions.height15),
                          padding: EdgeInsets.all(Dimensions.width15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius15),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Image.asset(
                                  method['image'],
                                  fit: BoxFit.contain,
                                  color: isDisabled ? Colors.grey : null,
                                ),
                              ),
                              SizedBox(width: Dimensions.width15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HeadingStyleText(
                                      text: method['name'],
                                      weight: FontWeight.w600,
                                      size: Dimensions.font20 / 1.2,
                                      color: isDisabled
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      method['description'],
                                      style: TextStyle(
                                        fontSize: Dimensions.font16 / 1.2,
                                        color: isDisabled
                                            ? Colors.grey
                                            : Colors.grey.shade600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    if (isDisabled) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        'Temporarily unavailable',
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 / 1.3,
                                          color: Colors.orange,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isDisabled)
                                Icon(Icons.lock_outline,
                                    color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: Dimensions.height20),
              SaveButton(
                isActive: controller.selectedPaymentMethod.isNotEmpty,
                description: 'Confirm Payment Method',
                isAuthScreen: false,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: Dimensions.height20),
            ],
          ),
        );
      },
    );
  }
}
