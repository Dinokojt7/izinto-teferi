import 'package:flutter/material.dart';

class GenericHeaderRow extends StatelessWidget {
  final Widget headingChild;
  final Widget? actionButtonChild;
  const GenericHeaderRow({
    super.key,
    required this.headingChild,
    this.actionButtonChild,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headingChild,
        actionButtonChild != null ? actionButtonChild! : Container(),
      ],
    );
  }
}
