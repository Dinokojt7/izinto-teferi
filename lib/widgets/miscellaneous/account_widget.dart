import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../utils/colors.dart';
import 'app_icon.dart';

class AccountWidget extends StatelessWidget {
  AppIcon appIcon;
  final String text;
  AccountWidget({Key? key, required this.appIcon, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: Dimensions.width20,
          top: Dimensions.width10,
          bottom: Dimensions.width10),
      child: Row(
        children: [
          appIcon,
          SizedBox(
            width: Dimensions.width15,
          ),
          Text(
            text,
            style: TextStyle(
                fontFamily: 'Hind',
                fontSize: MediaQuery.of(context).size.height * 0.0235,
                color: AppColors.titleColor),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
