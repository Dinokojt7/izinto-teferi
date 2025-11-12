// system_navigation_manager.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class SystemNavigationManager {
  static final SystemNavigationManager _instance =
      SystemNavigationManager._internal();
  factory SystemNavigationManager() => _instance;
  SystemNavigationManager._internal();

  String _currentRoute = '';
  bool _isHomeViewActive = false;
  bool _isApplyingTheme = false;

  // Define themes
  static const SystemUiOverlayStyle _homeViewTheme = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle _lightTheme = SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  // Routes that should use HOME theme (black bars, white icons)
  final List<String> _homeThemeRoutes = [
    'HomeView',
    'MainScaffold',
    'LightThemeHome',
    'OrderHistoryView',
    'CartViewPage',
    'FavoritesView',
    'UserSettingsView'
  ];

  // Routes that should use LIGHT theme (white bars, dark icons)
  final List<String> _lightThemeRoutes = [
    'CashPaymentSuccessScreen'
        'PhoneAuthView',
    'ProfileView',
    'LegalDocumentScreen',
    'FrequentlyAskedQuestions',
    'SavedAddresses',
    'SaveAddress',
    'ViewOrderScreen',
    'OrderSupportChat',
    'CheckoutPage',
  ];

  void setHomeViewActive(bool isActive) {
    if (_isHomeViewActive == isActive) return; // Prevent unnecessary calls

    _isHomeViewActive = isActive;
    if (isActive) {
      _safeApplyTheme(_applyHomeViewTheme);
    }
  }

  void setCurrentRoute(String routeName) {
    if (_currentRoute == routeName) return; // Prevent duplicate calls

    _currentRoute = routeName;
    _applyRouteSpecificSettings();
  }

  void _safeApplyTheme(Function themeApplier) {
    if (_isApplyingTheme) return;

    _isApplyingTheme = true;
    themeApplier();
    _isApplyingTheme = false;
  }

  void _applyHomeViewTheme() {
    SystemChrome.setSystemUIOverlayStyle(_homeViewTheme);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void _applyLightTheme() {
    SystemChrome.setSystemUIOverlayStyle(_lightTheme);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void _applyRouteSpecificSettings() {
    // Check for light theme routes first (more specific)
    if (_lightThemeRoutes.any((route) => _currentRoute.contains(route))) {
      _safeApplyTheme(_applyLightTheme);
    }
    // Then check for home theme routes
    else if (_homeThemeRoutes.any((route) => _currentRoute.contains(route))) {
      _safeApplyTheme(_applyHomeViewTheme);
    }
    // Default to home theme if HomeView is active
    else if (_isHomeViewActive) {
      _safeApplyTheme(_applyHomeViewTheme);
    }
  }

  // For explicit control when needed
  void applyHomeTheme() {
    _safeApplyTheme(_applyHomeViewTheme);
  }

  void applyLightTheme() {
    _safeApplyTheme(_applyLightTheme);
  }
}
