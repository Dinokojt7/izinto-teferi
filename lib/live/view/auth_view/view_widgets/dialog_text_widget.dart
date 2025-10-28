import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class DialogTextWidget extends StatefulWidget {
  final FontWeight fontWeight;

  DialogTextWidget({
    Key? key,
    required this.fontWeight,
  }) : super(key: key);

  @override
  State<DialogTextWidget> createState() => _DialogTextWidgetState();
}

class _DialogTextWidgetState extends State<DialogTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.height10),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: Dimensions.font20 / 1.2,
            fontFamily: 'Poppins',
            fontWeight: widget.fontWeight,
            color: Colors.black,
          ),
          children: [
            TextSpan(text: 'I accept the '),
            TextSpan(
              text: 'General Terms and Conditions',
              style: TextStyle(
                  color: LiveColors.standardBlue, fontWeight: FontWeight.w600),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Handle tap on "terms and conditions"
                },
            ),
            TextSpan(
                text:
                    ' of Izinto (Teferi Group Limited.) and confirm receipt of the '),
            TextSpan(
              text: 'Privacy Notice',
              style: TextStyle(
                  color: LiveColors.standardBlue, fontWeight: FontWeight.w600),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Handle tap on "privacy policy"
                },
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
