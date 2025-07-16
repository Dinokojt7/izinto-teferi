import 'package:flutter/material.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../../widgets/texts/small_text.dart';
import '../../../../utilities/colors.dart';

class IncludedVehicles extends StatelessWidget {
  const IncludedVehicles({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height45 * 1.4,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        color: LiveColors.accent.withOpacity(0.05),
        border: Border.all(color: Colors.white, width: 3.0),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 16.0, vertical: Dimensions.height10 / 2),
      child: true
          ? Center(
              child: SmallText(
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: Colors.grey.withOpacity(0.5),
                  size: Dimensions.font16 / 1.3,
                  text: 'You have not added any vehicles'),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [],
            ),
    );
  }
}
