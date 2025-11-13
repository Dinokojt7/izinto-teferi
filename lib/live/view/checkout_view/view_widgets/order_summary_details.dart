import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../controller/checkout_view_controller.dart';

class OrderSummaryDetails extends StatelessWidget {
  const OrderSummaryDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutViewController>(
      builder: (context, checkout, child) {
        // This will automatically rebuild when checkout notifies listeners
        int subtotal = checkout.orderSubtotal;
        int serviceFee = checkout.serviceFee;
        int riderTip = checkout.optionalTip;
        int promoDiscount = checkout.promoDiscount;
        int walletDiscount = checkout.walletDiscount;
        int total = checkout.orderTotal;

        return Column(
          children: [
            LineItems(
              itemName: 'Subtotal',
              updatedAmount: subtotal,
              isTotal: false,
              isDeliveryItems: false,
            ),
            SizedBox(height: Dimensions.height15 * 1.1),

            LineItems(
              itemName: 'Transport fee',
              updatedAmount: serviceFee,
              isTotal: false,
              isDeliveryItems: true,
            ),
            SizedBox(height: Dimensions.height15 * 1.1),

            LineItems(
              itemName: 'Tip (optional)',
              updatedAmount: riderTip,
              isTotal: false,
              isDeliveryItems: false,
            ),
            SizedBox(height: Dimensions.height15 * 1.1),
            // ... include promo and wallet discount lines
            if (checkout.isPromoCodeValid && promoDiscount > 0)
              Column(
                children: [
                  LineItems(
                    itemName: 'Promo Code Discount',
                    updatedAmount: -promoDiscount,
                    isTotal: false,
                    isDeliveryItems: false,
                    isDiscount: true,
                  ),
                  SizedBox(height: Dimensions.height15 * 1.1),
                ],
              ),
            if (checkout.isWalletApplied && walletDiscount > 0)
              Column(
                children: [
                  LineItems(
                    itemName: 'Wallet Balance Used',
                    updatedAmount: -walletDiscount,
                    isTotal: false,
                    isDeliveryItems: false,
                    isDiscount: true,
                  ),
                  SizedBox(height: Dimensions.height15 * 1.1),
                ],
              ),
            LineItems(
              itemName: 'Total',
              updatedAmount: total,
              isTotal: true,
              isDeliveryItems: false,
            ),
          ],
        );
      },
    );
  }
}

class LineItems extends StatefulWidget {
  final String itemName;
  final bool? isFreeDelivery;
  final int updatedAmount;
  final bool isTotal;
  final bool isDeliveryItems;
  final bool isDiscount;

  LineItems({
    super.key,
    required this.itemName,
    this.isFreeDelivery,
    required this.updatedAmount,
    required this.isTotal,
    required this.isDeliveryItems,
    this.isDiscount = false,
  });

  @override
  State<LineItems> createState() => _LineItemsState();
}

class _LineItemsState extends State<LineItems> {
  @override
  Widget build(BuildContext context) {
    final isNegative = widget.updatedAmount < 0;
    final amountColor = isNegative ? Colors.green : Colors.black;

    return Row(
      children: [
        Expanded(
          child: HeadingStyleText(
            text: widget.itemName,
            size: Dimensions.font20 / 1.3,
            family: 'Poppins',
            weight: widget.isTotal ? FontWeight.w600 : FontWeight.w300,
            color: Colors.black,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.isDeliveryItems
                ? Icon(MdiIcons.giftOutline,
                    color: LiveColors.standardBlue, size: 18.0)
                : Container(),
            SizedBox(width: Dimensions.width10),
            HeadingStyleText(
              isCancelled: widget.isDeliveryItems,
              text: '${isNegative ? '-' : ''}R${widget.updatedAmount.abs()},00',
              size: Dimensions.font20 / 1.25,
              family: 'Poppins',
              weight: widget.isTotal
                  ? FontWeight.w600
                  : isNegative
                      ? FontWeight.w600
                      : FontWeight.w300,
              color: amountColor,
            ),
          ],
        ),
      ],
    );
  }
}
