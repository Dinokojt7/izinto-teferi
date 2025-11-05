import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../utils/dimensions.dart';
import '../../../../utilities/colors.dart';
import '../../../../widgets/buttons/cart_action_button.dart';
import '../../../../widgets/generic_header_row.dart';

class SpecialtyBottomCheckoutNav extends StatelessWidget {
  final int totalAmount;
  final VoidCallback onCheckout;
  final bool isActive;

  const SpecialtyBottomCheckoutNav({
    super.key,
    required this.totalAmount,
    required this.onCheckout,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radius30 * 1.6),
          topRight: Radius.circular(Dimensions.radius30 * 1.6),
        ),
      ),
      height: Dimensions.bottomHeightBar / 1.3,
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20, vertical: Dimensions.height20 / 1.1),
      child: GenericHeaderRow(
        headingChild: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Charges',
              maxLines: 2,
              style: TextStyle(
                height: 1.2,
                overflow: TextOverflow.ellipsis,
                fontSize: Dimensions.font16 / 1.3,
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.height10 / 2),
            Text(
              'R$totalAmount,00*',
              maxLines: 2,
              style: TextStyle(
                height: 1.2,
                overflow: TextOverflow.ellipsis,
                fontSize: Dimensions.font16 / 1.2,
                fontFamily: 'Poppins',
                color: LiveColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actionButtonChild: CartActionButton(
          backgroundColor:
              isActive ? LiveColors.accent.withOpacity(0.2) : Colors.grey,
          isActive: isActive,
          description: 'Checkout',
          onTap: onCheckout,
        ),
      ),
    );
  }
}
