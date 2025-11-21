import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';



class GenericWhiteContainer extends StatelessWidget {
  final Widget child;
  final double topPadding;
  final double bottomPadding;
  final double leftPadding;
  final double rightPadding;
  final bool isSelected;
  final Color color;
  final bool isExpanded;

  const GenericWhiteContainer({
    super.key,
    required this.child,
    this.topPadding = 0.0,
    this.bottomPadding = 16.0,
    this.leftPadding = 15.0,
    this.isSelected = false,
    this.color = Colors.white,
    this.rightPadding = 15.0,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? double.maxFinite : null,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          border: isSelected
              ? Border.all(
                  color: Colors.black,
                  width: 1.8,
                )
              : null),
      child: Padding(
        padding: isExpanded
            ? EdgeInsets.only(
                left: leftPadding,
                top: topPadding,
                right: rightPadding,
                bottom: bottomPadding)
            : EdgeInsets.all(6.0),
        child: child,
      ),
    );
  }
}
