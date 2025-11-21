import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';

import '../../../../../controllers/new_cart_controller.dart';
import '../../../../../utils/dimensions.dart';
import '../../../../../widgets/miscellaneous/app_icon.dart';

class AddVehicle extends StatefulWidget {
  final List? specialtyList;
  final int? index;
  final BuildContext? viewContext;
  final IconData icon;
  final bool isValid;
  final VoidCallback? onTap;
  final String? vehicleType;
  final String? imageString;

  const AddVehicle({
    Key? key,
    this.specialtyList,
    this.index,
    this.viewContext,
    required this.icon,
    required this.isValid,
    this.onTap,
    this.vehicleType,
    this.imageString,
  }) : super(key: key);

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  bool _isTapped = false;
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarWashController>(
      builder: (carWashController) {
        return GetBuilder<NewCartController>(builder: (_cartController) {
          var specialty = widget.specialtyList![widget.index!];
          var _quantity = _cartController.getQuantity(specialty);

          // Use the new method to get quantity - this will auto-update when controller updates
          final displayQuantity =
              carWashController.getVehicleQuantity(widget.vehicleType!);
          final isInCart = displayQuantity > 0;

          // Reset state if item is no longer in cart
          if (!isInCart && _isReady) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _isReady = false;
                _isTapped = false;
              });
            });
          }

          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: _isTapped && _isReady ? 100 : 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius15 / 1.1),
              color: Colors.black,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isTapped = true;
                  Future.delayed(Duration(milliseconds: 500), () {
                    setState(() {
                      _isReady = true;
                    });
                  });
                });
                carWashController.addCar(
                    widget.vehicleType!, widget.imageString!);
              },
              child: _isTapped && _isReady && isInCart
                  ? AddVehicleControllers(
                      onTap: () {
                        if (displayQuantity == 1) {
                          // Show remove confirmation dialog
                          _showRemoveDialog(context, widget.vehicleType!,
                              specialty, carWashController);
                        } else {
                          carWashController.removeItem(specialty);
                        }
                      },
                      quantity: displayQuantity,
                    )
                  : AppIcon(
                      weight: 5,
                      size: Dimensions.width30 * 1.1,
                      iconSize: Dimensions.iconSize24 / 1.4,
                      backgroundColor: Colors.transparent,
                      iconColor: Colors.white,
                      icon: widget.icon,
                    ),
            ),
          );
        });
      },
    );
  }

  void _showRemoveDialog(BuildContext context, String vehicleType,
      dynamic specialty, CarWashController carWashController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Vehicle'),
        content: Text('Remove $vehicleType from selection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Remove item and reset state
              carWashController.removeItem(specialty);
              setState(() {
                _isReady = false;
                _isTapped = false;
              });
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddVehicleControllers extends StatelessWidget {
  final VoidCallback onTap;
  final int quantity;

  const AddVehicleControllers({
    super.key,
    required this.onTap,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 28,
            height: 28,
            child: Icon(Icons.remove, color: Colors.white, size: 16),
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
        Container(
          width: 28,
          height: 28,
          child: Icon(Icons.add, color: Colors.white, size: 16),
        ),
      ],
    );
  }
}
