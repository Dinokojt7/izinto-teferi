import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/buttons/blue_text_button.dart';
import 'package:izinto/widgets/miscellaneous/app_icon.dart';

import '../../utils/dimensions.dart';
import 'colors.dart';

class GenericSnackBar {
  void showCustomSnackBar(VoidCallback? onTap, BuildContext context,
      String message, bool isWiderSnack) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.horizontal,
        margin: isWiderSnack
            ? EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 2.0)
            : EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
        duration: Duration(seconds: 2),
        elevation: 5,
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.only(
            left: 0, top: 0, right: Dimensions.width20, bottom: 0),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: Dimensions.width10 / 2,
                    height: Dimensions.height45 * 1.3,
                    decoration: BoxDecoration(
                      color: LiveColors.cartBlue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radius15 / 2),
                        bottomLeft: Radius.circular(Dimensions.radius15 / 2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: Dimensions.width10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: LiveColors.cartBlue,
                            size: Dimensions.iconSize26,
                          ),
                          SizedBox(width: Dimensions.width10),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.black,
                                fontSize: Dimensions.font20 / 1.38,
                                fontWeight: isWiderSnack
                                    ? FontWeight.w500
                                    : FontWeight.w300,
                              ),
                              maxLines: 2, // Allow up to 2 lines
                              overflow: TextOverflow.ellipsis, // Add ellipsis
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            onTap != null
                ? BlueTextButton(text: 'login', onTap: onTap)
                : GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    },
                    child: AppIcon(
                      icon: Icons.close,
                      backgroundColor: Colors.black.withOpacity(0.04),
                      size: Dimensions.iconSize26,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
