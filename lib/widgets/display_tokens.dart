import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'miscellaneous/app_icon.dart';

class DisplayTokens extends StatefulWidget {
  const DisplayTokens({
    super.key,
    required this.tokens,
  });

  final double tokens;

  @override
  State<DisplayTokens> createState() => _DisplayTokensState();
}

class _DisplayTokensState extends State<DisplayTokens> {
  @override
  Widget build(BuildContext context) {
    final displayRewards = (widget.tokens * 100).toInt();
    final displayGraph = (widget.tokens * Dimensions.screenWidth)
        .clamp(0.0, Dimensions.screenWidth);
    return Container(
      height: Dimensions.height45,
      color: Colors.transparent,
      padding: EdgeInsets.only(top: Dimensions.height20 / 2),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Stack(
          children: [
            Stack(
              children: [
                Container(
                  height: Dimensions.height20 / 1.1,
                  decoration: buildBoxDecoration(
                    Colors.grey.withOpacity(0.25),
                  ),
                ),
                Container(
                  height: Dimensions.height20 / 1.1,
                  width: displayGraph,
                  decoration: buildBoxDecoration(AppColors.one
                      // Colors.grey.withOpacity(0.2),
                      ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: Dimensions.width10),
                  child: Text(
                    'R ${displayRewards.toString()}.00',
                    style: TextStyle(
                        fontSize: Dimensions.font16 / 1.4,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: Dimensions.height45 / 1.8,
                      height: Dimensions.height45 / 1.8,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                        color: Colors.green,
                      ),
                      child: Icon(
                        MdiIcons.trophy,
                        color: Colors.white,
                        size: Dimensions.iconSize16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration buildBoxDecoration(Color backgroundColor) {
    return BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radius30));
  }
}
