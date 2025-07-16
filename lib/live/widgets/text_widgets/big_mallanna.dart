import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../../widgets/texts/big_text.dart';
import '../../utilities/colors.dart';

class BigMallanna extends StatelessWidget {
  final String text1;
  final String text2;
  final double? size;
  bool isSettingsView;
  BigMallanna({
    Key? key,
    required this.text1,
    required this.text2,
    this.size,
    this.isSettingsView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isSettingsView
            ? Expanded(
                child: Text(
                  text1.toUpperCase(),
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: size ?? Dimensions.height20 * 2.2,
                    fontFamily: 'Cabin',
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : Text(
                text1.toUpperCase(),
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: size ?? Dimensions.height20 * 2.2,
                  fontFamily: 'Cabin',
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
        SizedBox(
          width: Dimensions.width10 * 1.5,
        ),
        Expanded(
          child: Text(
            size != null ? text2.toUpperCase() : text2.toUpperCase(),
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: size ?? Dimensions.height20 * 2.2,
              fontFamily: 'Cabin',
              color: LiveColors.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
