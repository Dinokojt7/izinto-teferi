import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:provider/provider.dart';

import '../../../../../controllers/cart_controller.dart';
import '../../../../../models/popular_specialty_model.dart';
import '../../../../../utils/dimensions.dart';
import '../../../../../widgets/miscellaneous/app_icon.dart';
import '../../../cart_view/controller/cart_actions_controller.dart';
import '../../../cart_view/view_widgets/cart_product_actions.dart';

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
    return Consumer<CarWashController>(
        builder: (context, _carWashController, child) {
      return GetBuilder<CartController>(builder: (_cartController) {
        var specialty = widget.specialtyList![widget.index!];
        var _quantity = _cartController.getQuantity(specialty);
        var widen = _quantity > 0;
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
              //_cartController.addItem(specialty, 1);
              _carWashController.addCar(
                  widget.vehicleType!, widget.imageString!);
            },
            child: _isTapped && _isReady
                ? AddVehicleControllers(
                    onTap: () {
                      _carWashController.removeItem(specialty);
                      _cartController.getQuantity(specialty) == 0
                          ? setState(() {
                              _isReady = false;
                              _isTapped = false;
                              Future.delayed(Duration(milliseconds: 500), () {
                                setState(() {
                                  _isTapped = false;
                                });
                              });
                            })
                          : null;
                    },
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
    });
  }
}

class AddVehicleControllers extends StatelessWidget {
  final VoidCallback onTap;
  const AddVehicleControllers({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CarWashController>(
        builder: (context, _carWashController, child) {
      final _itemIndex = _carWashController.selectVehicleIndex;
      final _quantity = _carWashController.includedVehicles;
      return GetBuilder<CartController>(builder: (_cartController) {
        final includedVehicles = _carWashController.includedVehicles;
        final _displayQuantity = _carWashController.updateQuantityDisplayed();
        final quantity = includedVehicles.length > 0
            ? includedVehicles[0]['selectionQuantity']
            : 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onTap,
              child: AppIcon(
                weight: 5,
                size: Dimensions.width30 * 1.1,
                iconSize: Dimensions.iconSize24 / 1.4,
                backgroundColor: Colors.transparent,
                iconColor: Colors.white,
                icon: Icons.remove,
              ),
            ),
            Text(
              quantity.toString(),
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
            AppIcon(
              weight: 5,
              size: Dimensions.width30 * 1.1,
              iconSize: Dimensions.iconSize24 / 1.4,
              backgroundColor: Colors.transparent,
              iconColor: Colors.white,
              icon: Icons.add,
            ),
          ],
        );
      });
    });
  }
}
