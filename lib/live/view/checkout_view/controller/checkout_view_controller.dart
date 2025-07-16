import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../checkout_page.dart';

class CheckoutViewController extends ChangeNotifier {
  //Primary
  bool _isLoadingIndicator = false;
  bool get isLoadingIndicator => _isLoadingIndicator;

  //Delivery instructions
  bool _shouldLeaveAtTheDoor = false;
  bool get shouldLeaveAtTheDoor => _shouldLeaveAtTheDoor;
  bool _isBellAllowed = false;
  bool get isBellAllowed => _isBellAllowed;
  bool _shouldCallWhenArrive = false;
  bool get shouldCallWhenArrive => _shouldCallWhenArrive;

  //Order summary values
  int _orderSubtotal = 88;
  int get orderSubtotal => _orderSubtotal;
  int _serviceFee = 35;
  int get serviceFee => _serviceFee;
  int _optionalTip = 0;
  int get optionalTip => _optionalTip;
  int _orderTotal = 0;
  int get orderTotal => _orderTotal;
  bool _isFreeDelivery = true;
  bool get isFreeDelivery => _isFreeDelivery;

  //Delivery notes
  String _defaultDeliveryNote = 'Any other delivery notes? Add them here!';
  String get defaultDeliveryNote => _defaultDeliveryNote;

  void selectOption() {
    // isChecked = !isChecked;
    // notifyListeners();
    print(
        'value of ${_shouldLeaveAtTheDoor} is now ${_shouldLeaveAtTheDoor.toString()}');
    print('value of ${isBellAllowed} is now ${isBellAllowed.toString()}');
    print(
        'value of ${shouldCallWhenArrive} is now ${shouldCallWhenArrive.toString()}');
  }

  Future<void> onUserNavigation(BuildContext context, Widget child) async {
    _isLoadingIndicator = true;
    notifyListeners(); // Immediately notify listeners about the change

    await Future.delayed(const Duration(seconds: 1), () async {
      await Get.to(() => child,
          transition: Transition.fade, duration: Duration(seconds: 1));
      ;
      _isLoadingIndicator = false;
      notifyListeners();
    });
  }
}
