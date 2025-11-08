import 'package:flutter/material.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class SelectedPaymentMethod extends StatelessWidget {
  const SelectedPaymentMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutViewController>(
      builder: (context, controller, child) {
        final selectedMethod = controller.paymentMethods.firstWhere(
          (method) => method['type'] == controller.selectedPaymentMethod,
          orElse: () => {},
        );

        if (selectedMethod.isEmpty) return Container();

        return Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: Dimensions.width10, top: Dimensions.height10 / 2),
              child: Container(
                height: Dimensions.height45 * 1.1,
                width: Dimensions.width30 * 2.3,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius20 / 2),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                child: Image.asset(
                  selectedMethod['image'],
                  width: 30.0,
                  height: 30.0,
                ),
              ),
            ),
            SizedBox(width: Dimensions.width20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Dimensions.height10 / 2.5),
                  HeadingStyleText(
                    text: selectedMethod['name'],
                    size: Dimensions.font20 / 1.3,
                    family: 'Poppins',
                    weight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  SizedBox(height: Dimensions.height10 / 2),
                  HeadingStyleText(
                    text: selectedMethod['description'],
                    size: Dimensions.font20 / 1.3,
                    family: 'Poppins',
                    weight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
