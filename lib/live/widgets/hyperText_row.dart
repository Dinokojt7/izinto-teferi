import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

import '../../utils/dimensions.dart';
import '../utilities/colors.dart';
import '../utilities/generic_system_navigation.dart';
import '../view/user_settings_view/screens/legal_documents/legal_document_screen.dart';

class HyperTextRow extends StatefulWidget {
  final String preText;
  final String firstLink;
  final String middleText;
  final String secondLink;

  const HyperTextRow({
    super.key,
    required this.preText,
    required this.firstLink,
    required this.middleText,
    required this.secondLink,
  });

  @override
  State<HyperTextRow> createState() => _HyperTextRowState();
}

class _HyperTextRowState extends State<HyperTextRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeadingStyleText(
          text: widget.preText,
          size: Dimensions.font20 / 1.8,
          family: 'Poppins',
          weight: FontWeight.w300,
          color: Colors.black,
        ),
        SizedBox(
          width: Dimensions.width10 / 2,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              SystemNavigation().applyCustomSystemChromeSettings(
                  Colors.white, Brightness.dark, Colors.white, Brightness.dark);
            });
            Get.to(
              () => LegalDocumentScreen(
                description:
                    'Please read these terms carefully before using our services',
                documentType: 'terms-of-use',
                screenTitle: 'Terms & Conditions',
                primaryColor: LiveColors.cartBlue,
                lastUpdated: 'June 2025',
              ),
              transition: Transition.native,
              duration: Duration(milliseconds: 500),
            );
          },
          child: HeadingStyleText(
            text: widget.firstLink,
            size: Dimensions.font20 / 1.8,
            family: 'Poppins',
            weight: FontWeight.w600,
            color: LiveColors.standardBlue,
          ),
        ),
        SizedBox(
          width: Dimensions.width10 / 2,
        ),
        HeadingStyleText(
          text: widget.middleText,
          size: Dimensions.font20 / 1.8,
          family: 'Poppins',
          weight: FontWeight.w300,
          color: Colors.black,
        ),
        SizedBox(
          width: Dimensions.width10 / 2,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              SystemNavigation().applyCustomSystemChromeSettings(
                  Colors.white, Brightness.dark, Colors.white, Brightness.dark);
            });
            Get.to(
              () => LegalDocumentScreen(
                documentType: 'privacy-policy',
                screenTitle: 'Privacy Policy',
                description: 'How we protect and use your personal information',
                primaryColor: LiveColors.cartBlue,
                lastUpdated: 'June 2025',
              ),
              transition: Transition.native,
              duration: Duration(milliseconds: 500),
            );
          },
          child: HeadingStyleText(
            text: widget.secondLink,
            size: Dimensions.font20 / 1.8,
            family: 'Poppins',
            weight: FontWeight.w600,
            color: LiveColors.standardBlue,
          ),
        ),
        HeadingStyleText(
          text: '.',
          size: Dimensions.font20 / 1.8,
          family: 'Poppins',
          weight: FontWeight.w300,
          color: Colors.black,
        ),
      ],
    );
  }
}
