import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:provider/provider.dart';

import '../../../../../controllers/cart_controller.dart';
import '../../../../../models/popular_specialty_model.dart';
import '../../../../../utils/dimensions.dart';
import '../../../cart_view/controller/cart_actions_controller.dart';
import '../../../cart_view/view_widgets/cart_product_actions.dart';

class AddToBasket extends StatelessWidget {
  final List? specialtyList;
  final int? index;
  final BuildContext? viewContext;
  const AddToBasket(
      {Key? key, this.specialtyList, this.index, this.viewContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (_cartController) {
      var specialty = specialtyList![index!];
      var _quantity = _cartController.getQuantity(specialty);
      var _isInCart = _quantity > 0;
      var _productName = specialty.name;
      final cartActionsController =
          Provider.of<CartActionsController>(context, listen: false);
      return Stack(
        children: [
          AnimatedContainer(
            duration: Duration(seconds: 2),
            width: _isInCart ? 90 : 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              color: Colors.black,
              border: Border.all(
                color: Colors.black,
              ),
            ),
            child: _isInCart
                ? null
                : Text(
                    '+',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Dimensions.font20,
                        fontFamily: 'Poppins'),
                  ),
          ),
          _isInCart
              ? AnimatedContainer(
                  duration: Duration(seconds: 2),
                  width: 90,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    color: Colors.black,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (_quantity == 1) {
                            cartActionsController.clearCartData(
                                viewContext,
                                'Remove ${_productName} from cart?',
                                'Remove',
                                false,
                                index,
                                specialty);
                          } else {
                            _cartController.addItem(specialty, -1);
                          }
                        },
                        child: ActionButton(icon: Icons.remove),
                      ),
                      Text(
                        _quantity.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font16),
                      ),
                      GestureDetector(
                          onTap: () {
                            _cartController.addItem(specialty, 1);
                          },
                          child: ActionButton(icon: Icons.add)),
                    ],
                  ),
                )
              : Container()
        ],
      );
    });
  }
}

class CartControllerWidget extends StatelessWidget {
  final int quantity;
  const CartControllerWidget({Key? key, required this.quantity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            if (quantity == 1) {
              //   cartActionsController.clearCartData(
              //       viewContext,
              //       'Remove ${_productName} from cart?',
              //       'Remove',
              //       false,
              //       index,
              //       specialty);
            } else {
              //    _cartController.addItem(specialty, -1);
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
              //    _cartController.addItem(specialty, 1);
            },
            child: ActionButton(icon: Icons.add)),
      ],
    );
  }
}
