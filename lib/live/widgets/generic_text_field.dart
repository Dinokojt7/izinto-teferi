import 'package:flutter/material.dart';
import '../../utils/dimensions.dart';
import '../view/checkout_view/view_widgets/generic_white_container.dart';

class GenericTextField extends StatelessWidget {
  final Widget textField;
  final Color? backgroundColor;
  const GenericTextField(
      {Key? key, required this.textField, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultColor = Colors.black12.withOpacity(0.03);
    return GenericWhiteContainer(
      color: backgroundColor ?? defaultColor,
      leftPadding: 5,
      topPadding: 0.1,
      bottomPadding: 0.1,
      child: Padding(
        padding: EdgeInsets.only(
            top: Dimensions.height15, bottom: Dimensions.height10),
        child: Container(
          height: Dimensions.height45 / 1.2,
          alignment: Alignment.centerLeft, // Add this for vertical alignment
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Align(
            // Wrap with Align widget
            alignment: Alignment.centerLeft,
            child: textField,
          ),
        ),
      ),
    );
  }
}
