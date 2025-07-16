import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';

class TopNotch extends StatelessWidget {
  final Color color;
  const TopNotch({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.width30 * 1.6,
      height: Dimensions.height10 / 1.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
        color: color,
      ),
    );
  }
}
