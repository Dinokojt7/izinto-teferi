import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';

class bottomBarLever extends StatelessWidget {
  const bottomBarLever({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Dimensions.screenWidth / 6,
        height: Dimensions.height10 / 2,
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(Dimensions.radius30)),
      ),
    );
  }
}
