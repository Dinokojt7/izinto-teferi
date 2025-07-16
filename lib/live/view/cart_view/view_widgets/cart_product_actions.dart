import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
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
  const CartProductActions({
    super.key,
    this.hasReachedLimit = false,
    this.isRemoved = false,
    required this.quantity,
    required this.index,
    required this.productName,
    required this.viewContext,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (_cartController) {
      final cartActionsController =
          Provider.of<CartActionsController>(context, listen: false);

      final List _cartList = _cartController.getItems;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              if (_cartList[index].quantity == 1) {
                cartActionsController.clearCartData(
                    context,
                    'Remove ${productName} from cart?',
                    'Remove',
                    false,
                    index,
                    _cartList[index].specialty!);
              } else {
                _cartController.addItem(_cartList[index].specialty!, -1);
              }
            },
            child: ActionButton(icon: Icons.remove),
          ),
          Text(
            quantity.toString(),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                fontSize: Dimensions.font16),
          ),
          GestureDetector(
              onTap: () {
                _cartController.addItem(_cartList[index].specialty!, 1);
              },
              child: ActionButton(icon: Icons.add)),
        ],
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
