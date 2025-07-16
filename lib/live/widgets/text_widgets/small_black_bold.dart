import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';

class SmallBlackBald extends StatelessWidget {
  final String text;
  final bool isBold;
  const SmallBlackBald({Key? key, required this.text, required this.isBold})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        decoration: TextDecoration.none,
        fontSize: Dimensions.font20 / 1.4,
        fontFamily: 'Poppins',
        color: isBold ? Colors.black : Colors.black87,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
