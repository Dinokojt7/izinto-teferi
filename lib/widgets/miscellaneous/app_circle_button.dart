import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AppCircleButton extends StatelessWidget {
  const AppCircleButton(
      {Key? key, required this.child, this.color, this.width = 60, this.onTap})
      : super(key: key);
  final Widget child;
  final Color? color;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      child: InkWell(
        child: child,
      ),
    );
  }
}
