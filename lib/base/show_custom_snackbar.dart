import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/utils/dimensions.dart';

import '../utils/colors.dart';
import '../widgets/texts/big_text.dart';

void showCustomSnackBar(String message,
    {bool isError = true, String title = 'Error'}) {
  Get.snackbar(title, message,
      titleText: BigText(
        text: title,
        color: Colors.white,
        weight: FontWeight.normal,
      ),
      messageText: Text(
        message,
        style: TextStyle(
            color: Color(0xff8E806A), fontSize: Dimensions.font16 * 1.08),
      ),
      borderRadius: 6,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderWidth: Dimensions.width10 / 9,
      borderColor: Color(0xffA0937D),
      backgroundGradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xff966C3B),
          Color(0xffA0937D),
        ],
      ));
}
