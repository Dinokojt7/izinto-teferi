import 'package:flutter/material.dart';

class TopLogo extends StatelessWidget {
  const TopLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logos/retro-logo.png', // Image path from item list
          height: 35.0, alignment: Alignment.topCenter,
        ),
      ],
    );
  }
}
