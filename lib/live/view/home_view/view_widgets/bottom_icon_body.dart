import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class BottomIconBody extends StatelessWidget {
  final String iconString;
  final int index;
  final bool isSelected;
  const BottomIconBody({
    Key? key,
    required this.iconString,
    required this.index,
    this.isSelected = false,
  }) : super(key: key);

  double _getIconSize() {
    switch (index) {
      case 0:
        return 27.0;
      case 1:
        return 32.0;
      case 3: // Favorites icon
        return isSelected ? 25.0 : 29.0; // Smaller when selected
      case 4:
        return 29.0;
      default:
        return 30.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconString,
      width: _getIconSize(),
      height: _getIconSize(),
    );
  }
}
