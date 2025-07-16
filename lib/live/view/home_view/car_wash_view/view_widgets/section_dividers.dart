import 'package:flutter/material.dart';

import '../../../../../utils/dimensions.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 0.6,
      color: Colors.grey.shade300,
      indent: Dimensions.width10,
      endIndent: Dimensions.width10,
    );
  }
}

class ContainedDivider extends StatelessWidget {
  const ContainedDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Divider(
        thickness: 0.6,
        color: Colors.grey.shade300,
      ),
    );
  }
}
