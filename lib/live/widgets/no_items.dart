import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/small_text.dart';

class NoItems extends StatelessWidget {
  const NoItems({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenHeight / 3,
      child: Center(
        child: SmallText(
          text: "No items",
          maxLines: 1,
          color: AppColors.titleColor.withOpacity(0.5),
          height: 1.5,
          size: Dimensions.font16,
          overFlow: TextOverflow.fade,
        ),
      ),
    );
  }
}
