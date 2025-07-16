import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import 'dimensions.dart';

void appDialog({
  required BuildContext context,
  final VoidCallback? close,
  required String title,
  final VoidCallback? actionText,
  final VoidCallback? actionButton,
  required String buttonText,
  Widget? customField,
  required TextEditingController codeController,
}) {
  Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: Dimensions.width10,
            vertical: Dimensions.width30 + Dimensions.width15,
          ),
          width: double.infinity,
          height: Dimensions.screenHeight / 4.5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              color: Colors.white),
          padding: EdgeInsets.fromLTRB(
              Dimensions.width20, Dimensions.height10, Dimensions.width20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.close,
                  color: Colors.black87,
                  size: 15,
                ),
              ),
              SizedBox(
                height: Dimensions.height15,
              ),
              Text(
                title,
                softWrap: true,
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontFamily: 'Hind',
                  color: Colors.black87,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(
                height: Dimensions.height10,
              ),
              Container(
                child: customField,
              ),
              const Divider(
                indent: 1,
                endIndent: 1,
                color: Colors.black12,
                thickness: 1.1,
                height: 10,
              ),
              SizedBox(
                height: Dimensions.height30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: close,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: Dimensions.font20,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: actionText,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: Dimensions.height20 / 1.55,
                          bottom: Dimensions.height20 / 1.55,
                          left: Dimensions.width20 * 1.2,
                          right: Dimensions.width15 * 1.2),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
                        color: Color(0xff8E806A),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: codeController,
                          ),
                          Text(
                            buttonText,
                            style: TextStyle(
                              fontSize: Dimensions.font20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    ),
  );
}
