import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:izinto/utils/colors.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.scale(
        scale: 0.5,
        child: CircularProgressIndicator(
          color: AppColors.mainColor,
        ),
      ),
    );
  }
}
