import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../../widgets/texts/small_text.dart';
import '../../../widgets/buttons/blue_text_button.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../controller/cart_actions_controller.dart';

class CartHeading extends StatelessWidget {
  final String totalInCartItems;
  final BuildContext viewContext;
  const CartHeading({
    super.key,
    required this.totalInCartItems,
    required this.viewContext,
  });

  @override
  Widget build(BuildContext context) {
    final cartActionsController =
        Provider.of<CartActionsController>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 20.0, right: 16.0),
      child: GenericHeaderRow(
        headingChild: Row(
          children: [
            HeadingStyleText(
              text: 'Your items',
              weight: FontWeight.w600,
            ),
            SizedBox(
              width: Dimensions.width10,
            ),
            SmallText(
                height: 1.5,
                color: Colors.black,
                size: Dimensions.font16 / 1.5,
                text: totalInCartItems)
          ],
        ),
        actionButtonChild: BlueTextButton(
          text: 'Remove all',
          onTap: () {
            cartActionsController.clearCartData(
                context,
                'Remove all items from cart?',
                'Remove items',
                true,
                null,
                null);
          },
        ),
      ),
    );
  }
}
