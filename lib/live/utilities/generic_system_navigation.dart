import 'package:flutter/services.dart';

class SystemNavigation {
  void applyCustomSystemChromeSettings(
      Color barColor,
      Brightness iconBrightness,
      Color? statusBarColor,
      Brightness? statusBarIconBrightness) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: barColor,
      systemNavigationBarIconBrightness: iconBrightness,
      statusBarIconBrightness: statusBarIconBrightness,
    ));
  }
}
