import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../live/view/cart_view/controller/cart_actions_controller.dart';
import '../live/widgets/buttons/save_button.dart';
import '../live/widgets/text_widgets/heading_style_text.dart';
import '../live/widgets/top_nortch.dart';
import '../services/firebase_auth_methods.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

class BottomDeleteSheet extends StatelessWidget {
  final String expected;
  final String headerText;
  final String action;
  final int? index;
  final bool? isLoading;

  const BottomDeleteSheet({
    Key? key,
    required this.expected,
    required this.headerText,
    required this.action,
    this.index,
    this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartActionsController =
        Provider.of<CartActionsController>(context, listen: false);
    return Container(
      // margin: EdgeInsets.only(bottom: Dimensions.bottomHeightBar / 2),
      height: MediaQuery.of(context).size.height / 3.4,
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20, vertical: Dimensions.width15),
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
          HeadingStyleText(
            text: headerText,
            weight: FontWeight.w600,
            size: Dimensions.font26 / 1.2,
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
            height: Dimensions.height30,
          ),
          GestureDetector(
            child: Consumer<CartActionsController>(
                builder: (context, controller, child) {
              return SaveButton(
                isLoading: controller.isLoading,
                isActive: true,
                description: action,
                isAuthScreen: false,
                onTap: () {
                  if (expected == 'Logout') {
                  } else if (expected == 'Delete account') {
                  } else if (expected == 'Remove item') {
                    // cartActionsController.removeItem(index!);
                    Navigator.of(context).pop();
                  } else if (expected == 'Clear cart') {
                    Navigator.of(context).pop();
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
