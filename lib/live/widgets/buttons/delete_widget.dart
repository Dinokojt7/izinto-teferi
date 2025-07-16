import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';
import '../../utilities/colors.dart';
import '../text_widgets/heading_style_text.dart';

class DeleteWidget extends StatefulWidget {
  final String description;
  final String? imagePath;
  const DeleteWidget({Key? key, required this.description, this.imagePath})
      : super(key: key);

  @override
  State<DeleteWidget> createState() => _DeleteWidgetState();
}

class _DeleteWidgetState extends State<DeleteWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.imagePath != null
            ? Row(
                children: [
                  Image.asset(
                    widget.imagePath!, // Image path from item list
                    width: 25.0,
                    height: 25.0,
                  ),
                  SizedBox(width: Dimensions.width10 * 1.2),
                ],
              )
            : Container(), // Your icon
        // Space between icon and text
        Expanded(
          child: HeadingStyleText(
            text: widget.description,
            size: Dimensions.font20 / 1.15,
            family: 'Poppins',
            weight: FontWeight.w600,
            color: LiveColors.standardRed,
          ),
        ),
      ],
    );
  }
}
