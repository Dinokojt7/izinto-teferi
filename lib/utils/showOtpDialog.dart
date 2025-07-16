import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showOTPDialog({
  required BuildContext context,
  required TextEditingController codeController,
  required VoidCallback onPressed,
}) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: const Text('Enter OPT'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: codeController,
                )
              ],
            ),
            actions: [
              TextButton(onPressed: onPressed, child: const Text('Continue'))
            ],
          ));
}
