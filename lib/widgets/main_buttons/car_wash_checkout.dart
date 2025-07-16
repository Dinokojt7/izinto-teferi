import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/pages/cart/re_cart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../controllers/cart_controller.dart';
import '../../pages/cart/cart_page.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class CarWashCheckout extends StatefulWidget {
  const CarWashCheckout({Key? key, required this.email}) : super(key: key);
  final String email;
  @override
  State<CarWashCheckout> createState() => _CarWashCheckoutState();
}

class _CarWashCheckoutState extends State<CarWashCheckout> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.screenWidth / 2.3, // Match parent width
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(Dimensions.radius15), // Rounded corners
        color: Colors.white, // Background color
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
            offset: Offset(1, 2),
          ),
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          Get.to(
            () => ReCart(
              email: widget.email,
              // storedTime: storedTime,
              // carTime: carTime,
              //  availableKilos: availableKilos,
              //  remainingWashes: totalWashes.toString(),
            ),
            duration: Duration(milliseconds: 500),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  Image(
                    color: Colors.black,
                    image: AssetImage('assets/image/carwash.png'),
                    width: 30,
                  ),
                  // GetBuilder<CartController>(
                  //   builder: (_cartController) {
                  //     return _cartController.totalItems >= 1
                  //         ? Positioned(
                  //             right: 0,
                  //             top: 0,
                  //             child: Container(
                  //               width: 23,
                  //               height: 23,
                  //               decoration: BoxDecoration(
                  //                 color: Colors.white,
                  //                 boxShadow: const [
                  //                   BoxShadow(
                  //                     color: Color(0xff966C3B),
                  //                     blurRadius: 2.0,
                  //                     offset: Offset(1, 1),
                  //                   ),
                  //                 ],
                  //                 borderRadius: BorderRadius.circular(
                  //                   Dimensions.height10 * 5,
                  //                 ),
                  //                 border: Border.all(
                  //                   width: 1,
                  //                   color: Color(0xff966C3B),
                  //                 ),
                  //               ),
                  //               child: Center(
                  //                 child: Text(
                  //                   '${Get.find<CartController>().totalItems.toString()}',
                  //                   style: TextStyle(
                  //                     fontSize: 14,
                  //                     fontFamily: 'Poppins',
                  //                     color: const Color(0xff966C3B),
                  //                     fontWeight: FontWeight.w600,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           )
                  //         : Container(width: 0, height: 0);
                  //   },
                  // ),
                ],
              ),
              Text(
                'View in cart',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  color: AppColors.fontColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
