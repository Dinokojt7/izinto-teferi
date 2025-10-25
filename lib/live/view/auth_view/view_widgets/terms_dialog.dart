import 'package:flutter/material.dart';
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
        void _handleTap() {
          setState(() {
            _isTapped = true;
          });

          phoneAuthController.onConfirmButtonTapped(widget.widgetContext);

          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              _isTapped = false;
            });
          });
        }

        return Dialog(
          elevation: 0,
          backgroundColor: Color(0xff000008).withOpacity(0.55),
          insetPadding: EdgeInsets.all(Dimensions.width20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height / 3,
            ),
            margin: EdgeInsets.all(Dimensions.width20),
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
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with proper text wrapping
                  Padding(
                    padding: EdgeInsets.only(bottom: Dimensions.height10),
                    child: IntroductionText(
                      text: 'General Terms and Conditions',
                      textSize: Dimensions.font20 / 1.1,
                      maxLines: 2,
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: DialogTextWidget(
                        isSelected: false,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.height20),

                  // Confirm button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: Dimensions.height30 * 1.2,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius20 / 2.1),
                          onTap: _handleTap,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width20,
                              vertical: Dimensions.height10,
                            ),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
