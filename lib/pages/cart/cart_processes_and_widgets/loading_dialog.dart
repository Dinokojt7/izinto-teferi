import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black38,
      insetPadding: EdgeInsets.all(0),
      elevation: 0,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius20),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.red.withOpacity(0.7),
            ),
          )),
    );
  }
}
