import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/dimensions.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: EdgeInsets.only(
          bottom: Dimensions.screenHeight / 20,
          right: Dimensions.screenHeight / 50,
          left: Dimensions.screenHeight / 50),
      elevation: 8,
      backgroundColor: Color(0xff9A9483),
      behavior: SnackBarBehavior.floating,
      content: Text(text),
    ),
  );
}

// SnackBar(
// elevation: 8,
// backgroundColor:
// Color(0xff9A9483),
// behavior: SnackBarBehavior
//     .floating,
// content: const Text(
// 'You\'re currently not logged in'),
// ),
