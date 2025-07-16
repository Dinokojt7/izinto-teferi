import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class NoDataPage extends StatelessWidget {
  final String text;
  final String imgPath;
  final bool softWrap;
  const NoDataPage(
      {Key? key,
      required this.text,
      this.imgPath = 'assets/image/nodatapage.png',
      required this.softWrap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          imgPath,
          height: MediaQuery.of(context).size.height * 0.18,
          width: MediaQuery.of(context).size.width * 0.16,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.009,
        ),
        Text(
          text,
          softWrap: softWrap,
          style: TextStyle(
            fontFamily: 'Hind',
            color: AppColors.titleColor,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
