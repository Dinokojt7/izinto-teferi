import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../pages/cart/cart_processes_and_widgets/no_items.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/miscellaneous/app_icon.dart';
import '../../../../widgets/texts/small_text.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/text_widgets/small_black_text.dart';
import '../../checkout_view/view_widgets/generic_white_container.dart';
import 'cart_product_actions.dart';

class CartProductView extends StatelessWidget {
  final List cartList;
  final int index;
  const CartProductView({
    super.key,
    required this.cartList,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(left: 16.0, top: 10.0, right: 16.0, bottom: 10.0),
      child: GenericWhiteContainer(
        topPadding: 10.0,
        leftPadding: 4.0,
        rightPadding: 6.0,
        bottomPadding: 10.0,
        child: Row(
          children: [
            AppIcon(
              size: 24,
              icon: Icons.thermostat,
              backgroundColor: LiveColors.standardBlue.withOpacity(0.05),
              iconColor: Colors.black,
            ),
            Container(
              padding: EdgeInsets.only(left: 8, right: 12),
              child: Image.asset(
                cartList[index].img!,
                width: 70,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallBlackText(
                          text: 'R${cartList[index].price!.toString()},00*',
                          size: Dimensions.font20 / 1.1,
                          font: 'Poppins',
                          fontWeight: FontWeight.w600),
                      Icon(
                        MdiIcons.heartOutline,
                        color: Colors.black.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SmallText(
                          height: 1.5,
                          color: Colors.black,
                          size: Dimensions.font16 / 1.3,
                          fontWeight: FontWeight.w500,
                          text: cartList[index].name!),
                    ],
                  ),
                  Row(
                    children: [
                      SmallText(
                          height: 1.5,
                          color: Colors.black,
                          size: Dimensions.font16 / 1.5,
                          text: cartList[index].type!)
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.height10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallBlackText(
                        text: 'More info',
                        decoration: TextDecoration.underline,
                        size: Dimensions.font20 / 1.8,
                        font: 'Poppins',
                        fontWeight: FontWeight.w600,
                        overFlow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      CartProductActions(
                        quantity: cartList[index].quantity,
                        index: index,
                        productName: cartList[index].name,
                        viewContext: context,
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
