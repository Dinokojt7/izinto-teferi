import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'texts/big_text.dart';

class WashDetailsPanel extends StatefulWidget {
  const WashDetailsPanel({Key? key}) : super(key: key);

  @override
  State<WashDetailsPanel> createState() => _WashDetailsPanelState();
}

class _WashDetailsPanelState extends State<WashDetailsPanel> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8, left: 20, top: 20, bottom: 0),
              child: Column(
                children: [
                  SizedBox(
                    height: Dimensions.height20,
                  ),
                  Row(
                    children: [
                      BigText(
                        text: 'Wash details',
                        color: AppColors.mainColor,
                        size: Dimensions.font20,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.only(bottom: 15, top: 15, right: 10),
                    padding: EdgeInsets.only(
                        left: 10, bottom: 5, right: 10, top: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          offset: Offset(5, 5),
                          color: AppColors.iconColor1.withOpacity(0.1),
                        ),
                        BoxShadow(
                          blurRadius: 3,
                          offset: Offset(-5, -5),
                          color: AppColors.iconColor1.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: Dimensions.width20,
                        ),
                        SizedBox(
                          height: Dimensions.width20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
