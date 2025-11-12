// screen_wrappers.dart
import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/system_navigation_manager.dart';

// For Home Theme Screens (Black bars, White icons)
class HomeThemeScreen extends StatefulWidget {
  final Widget child;
  final String routeName;

  const HomeThemeScreen({
    Key? key,
    required this.child,
    required this.routeName,
  }) : super(key: key);

  @override
  State<HomeThemeScreen> createState() => _HomeThemeScreenState();
}

class _HomeThemeScreenState extends State<HomeThemeScreen> {
  @override
  void initState() {
    super.initState();
    SystemNavigationManager().setCurrentRoute(widget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// For Light Theme Screens (White bars, Dark icons)
class LightThemeScreen extends StatefulWidget {
  final Widget child;
  final String routeName;

  const LightThemeScreen({
    Key? key,
    required this.child,
    required this.routeName,
  }) : super(key: key);

  @override
  State<LightThemeScreen> createState() => _LightThemeScreenState();
}

class _LightThemeScreenState extends State<LightThemeScreen> {
  @override
  void initState() {
    super.initState();
    SystemNavigationManager().setCurrentRoute(widget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
