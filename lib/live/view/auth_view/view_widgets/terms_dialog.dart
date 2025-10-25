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
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    final phoneAuthController =
        Provider.of<PhoneAuthViewController>(context, listen: false);

    return Consumer<PhoneAuthViewController>(
        builder: (context, phoneAuthController, child) {
      void _handleTap() {
        if (!_termsAccepted) {
          // Show error if terms not accepted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Please accept the terms and conditions to continue'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _isTapped = true;
        });

        phoneAuthController.onConfirmButtonTapped(
            widget.widgetContext, _termsAccepted);

        // Optional: Reset border visibility after a short delay
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _isTapped = false;
            });
          }
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
                  height: Dimensions.screenHeight /
                      2.8, // Increased height for checkbox
                  width: Dimensions.screenWidth,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 0.7,
                        offset: Offset(0, 1.7),
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
                              textSize: Dimensions.font20 / 1.5,
                            ),
                          ],
                        ),

                        // Updated section with checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  _termsAccepted = value ?? false;
                                });
                              },
                            ),
                            SizedBox(width: Dimensions.width10),
                            Expanded(
                              child: DialogTextWidget(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                                      color: _termsAccepted
                                          ? Colors.black
                                          : Colors.grey,
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
