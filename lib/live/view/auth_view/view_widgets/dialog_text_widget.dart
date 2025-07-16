import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class DialogTextWidget extends StatefulWidget {
  late bool isSelected;
  final FontWeight fontWeight;

  DialogTextWidget({
    Key? key,
    required this.isSelected,
    required this.fontWeight,
  }) : super(key: key);

  @override
  State<DialogTextWidget> createState() => _DialogTextWidgetState();
}

class _DialogTextWidgetState extends State<DialogTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align items at the start (top)
          children: [
            Transform.scale(
              scale: 1.1,
              child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.black, // Darker border color
                  checkboxTheme: CheckboxThemeData(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0), // Square shape
                      side: BorderSide(
                        color: Colors.black, // Darker border
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                child: Checkbox(
                  value: widget.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      widget.isSelected = value ?? false;
                    });
                    // Additional actions here if needed
                  },
                ),
              ),
            ),
            SizedBox(width: 8.0), // Spacing between the checkbox and text
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: Dimensions.height10),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: Dimensions.font20 / 1.3,
                      fontFamily: 'Poppins',
                      fontWeight: widget.fontWeight,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: 'I accept the '),
                      TextSpan(
                        text: 'General Terms and Conditions',
                        style: TextStyle(
                            color: LiveColors.standardBlue,
                            fontWeight: FontWeight.w600),
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
                            color: LiveColors.standardBlue,
                            fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle tap on "privacy policy"
                          },
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
