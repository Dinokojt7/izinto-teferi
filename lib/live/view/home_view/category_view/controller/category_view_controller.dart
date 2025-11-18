import 'package:flutter/material.dart';

class CategoryViewController extends ChangeNotifier {
  int _mainCategoryListIndex = 0;
  int get mainCategoryListIndex => _mainCategoryListIndex;

  int _selectedListIndex = 0;
  int get selectedListIndex => _selectedListIndex;

  int _tabsIndex = 0;
  int get tabsIndex => _tabsIndex;

  String _specialtyName = '';
  String get specialtyName => _specialtyName;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void updateCategoryList(int activeCategory, int activeList) {
    _mainCategoryListIndex = activeCategory;
    _selectedListIndex = activeList;
    _isInitialized = true;
    notifyListeners();
  }

  void updateTabsControllerIndex(String activeSpecialty, int activeTab) {
    _specialtyName = activeSpecialty;
    _tabsIndex = activeTab;
    _isInitialized = true;
    notifyListeners();
  }

  void reset() {
    _mainCategoryListIndex = 0;
    _selectedListIndex = 0;
    _tabsIndex = 0;
    _specialtyName = '';
    _isInitialized = false;
    notifyListeners();
  }
}
