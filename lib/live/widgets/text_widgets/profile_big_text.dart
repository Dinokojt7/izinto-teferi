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

  // Calculate the total character count
  int get _totalCharacters => (text1.length + text2.length);

  // Smooth scaling based on character count
  double get _dynamicFontSize {
    final baseSize = size ?? Dimensions.height20 * 2.2;
    final totalChars = _totalCharacters;

    if (totalChars <= 16) {
      return baseSize;
    } else {
      // Gradual scaling: reduce by 2.5% for each character over 16
      final extraChars = totalChars - 16;
      final reductionFactor = 1.0 - (extraChars * 0.025);
      return baseSize * reductionFactor.clamp(0.4, 1.0); // Never go below 40%
    }
  }

  // Dynamic min font size
  double get _minFontSize {
    final totalChars = _totalCharacters;

    if (totalChars <= 16) {
      return 18;
    } else {
      // Reduce min size gradually for longer names
      final extraChars = totalChars - 16;
      final reduction = extraChars * 0.5; // Reduce by 0.5 for each extra char
      return (18 - reduction).clamp(8.0, 18.0); // Never go below 8
    }
  }

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
                  fontSize: _dynamicFontSize,
                  fontFamily: 'Cabin',
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: text2.toUpperCase(),
                style: TextStyle(
                  fontSize: _dynamicFontSize,
                  fontFamily: 'Cabin',
                  color: LiveColors.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          maxLines: 1,
          minFontSize: _minFontSize,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
