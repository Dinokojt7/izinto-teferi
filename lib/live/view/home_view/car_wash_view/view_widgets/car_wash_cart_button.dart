import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/dimensions.dart';
import '../controller/car_wash_controller.dart';

class CarWashCartButton extends StatelessWidget {
  final int itemId;
  final int initialQuantity;

  const CarWashCartButton({
    Key? key,
    required this.itemId,
    required this.initialQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final carWashController = Get.find<CarWashController>();

    return GetBuilder<CarWashController>(
      builder: (controller) {
        final item = controller.carWashCartItems.firstWhere(
          (item) => item['id'] == itemId,
          orElse: () => {'quantity': 0},
        );

        final quantity = item['quantity'] ?? 0;
        final isInCart = quantity > 0;

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: isInCart ? 96 : 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            color: Colors.black,
          ),
          child: isInCart
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity == 1) {
                          // Show remove confirmation
                          _showRemoveDialog(context, itemId, item['name']);
                        } else {
                          carWashController.updateCarWashQuantity(
                              itemId, quantity - 1);
                        }
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        child:
                            Icon(Icons.remove, color: Colors.white, size: 16),
                      ),
                    ),
                    Text(
                      quantity.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        carWashController.updateCarWashQuantity(
                            itemId, quantity + 1);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        child: Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font20,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _showRemoveDialog(BuildContext context, int itemId, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Item'),
        content: Text('Remove $itemName from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.find<CarWashController>().removeCarWashItem(itemId);
              Navigator.of(context).pop();
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
