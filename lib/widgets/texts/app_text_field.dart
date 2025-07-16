import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final void Function(String?)? onSubmitted;
  final TextInputType inputType;
  final int? textMaxLength;
  final bool isObscure;
  AppTextField(
      {Key? key,
      required this.hintText,
      this.isObscure = false,
      required this.inputType,
      this.textMaxLength,
      required this.textController,
      this.onSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height20 * 2.5,
      width: Dimensions.width30 * 13.5,
      margin: EdgeInsets.only(right: Dimensions.width15),
      child: TextField(
        cursorColor: Color(0xff9A9483),
        keyboardType: inputType,
        cursorHeight: Dimensions.height20 * 2,
        cursorWidth: Dimensions.width10 / 6,
        obscureText: isObscure ? true : false,
        controller: textController,
        maxLength: textMaxLength,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontSize: Dimensions.font26,
        ),
        decoration: InputDecoration(
          counterText: "",

          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            width: 1.0,
            color: Colors.white,
          )),
          //enabled border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            borderSide: BorderSide(
              width: 1.0,
              color: Colors.white,
            ),
          ),
          //border
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
        ),
      ),
    );
  }
}
