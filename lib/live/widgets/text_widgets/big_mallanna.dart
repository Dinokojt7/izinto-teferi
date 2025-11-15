import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../utilities/colors.dart';

class BigMallanna extends StatelessWidget {
  final String text1;
  final String text2;
  final double? size;
  final bool isSettingsView;

  const BigMallanna({
    Key? key,
    required this.text1,
    required this.text2,
    this.size,
    this.isSettingsView = false,
  }) : super(key: key);

  // Safe text getters with defaults
  String get _safeText1 => text1.trim();
  String get _safeText2 => text2.trim();

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

    return Row(
      children: [
        // First Text Part
        if (isSettingsView)
          Expanded(
            child: _buildAutoSizeText(
              text: _safeText1.toUpperCase(),
              color: Colors.white,
            ),
          )
        else
          _buildAutoSizeText(
            text: _safeText1.toUpperCase(),
            color: Colors.white,
          ),

        SizedBox(width: Dimensions.width10 * 1.5),

        // Second Text Part - Always Expanded
        Expanded(
          child: _buildAutoSizeText(
            text: _safeText2.toUpperCase(),
            color: LiveColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAutoSizeText({
    required String text,
    required Color color,
  }) {
    return AutoSizeText(
      text,
      maxLines: 1,
      minFontSize: _minFontSize,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: _dynamicFontSize,
        fontFamily: 'Cabin',
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Row(
      children: [
        _buildStaticText(
          text: 'Hello',
          color: Colors.white,
        ),
        SizedBox(width: Dimensions.width10 * 1.5),
        Expanded(
          child: _buildStaticText(
            text: 'Welcome',
            color: LiveColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStaticText({
    required String text,
    required Color color,
  }) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: size ?? Dimensions.height20 * 2.2,
        fontFamily: 'Cabin',
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
