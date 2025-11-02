import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/models/new_specialty_model.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../models/popular_specialty_model.dart';
import '../../../../widgets/bottom_delete_sheet.dart';
import '../../../widgets/bottom_remove_sheet.dart';

class CartActionsController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSelected = false;
  bool get isSelected => _isSelected;

  //SET ANIMATED CONTAINER
  void setAnimatedContainer(bool) {
    _isSelected = true;
    notifyListeners();
  }

  // CLEAR CART
  void clearCartData(context, String headerText, String action,
      bool isClearAllCached, int? index, NewSpecialtyModel? specialty) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return BottomRemoveSheet(
          headerText: headerText,
          action: action,
          isMiniaturized: true,
          isCartView: true,
          onTap: () async {
            _isLoading = true;
            notifyListeners();
            if (_isLoading) {
              Future.delayed(const Duration(seconds: 2), () async {
                if (isClearAllCached) {
                  await removeCachedData();
                } else {
                  await removeItem(index!, specialty!);
                }
                Navigator.of(context).pop();
                _isLoading = false;
              });
            }
            notifyListeners();
          },
        );
      },
    );
  }

  Future<void> removeCachedData() async {
    final cart = await Get.find<NewCartController>();
    cart.clear();
    //  cart.clearCartHistory();
    notifyListeners();
  }

  // REMOVE INDIVIDUAL CART ITEM

  Future<void> removeItem(int index, NewSpecialtyModel specialty) async {
    final cart = await Get.find<NewCartController>();
    cart.addItem(specialty, -1);
  }
}
