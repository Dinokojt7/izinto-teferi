import 'package:flutter/material.dart';

class BottomIconBody extends StatelessWidget {
  final String iconString;
  final int index;
  const BottomIconBody(
      {Key? key, required this.iconString, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconString,
      // Image path from item list
      width: index == 0
          ? 27
          : index == 4
              ? 29
              : index == 1
                  ? 32
                  : 30.0,
      height: index == 0
          ? 27
          : index == 4
              ? 29
              : index == 1
                  ? 32
                  : 30.0,
    );
  }
}
