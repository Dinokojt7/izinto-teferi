import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        color: Colors.transparent,
      ),
    );
  }
}
