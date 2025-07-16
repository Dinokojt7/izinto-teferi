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
  late String firstHalf;
  late String secondHalf;

  bool hiddenText = true;

  double textHeight = Dimensions.screenHeight / 5.63;

  @override
  void initState() {
    super.initState();
    if (widget.text.length > textHeight) {
      firstHalf = widget.text.substring(0, textHeight.toInt());
      secondHalf =
          widget.text.substring(textHeight.toInt() + 1, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: secondHalf.isEmpty
          ? SmallText(
              height: 1.5,
              color: Colors.black,
              size: Dimensions.font16 / 1.1,
              text: firstHalf)
          : Column(
              children: [
                SmallText(
                  height: 1.5,
                  color: Colors.black,
                  size: Dimensions.font16 / 1.1,
                  text: hiddenText
                      ? (firstHalf + "...")
                      : (firstHalf + secondHalf),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      hiddenText = !hiddenText;
                    });
                  },
                  child: Row(
                    children: [
                      IntegerText(
                        decoration: TextDecoration.underline,
                        text: hiddenText ? 'Show more' : 'Show less',
                        color: LiveColors.standardBlue,
                        size: Dimensions.font16 / 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
