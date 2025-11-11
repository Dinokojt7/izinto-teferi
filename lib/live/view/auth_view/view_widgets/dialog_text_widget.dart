import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../../user_settings_view/screens/legal_documents/legal_document_screen.dart';

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
                  setState(() {
                    SystemNavigation().applyCustomSystemChromeSettings(
                        Colors.white,
                        Brightness.dark,
                        Colors.white,
                        Brightness.dark);
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
                  setState(() {
                    SystemNavigation().applyCustomSystemChromeSettings(
                        Colors.white,
                        Brightness.dark,
                        Colors.white,
                        Brightness.dark);
                  });
                  Get.to(
                    () => LegalDocumentScreen(
                      documentType: 'privacy-policy',
                      screenTitle: 'Privacy Policy',
                      description:
                          'How we protect and use your personal information',
                      primaryColor: LiveColors.cartBlue,
                      lastUpdated: 'June 2025',
                    ),
                    transition: Transition.native,
                    duration: Duration(milliseconds: 500),
                  );
                },
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
