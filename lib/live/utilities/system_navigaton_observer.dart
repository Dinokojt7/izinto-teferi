// system_navigation_observer.dart
import 'package:flutter/material.dart';

import 'generic_system_navigation.dart';

class SystemNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _applySystemSettingsForRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _applySystemSettingsForRoute(newRoute);
    }
  }

  void _applySystemSettingsForRoute(Route route) {
    if (route.settings.name?.contains('MainScaffold') == true ||
        route.settings is MaterialPageRoute &&
            (route.settings as MaterialPageRoute)
                .builder
                .toString()
                .contains('MainScaffold')) {
      // Apply system settings for ViewOrderScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SystemNavigation().applyCustomSystemChromeSettings(
            Colors.black, Brightness.light, Colors.black, Brightness.light);
      });
      if (route.settings.name?.contains('ViewOrderScreen') == true ||
          route.settings is MaterialPageRoute &&
              (route.settings as MaterialPageRoute)
                  .builder
                  .toString()
                  .contains('ViewOrderScreen')) {
        // Apply system settings for ViewOrderScreen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemNavigation().applyCustomSystemChromeSettings(
              Colors.white.withOpacity(0.95),
              Brightness.dark,
              Colors.white,
              Brightness.dark);
        });
      }
      if (route.settings.name?.contains('PhoneAuthView') == true ||
          route.settings is MaterialPageRoute &&
              (route.settings as MaterialPageRoute)
                  .builder
                  .toString()
                  .contains('PhoneAuthView')) {
        // Apply system settings for PhoneAuthView
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemNavigation().applyCustomSystemChromeSettings(
              Colors.white.withOpacity(0.95),
              Brightness.dark,
              Colors.white,
              Brightness.dark);
        });
      }
      if (route.settings.name?.contains('ProfileView') == true ||
          route.settings is MaterialPageRoute &&
              (route.settings as MaterialPageRoute)
                  .builder
                  .toString()
                  .contains('ProfileView')) {
        // Apply system settings for ProfileView
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemNavigation().applyCustomSystemChromeSettings(
              Colors.white.withOpacity(0.95),
              Brightness.dark,
              Colors.white,
              Brightness.dark);
        });
      }
      if (route.settings.name?.contains('LegalDocumentScreen') == true ||
          route.settings is MaterialPageRoute &&
              (route.settings as MaterialPageRoute)
                  .builder
                  .toString()
                  .contains('LegalDocumentScreen')) {
        // Apply system settings for LegalDocumentScreen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemNavigation().applyCustomSystemChromeSettings(
              Colors.white.withOpacity(0.95),
              Brightness.dark,
              Colors.white,
              Brightness.dark);
        });
      }
      if (route.settings.name?.contains('FrequentlyAskedQuestions') == true ||
          route.settings is MaterialPageRoute &&
              (route.settings as MaterialPageRoute)
                  .builder
                  .toString()
                  .contains('FrequentlyAskedQuestions')) {
        // Apply system settings for FrequentlyAskedQuestions
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemNavigation().applyCustomSystemChromeSettings(
              Colors.white.withOpacity(0.95),
              Brightness.dark,
              Colors.white,
              Brightness.dark);
        });
      }
      if (route.settings.name?.contains('SavedAddresses') == true ||
          route.settings is MaterialPageRoute &&
              (route.settings as MaterialPageRoute)
                  .builder
                  .toString()
                  .contains('SavedAddresses')) {
        // Apply system settings for SavedAddresses
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SystemNavigation().applyCustomSystemChromeSettings(
              Colors.white.withOpacity(0.95),
              Brightness.dark,
              Colors.white,
              Brightness.dark);
        });
      }
    }
  }
}
