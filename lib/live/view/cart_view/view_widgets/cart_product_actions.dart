import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/miscellaneous/app_icon.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../../home_view/category_view/controller/category_view_controller.dart';
import '../controller/cart_actions_controller.dart';

class CartProductActions extends StatelessWidget {
  final int index;
  final int quantity;
  final String productName;
  final bool? hasReachedLimit;
  final bool? isRemoved;
  final BuildContext viewContext;
  final dynamic specialty; // Change from cartItem to specialty

  const CartProductActions({
    super.key,
    this.hasReachedLimit = false,
    this.isRemoved = false,
    required this.quantity,
    required this.index,
    required this.productName,
    required this.viewContext,
    required this.specialty, // Now accepts specialty directly
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewCartController>(builder: (_cartController) {
      final cartActionsController =
          Provider.of<CartActionsController>(context, listen: false);

      return Container(
        width: 95,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          color: Colors.black,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remove item from cart
            GestureDetector(
              onTap: () async {
                if (quantity == 1) {
                  cartActionsController.clearCartData(
                      context,
                      'Remove $productName from cart?',
                      'Remove',
                      false,
                      index,
                      specialty); // Pass specialty directly
                } else {
                  _cartController.addItem(
                      specialty, -1); // Pass specialty directly
                }
              },
              child: ActionButton(
                icon: Icons.remove,
              ),
            ),

            // Cart Item count
            Text(
              quantity.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font16),
            ),

            // Add item to cart
            GestureDetector(
                onTap: () {
                  _cartController.addItem(
                      specialty, 1); // Pass specialty directly
                },
                child: ActionButton(icon: Icons.add)),
          ],
        ),
      );
    });
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  const ActionButton({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppIcon(
      weight: 5,
      size: Dimensions.width30 * 1.1,
      iconSize: Dimensions.iconSize24 / 1.4,
      backgroundColor: Colors.transparent,
      iconColor: Colors.white,
      icon: icon,
    );
  }
}
