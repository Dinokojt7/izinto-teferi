import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';
import '../save_button_loader.dart';
import '../text_widgets/heading_style_text.dart';

class SaveButton extends StatefulWidget {
  final bool isActive;
  final bool? isLoading;
  final String description;
  final double? buttonHeight;
  final bool isAuthScreen;
  final Color? buttonColor;
  final VoidCallback onTap;
  const SaveButton({
    super.key,
    required this.isActive,
    required this.description,
    this.isLoading = false,
    this.buttonHeight,
    required this.isAuthScreen,
    this.buttonColor = Colors.black,
    required this.onTap,
  });

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool _isTapped = false;
  void _handleTap() {
    setState(() {
      _isTapped = true;
    });
    widget.onTap();

    // Optional: Reset border visibility after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isTapped = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimensions.height10,
      ),
      child: Container(
        width: double.maxFinite,
        height: widget.buttonHeight ?? Dimensions.bottomHeightBar / 2.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          color: widget.isActive
              ? widget.buttonColor
              : Colors.black12.withOpacity(0.17),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
            onTap: _handleTap,
            child: widget.isLoading!
                ? widget.isAuthScreen
                    ? Center(
                        child: SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularCappedProgressIndicator(
                              //      value: _backgroundAnimation.value,
                              color: Colors.white70,
                              strokeWidth: 3.0,
                              strokeCap: StrokeCap.round),
                        ),
                      )
                    : SaveButtonLoader()
                : Center(
                    child: HeadingStyleText(
                      size: _isTapped
                          ? Dimensions.font16 / 1.02
                          : Dimensions.font16,
                      color: Colors.white,
                      text: widget.description,
                      family: 'Poppins',
                      weight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
