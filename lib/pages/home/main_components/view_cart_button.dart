import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/pages/cart/re_cart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/popular_specialty_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/skeletons.dart';
import '../../../widgets/texts/integers_and_doubles.dart';
import '../../cart/cart_page.dart';

class ViewCartFloating extends StatefulWidget {
  final String? email;
  const ViewCartFloating({
    super.key,
    this.email,
  });

  @override
  State<ViewCartFloating> createState() => _ViewCartFloatingState();
}

class _ViewCartFloatingState extends State<ViewCartFloating> {
  bool isShowCartItemCount = false;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isShowCartItemCount = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (_cartController) {
      return GetBuilder<PopularSpecialtyController>(
          builder: (popularSpecialties) {
        return GestureDetector(
          onTap: () {
            Get.to(
                () => ReCart(
                      email: widget.email,
                    ),

                /// transition: Transition.rightToLeftWithFade,
                duration: Duration(milliseconds: 500));
          },
          child: Container(
            height: Dimensions.height30 * 2.2,
            width: Dimensions.width30 * 2.2,
            child: Center(
              child: Stack(
                children: [
                  popularSpecialties.isLoaded
                      ? Icon(
                          MdiIcons.pail,
                          color: const Color(0xff9A9483),
                          size: Dimensions.iconSize24 * 1.7,
                        )
                      : ViewCartSkeleton()
                ],
              ),
            ),
          ),
        );
      });
    });
  }
}
