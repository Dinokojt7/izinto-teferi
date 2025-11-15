import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../utilities/colors.dart';

class ProfileBigText extends StatelessWidget {
  final String? text1;
  final String? text2;
  final double? size;

  const ProfileBigText({
    Key? key,
    this.text1,
    this.text2,
    this.size,
  }) : super(key: key);

  // Safe text getters with defaults
  String get _safeText1 => text1?.trim() ?? '';
  String get _safeText2 => text2?.trim() ?? '';

  // Calculate the total character count safely
  int get _totalCharacters => _safeText1.length + _safeText2.length;

  // Check if we have any content
  bool get _hasContent => _safeText1.isNotEmpty || _safeText2.isNotEmpty;

  // Smooth scaling based on character count
  double get _dynamicFontSize {
    final baseSize = size ?? Dimensions.height20 * 2.2;
    final totalChars = _totalCharacters;

    if (totalChars <= 16) {
      return baseSize;
    } else {
      final extraChars = totalChars - 16;
      final reductionFactor = 1.0 - (extraChars * 0.025);
      return baseSize * reductionFactor.clamp(0.4, 1.0);
    }
  }

  // Dynamic min font size
  double get _minFontSize {
    final totalChars = _totalCharacters;

    if (totalChars <= 16) {
      return 18.0;
    } else {
      final extraChars = totalChars - 16;
      final reduction = extraChars * 0.5;
      return (18.0 - reduction).clamp(8.0, 18.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) {
      return _buildPlaceholder();
    }

    return Expanded(
      child: Center(
        child: AutoSizeText.rich(
          TextSpan(
            children: [
              if (_safeText1.isNotEmpty)
                TextSpan(
                  text: _safeText1.toUpperCase(),
                  style: TextStyle(
                    fontSize: _dynamicFontSize,
                    fontFamily: 'Cabin',
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              if (_safeText2.isNotEmpty)
                TextSpan(
                  text: _safeText2.toUpperCase(),
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
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Expanded(
      child: Center(
        child: Text(
          'Your Account!',
          style: TextStyle(
            fontSize: Dimensions.height20 * 2.2,
            fontFamily: 'Cabin',
            color: Colors.grey,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
