import 'package:flutter/material.dart';
import '../../utils/dimensions.dart';
import '../texts/big_text.dart';

class OTPVerifyButton extends StatelessWidget {
  const OTPVerifyButton({
    Key? key,
    required this.phoneController,
    required this.isLoading,
  }) : super(key: key);

  final TextEditingController phoneController;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: Dimensions.bottomHeightBar / 1.2,
        padding: EdgeInsets.only(
            top: Dimensions.height18,
            bottom: Dimensions.height15,
            left: Dimensions.width20,
            right: Dimensions.width20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radius20 * 2),
            topRight: Radius.circular(Dimensions.radius20 * 2),
          ),
        ),
        child: Container(
          height: Dimensions.screenHeight / 14,
          width: Dimensions.width30 * 15,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                (!phoneController.text.isEmpty)
                    ? Color(0xffCFC5A5)
                    : Color(0xffCFC5A5),
                (phoneController.text.isEmpty)
                    ? Color(0xff9A9483)
                    : Color(0xff9A9483),
              ],
            ),

            borderRadius: BorderRadius.all(
              Radius.circular(Dimensions.radius20 * 3),
            ),
            // color: const Color(0xff8d7053),
          ),
          child: isLoading
              ? Transform.scale(
                  scale: 0.5,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                )
              : Center(
                  child: BigText(
                    text: 'Continue',
                    size: Dimensions.font20,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
