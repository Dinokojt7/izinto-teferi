import 'package:flutter/material.dart';
import 'package:izinto/widgets/texts/small_text.dart';

import '../../utils/dimensions.dart';

class ProfileWidget extends StatelessWidget {
  final String boldText;
  final String text;
  final String hintText;
  const ProfileWidget(
      {Key? key,
      required this.boldText,
      required this.text,
      required this.hintText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: Dimensions.width20,
          top: Dimensions.width10,
          bottom: Dimensions.width10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: Dimensions.height15),
                child: Text(
                  text,
                  style: TextStyle(
                      fontFamily: 'Hind',
                      fontSize: MediaQuery.of(context).size.height * 0.0235,
                      color: Colors.black),
                  textAlign: TextAlign.left,
                ),
              ),
              SmallText(
                text: hintText,
                color: Colors.black54,
              )
            ],
          ),
          Padding(
            padding:
                EdgeInsets.only(right: Dimensions.width15 + Dimensions.width10),
            child: Text(
              boldText,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline),
            ),
          )
        ],
      ),
    );
  }
}
