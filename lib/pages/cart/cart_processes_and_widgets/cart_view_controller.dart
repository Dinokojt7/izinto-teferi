import 'package:flutter/material.dart';

class CartViewController extends ChangeNotifier {
  bool _isSubscriptionPayment = false;
  bool get isSubscriptionPayment => _isSubscriptionPayment;

  bool _isViewSubscriptionSignUp = false;
  bool get isViewSubscriptionSignUp => _isViewSubscriptionSignUp;

  void showDialog() {
    _isViewSubscriptionSignUp = !_isViewSubscriptionSignUp;
    notifyListeners();
  }

  void changeHeight() {
    _isSubscriptionPayment = true;
    notifyListeners();
  }
}
