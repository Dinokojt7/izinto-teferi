import 'package:flutter/material.dart';
import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../controller/profile_view_controller.dart';
import 'package:provider/provider.dart';

class MarketingConsentForm extends StatelessWidget {
  final String description;
  final bool isEmailMarketing;
  final FontWeight fontWeight;

  const MarketingConsentForm({
    Key? key,
    required this.description,
    required this.isEmailMarketing,
    required this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewController>(
      builder: (context, controller, child) {
        bool isSelected = isEmailMarketing
            ? controller.emailMarketingConsent
            : controller.telephoneSurveyConsent;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1.1,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: Colors.black,
                      checkboxTheme: CheckboxThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                          side: BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                    ),
                    child: Checkbox(
                      activeColor: Colors.black,
                      value: isSelected,
                      onChanged: (bool? value) {
                        if (isEmailMarketing) {
                          controller
                              .updateEmailMarketingConsent(value ?? false);
                        } else {
                          controller
                              .updateTelephoneSurveyConsent(value ?? false);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: Dimensions.height10),
                    child: HeadingStyleText(
                      text: description,
                      size: Dimensions.font20 / 1.3,
                      family: 'Poppins',
                      weight: fontWeight,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
