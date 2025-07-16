import 'package:flutter/material.dart';
import 'package:izinto/live/view/profile_view/view_widgets/marketing_consent_form.dart';
import 'package:izinto/live/widgets/generic_center_dialog.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/introduction_text.dart';
import '../controller/phone_auth_view_controller.dart';
import 'dialog_text_widget.dart';

class TermsDialog extends StatefulWidget {
  final BuildContext widgetContext;
  const TermsDialog({Key? key, required this.widgetContext}) : super(key: key);

  @override
  State<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final phoneAuthController =
        Provider.of<PhoneAuthViewController>(context, listen: false);
    return Consumer<PhoneAuthViewController>(
        builder: (context, phoneAuthController, child) {
      var isGoogleAuth = phoneAuthController.isGoogleAuth;
      void _handleTap() {
        setState(() {
          _isTapped = true;
        });

        phoneAuthController.onConfirmButtonTapped(widget.widgetContext);

        // Optional: Reset border visibility after a short delay
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            _isTapped = false;
          });
        });
      }

      return Center(
        child: Dialog(
          elevation: 0,
          backgroundColor: Color(0xff000008).withOpacity(0.55),
          insetPadding: EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Dimensions.width20 * 1.1),
                child: Container(
                  margin: EdgeInsets.only(top: Dimensions.height45 / 1.1),
                  height: Dimensions.screenHeight / 3.2,
                  width: Dimensions.screenWidth,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                            0.1), // Slightly more opaque shadow color
                        spreadRadius: 1, // Spread the shadow more evenly
                        blurRadius: 0.7, // Increase blur for a smoother shadow
                        offset: Offset(
                            0, 1.7), // Offset downward to remove the top shadow
                      ),
                    ],
                    border: Border.all(
                      width: 0.5,
                      color: Colors.black.withOpacity(0.04),
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width30 / 1.4,
                        vertical: Dimensions.height20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            IntroductionText(
                              text: 'General Terms and Conditions',
                              textSize: Dimensions.font20,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Padding(
                              padding:
                                  EdgeInsets.only(right: Dimensions.width30),
                              child: DialogTextWidget(
                                isSelected: false,
                                fontWeight: FontWeight.w500,
                              ),
                            ))
                          ],
                        ),
                        SizedBox(
                          height: Dimensions.height30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: Dimensions.height30 * 1.2,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _handleTap,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IntroductionText(
                                      text: 'Confirm',
                                      textSize: _isTapped
                                          ? Dimensions.font20 / 1.15
                                          : Dimensions.font20 / 1.1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
