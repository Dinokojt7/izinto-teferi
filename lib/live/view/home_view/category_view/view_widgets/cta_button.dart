import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../widgets/text_widgets/heading_style_text.dart';

class CTAButton extends StatelessWidget {
  final bool isLoading = false;
  const CTAButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimensions.height10,
      ),
      child: Container(
        width: double.maxFinite,
        height: Dimensions.bottomHeightBar / 2.2,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
            color: LiveColors.cartBlue),
        child: isLoading
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
            : Center(
                child: HeadingStyleText(
                  size: Dimensions.font16,
                  color: Colors.white,
                  text: 'BOOK YOUR WASH',
                  family: 'Poppins',
                  weight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
