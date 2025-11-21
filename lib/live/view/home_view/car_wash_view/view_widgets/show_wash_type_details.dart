import 'package:flutter/material.dart';
import 'package:izinto/live/view/cart_view/controller/cart_actions_controller.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/wash_spec_section.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/widgets/top_nortch.dart';

import 'package:provider/provider.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../../widgets/texts/small_text.dart';
import '../../../../utilities/colors.dart';
import '../../../../widgets/buttons/save_button.dart';

class ShowWashTypeDetails extends StatelessWidget {
  final String headerText;
  final String? price;
  final String description;
  final String action;
  final bool isMiniaturized;
  final bool isCartView;
  final VoidCallback onTap;

  const ShowWashTypeDetails({
    Key? key,
    required this.headerText,
    required this.action,
    required this.onTap,
    this.price,
    required this.isMiniaturized,
    required this.isCartView,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartActionsController>(
        builder: (context, _cartController, child) {
      return Consumer<HomeViewController>(
          builder: (context, _homeViewController, child) {
        return Container(
          // margin: EdgeInsets.only(bottom: Dimensions.bottomHeightBar / 2),
          height: MediaQuery.of(context).size.height,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left: Dimensions.width30,
                      right: Dimensions.width30,
                      top: Dimensions.width15),
                  color: LiveColors.accent.withOpacity(0.2),
                  child: Column(
                    children: [
                      TopNotch(
                        color: Colors.black.withOpacity(0.1),
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SmallText(
                                overFlow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                maxLines: 1,
                                color: Colors.black,
                                size: Dimensions.font16,
                                text: headerText),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Dimensions.height10,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: Dimensions.height10 / 2),
                      Padding(
                        padding: EdgeInsets.only(
                          left: Dimensions.width30,
                          top: Dimensions.height10 / 2,
                          right: Dimensions.width30,
                          bottom: Dimensions.height10 / 2,
                        ),
                        child: Row(
                          children: [
                            SmallText(
                                overFlow: TextOverflow.clip,
                                family: 'Onest',
                                maxLines: 1,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                color: Colors.black,
                                size: Dimensions.font16 / 1.12,
                                text: 'R${price}.00*'),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.height10 / 2),
                      Padding(
                        padding: EdgeInsets.only(
                          left: Dimensions.width30,
                          right: Dimensions.width30,
                        ),
                        child: const Divider(
                          color: Colors.black26,
                          height: 1,
                        ),
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: Dimensions.width30,
                          right: Dimensions.width30,
                        ),
                        child: Container(
                          width: double.maxFinite,
                          child: Center(
                            child: SmallText(
                                textAlign: TextAlign.center,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                color: Colors.black54,
                                size: Dimensions.font16 / 1.3,
                                text: description),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Dimensions.height30,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: Dimensions.width30,
                          right: Dimensions.width30,
                        ),
                        child: WashSpecSection(),
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: Dimensions.height20,
                          left: Dimensions.width30,
                          right: Dimensions.width30,
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SaveButton(
                                buttonHeight: isCartView
                                    ? Dimensions.bottomHeightBar / 2.2
                                    : Dimensions.bottomHeightBar / 2.1,
                                isActive: true,
                                isLoading: isCartView
                                    ? _cartController.isLoading
                                    : false,
                                description: action,
                                isAuthScreen: false,
                                onTap: onTap,
                              ),
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
      });
    });
  }
}
