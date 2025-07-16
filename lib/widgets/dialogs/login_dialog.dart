import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../pages/auth/get_started.dart';
import '../../pages/cart/cart_processes_and_widgets/dialog_text.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({
    super.key,
    required this.showDialog,
  });

  final ValueNotifier<bool> showDialog;

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: dialogText(
                text: 'Not Signed In',
                weight: FontWeight.w600,
                color: AppColors.fontColor,
                size: Dimensions.font26 / 1.1,
              ),
            ),
            dialogText(
              text: 'Please sign in to continue.',
              size: Dimensions.font16 / 1.1,
              color: AppColors.fontColor,
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    Get.to(() => const GetStarted(),
                        transition: Transition.rightToLeft,
                        duration: Duration(milliseconds: 100));

                    await Future.delayed(
                      Duration(seconds: 3),
                    );
                    setState(() {
                      widget.showDialog.value = !widget.showDialog.value;
                    });
                  },
                  child: dialogLocalButton(
                    text: 'Sign In',
                    callAction: 1,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: Dimensions.width20 / 1.5,
                ),
                GestureDetector(
                  onTap: () {
                    widget.showDialog.value = !widget.showDialog.value;
                  },
                  child: dialogLocalButton(
                    text: 'Maybe Later',
                    callAction: 0,
                    color: AppColors.fontColor,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
