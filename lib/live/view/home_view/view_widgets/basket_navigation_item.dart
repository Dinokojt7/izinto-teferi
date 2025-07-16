import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class BasketNavigationItem extends StatelessWidget {
  const BasketNavigationItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewController>(
        builder: (context, homeController, child) {
      return GetBuilder<CartController>(builder: (_cartController) {
        var totalCartItems = _cartController.totalItems;
        return Stack(
          children: [
            Stack(
              children: [
                homeController.selectedIndex == 2
                    ? Image.asset(
                        'assets/icons/bucket-selected.png',
                        width: 30.0,
                        height: 30.0,
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                totalCartItems > 0 && homeController.selectedIndex != 2
                    ? Image.asset(
                        'assets/icons/bucket-ready.png',
                        width: 30.0,
                        height: 30.0,
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                Image.asset(
                  'assets/icons/bucket.png',
                  width: 30.0,
                  height: 30.0,
                ),
              ],
            ),
            Positioned(
              top: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: totalCartItems == 0
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: HeadingStyleText(
                          size: Dimensions.font20 / 1.5,
                          color: Colors.white,
                          text: totalCartItems.toString(),
                          family: 'Poppins',
                          weight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      });
    });
  }
}
