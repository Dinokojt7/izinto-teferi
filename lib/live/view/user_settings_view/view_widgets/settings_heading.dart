import 'package:flutter/material.dart';

import '../../../widgets/generic_header_row.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class SettingsHeading extends StatelessWidget {
  final String heading;
  const SettingsHeading({
    super.key,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: GenericHeaderRow(
        headingChild: HeadingStyleText(
          text: heading,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
