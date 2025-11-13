// lib/live/widgets/expandable_text_widget.dart
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../widgets/texts/integers_and_doubles.dart';
import '../utilities/colors.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableTextWidget({
    Key? key,
    required this.text,
    this.maxLines = 3,
  }) : super(key: key);

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;
  bool _needsExpansion = false;

  @override
  void initState() {
    super.initState();
    // Check if text needs expansion after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  void _checkTextOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: TextStyle(
          fontFamily: 'Poppins',
          letterSpacing: 0.10,
          color: Colors.black,
          fontSize: Dimensions.font16 / 1.1,
          height: 1.5,
          fontWeight: FontWeight.w300,
        ),
      ),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: Dimensions.screenWidth - 40);

    if (mounted) {
      setState(() {
        _needsExpansion = textPainter.didExceedMaxLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Text(
              widget.text,
              style: TextStyle(
                fontSize: Dimensions.font16 / 1.1,
                height: 1.5,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow:
                  _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            );
          },
        ),

        // Show toggle button only if text needs expansion
        if (_needsExpansion)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: IntegerText(
                decoration: TextDecoration.underline,
                text: _isExpanded ? 'Show less' : 'Show more',
                color: LiveColors.standardBlue,
                size: Dimensions.font16 / 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
