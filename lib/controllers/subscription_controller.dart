
import 'package:flutter/material.dart';
class SubscriptionController extends ChangeNotifier{
  int _subscriptionStatus = 0;
  bool _switchValue = false;
  int _discountedItems = 0;

  int get subscriptionStatus => _subscriptionStatus;
  bool get switchValue => _switchValue;
  int get discountedItems => _discountedItems;

  void updateSubscription(bool success){
    if(success){
      _subscriptionStatus = 1;
      _switchValue = true;
    }
    notifyListeners();
  }
}