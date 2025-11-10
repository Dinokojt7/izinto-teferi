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
  }
}
