import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../../widgets/texts/big_text.dart';
import '../../utilities/colors.dart';

class ProfileBigText extends StatelessWidget {
  final String text1;
  final String text2;
  final double? size;

  ProfileBigText({
    Key? key,
    required this.text1,
    required this.text2,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: AutoSizeText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: text1.toUpperCase(),
                style: TextStyle(
                  fontSize: size ?? Dimensions.height20 * 2.2, // Original size
                  fontFamily: 'Cabin',
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: text2.toUpperCase(),
                style: TextStyle(
                  fontSize: size ?? Dimensions.height20 * 2.2,
                  fontFamily: 'Cabin',
                  color: LiveColors.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          maxLines: 1,
          minFontSize: 18, // Minimum font size for both words
          overflow:
              TextOverflow.ellipsis, // Ensures text is truncated when necessary
        ),
      ),
    );
  }
}
