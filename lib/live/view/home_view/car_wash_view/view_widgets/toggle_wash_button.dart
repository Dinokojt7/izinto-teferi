import 'package:flutter/material.dart';

import '../../../../../utils/dimensions.dart';

import '../../../cart_view/view_widgets/cart_product_actions.dart';

class ToggleWashButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ToggleWashButton({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15 / 1.1),
        color: Colors.black,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radius15 / 1.1),
          onTap: onTap,
          child: ActionButton(icon: icon),
        ),
      ),
    );
  }
}
