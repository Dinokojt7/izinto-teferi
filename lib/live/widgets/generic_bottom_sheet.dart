import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/top_nortch.dart';


import '../../utils/dimensions.dart';

class GenericBottomSheet extends StatelessWidget {
  final String headerText;
  final String? description;
  final String action;
  final bool isMiniaturized;

  const GenericBottomSheet({
    Key? key,
    required this.headerText,
    required this.action,
    this.description,
    required this.isMiniaturized,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(bottom: Dimensions.bottomHeightBar / 2),
      height: isMiniaturized
          ? MediaQuery.of(context).size.height / 3.4
          : MediaQuery.of(context).size.height / 2.6,
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width30, vertical: Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TopNotch(
            color: Colors.black.withOpacity(0.1),
          ),
          SizedBox(
            height: Dimensions.height20,
          ),
          // In BottomRemoveSheet, update the Row widget:
          Row(
            mainAxisAlignment: isMiniaturized
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Expanded(
                // ← Add Expanded widget to constrain the text
                child: HeadingStyleText(
                  text: headerText,
                  weight: FontWeight.w600,
                  size: Dimensions.font26 / 1.2,
                  maxLines: 2, // ← Allow up to 2 lines
                  overFlow:
                      TextOverflow.ellipsis, // ← Add ellipsis if still too long
                  align: isMiniaturized
                      ? TextAlign.center
                      : TextAlign.left, // ← Maintain alignment
                ),
              ),
            ],
          ),

          const Divider(
            indent: 8,
            endIndent: 8,
            color: Colors.black26,
            height: 20,
          ),
          SizedBox(
            height:
                isMiniaturized ? Dimensions.height10 / 2 : Dimensions.height20,
          ),
          isMiniaturized
              ? Container()
              : Row(
                  children: [
                    Expanded(
                      child: HeadingStyleText(
                        text: description!,
                        weight: FontWeight.w400,
                        size: Dimensions.font16 / 1.1,
                        maxLines: 3,
                        overFlow: TextOverflow.ellipsis, // ← Add this too
                      ),
                    ),
                  ],
                ),
          SizedBox(
            height: Dimensions.height45 / 1.2,
          ),
        ],
      ),
    );
  }
}
