import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:izinto/utils/colors.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../live/utilities/colors.dart';
import 'integers_and_doubles.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool hiddenText = true;
  bool needsExpansion = false;

  @override
  void initState() {
    super.initState();
    // Check if text needs expansion after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextLength();
    });
  }

  void _checkTextLength() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: TextStyle(
          fontSize: Dimensions.font16 / 1.1,
          height: 1.5,
        ),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
        maxWidth: Dimensions.screenWidth - 40); // Account for padding
    setState(() {
      needsExpansion = textPainter.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: !needsExpansion
          ? SmallText(
              height: 1.5,
              color: Colors.black,
              size: Dimensions.font16 / 1.1,
              text: widget.text,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmallText(
                  height: 1.5,
                  color: Colors.black,
                  size: Dimensions.font16 / 1.1,
                  text:
                      hiddenText ? _getTruncatedText(widget.text) : widget.text,
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      hiddenText = !hiddenText;
                    });
                  },
                  child: IntegerText(
                    decoration: TextDecoration.underline,
                    text: hiddenText ? 'Show more' : 'Show less',
                    color: LiveColors.standardBlue,
                    size: Dimensions.font16 / 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
    );
  }

  String _getTruncatedText(String text) {
    const maxLines = 3;
    const maxCharsPerLine = 80; // Adjust based on your font size
    final maxChars = maxLines * maxCharsPerLine;

    if (text.length <= maxChars) return text;

    // Find the last space before maxChars to avoid cutting words
    final truncated = text.substring(0, maxChars);
    final lastSpace = truncated.lastIndexOf(' ');

    return lastSpace > 0
        ? '${text.substring(0, lastSpace)}...'
        : '$truncated...';
  }
}
