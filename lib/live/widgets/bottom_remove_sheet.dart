import 'package:flutter/material.dart';
import 'package:izinto/live/view/cart_view/controller/cart_actions_controller.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/top_nortch.dart';

import 'package:provider/provider.dart';

import '../../utils/dimensions.dart';
import 'buttons/save_button.dart';

class BottomRemoveSheet extends StatelessWidget {
  final String headerText;
  final String? description;
  final String action;
  final bool isMiniaturized;
  final bool isCartView;
  final VoidCallback onTap;

  const BottomRemoveSheet({
    Key? key,
    required this.headerText,
    required this.action,
    required this.onTap,
    this.description,
    required this.isMiniaturized,
    required this.isCartView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartActionsController>(
        builder: (context, _cartController, child) {
      return Consumer<HomeViewController>(
          builder: (context, _homeViewController, child) {
        return Container(
          // margin: EdgeInsets.only(bottom: Dimensions.bottomHeightBar / 2),
          height: isMiniaturized
              ? MediaQuery.of(context).size.height / 3.4
              : MediaQuery.of(context).size.height / 2.6,
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width30, vertical: Dimensions.width15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopNotch(
                color: Colors.black.withOpacity(0.1),
              ),
              SizedBox(
                height: Dimensions.height20,
              ),
              Row(
                mainAxisAlignment: isMiniaturized
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  HeadingStyleText(
                    text: headerText,
                    weight: FontWeight.w600,
                    size: Dimensions.font26 / 1.2,
                  ),
                ],
              ),
              SizedBox(
                height: Dimensions.height10,
              ),
              const Divider(
                indent: 8,
                endIndent: 8,
                color: Colors.black26,
                height: 20,
              ),
              SizedBox(
                height: isMiniaturized
                    ? Dimensions.height10 / 2
                    : Dimensions.height30,
              ),
              isMiniaturized
                  ? Container()
                  : Row(
                      children: [
                        Expanded(
                          child: HeadingStyleText(
                            text: description!,
                            weight: FontWeight.w400,
                            size: Dimensions.font16,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
              SizedBox(
                height: Dimensions.height45,
              ),
              SaveButton(
                buttonHeight: isCartView
                    ? Dimensions.bottomHeightBar / 2.2
                    : Dimensions.bottomHeightBar / 2.1,
                isActive: true,
                isLoading: isCartView
                    ? _cartController.isLoading
                    : _homeViewController.isLogOutLoading,
                description: action,
                isAuthScreen: false,
                onTap: onTap,
              ),
            ],
          ),
        );
      });
    });
  }
}
