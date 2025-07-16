import 'package:flutter/material.dart';

class UserSettingsController extends ChangeNotifier {
  int _currentActiveTab = 0;
  int get currentActiveTab => _currentActiveTab;

  void getActiveTab(int tabIndex) {
    _currentActiveTab = tabIndex;
    notifyListeners();
  }
}
