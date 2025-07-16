import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';
import '../../checkout_view/view_widgets/generic_white_container.dart';

class TextInputContainer extends StatelessWidget {
  final Widget textField;
  const TextInputContainer({
    super.key,
    required this.textField,
  });

  @override
  Widget build(BuildContext context) {
    return GenericWhiteContainer(
      leftPadding: 5,
      bottomPadding: 0.0,
      child: Padding(
        padding: EdgeInsets.only(top: Dimensions.height20 / 1.5, bottom: 0),
        child: Container(
          height: Dimensions.height45 * 1.1,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: textField,
        ),
      ),
    );
  }
}
