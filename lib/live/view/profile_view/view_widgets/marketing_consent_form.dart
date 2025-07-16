import 'package:flutter/material.dart';
import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class MarketingConsentForm extends StatefulWidget {
  final String description;
  late bool isSelected;
  final FontWeight fontWeight;

  MarketingConsentForm({
    Key? key,
    required this.description,
    required this.isSelected,
    required this.fontWeight,
  }) : super(key: key);

  @override
  State<MarketingConsentForm> createState() => _MarketingConsentFormState();
}

class _MarketingConsentFormState extends State<MarketingConsentForm> {
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
                child: HeadingStyleText(
                  text: widget.description,
                  size: Dimensions.font20 / 1.3,
                  family: 'Poppins',
                  weight: widget.fontWeight,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
