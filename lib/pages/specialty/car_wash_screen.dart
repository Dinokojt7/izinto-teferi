import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../controllers/car_specialty_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/integers_and_doubles.dart';
import '../../widgets/texts/small_text.dart';
import '../options/settings_view/terms_of_use.dart';

class CarWashView extends StatefulWidget {
  const CarWashView({Key? key}) : super(key: key);

  @override
  State<CarWashView> createState() => _CarWashViewState();
}

class _CarWashViewState extends State<CarWashView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int totalCarWashItems = 0;
      final List<dynamic> carWashSubList = [];

      for (var i = 0; i < cartController.getItems.length; i++) {
        switch (cartController.getItems[i].id) {
          case 401:
          case 402:
          case 403:
          case 404:
            carWashSubList.add({
              'img': cartController.getItems[i].img,
              'name': cartController.getItems[i].name
            });
            totalCarWashItems += cartController.getItems[i].quantity!;

            break;
        }
      }

      return GetBuilder<CarSpecialtyController>(builder: (carSpecialties) {
        return Center(
          child: Container(
            height: Dimensions.screenHeight / 1.5,
            width: Dimensions.screenWidth / 1.21,
            margin: EdgeInsets.only(top: Dimensions.screenHeight / 8),
            decoration: _buildBoxDecoration(),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(Dimensions.width10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          // widget.showDialog.value =
                          //     !widget
                          //         .showDialog.value;
                          // widget.showSubscriptionSignUpSwitch
                          //         ?.value =
                          //     !widget
                          //         .showSubscriptionSignUpSwitch!
                          //         .value;
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40 / 2),
                            color: Colors.white.withOpacity(0.7),
                            border: Border.all(
                              width: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${totalCarWashItems}',
                              style: TextStyle(
                                  fontSize: Dimensions.font16 * 1.1,
                                  fontFamily: 'Poppins',
                                  color: const Color(0Xff353839),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(
                  flex: Dimensions.height20.toInt(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IntegerText(
                        text: 'Select vehicle',
                        size: Dimensions.font16 * 2,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IntegerText(
                        text: 'Subscription',
                        height: Dimensions.height20 / Dimensions.height20,
                        size: Dimensions.font16 * 2.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Spacer(
                  flex: Dimensions.height15 ~/ 2,
                ),
                Spacer(),
                Container(
                  height: Dimensions.bottomHeightBar / 1.1,
                  width: Dimensions.screenWidth,
                  padding: EdgeInsets.only(
                      top: Dimensions.height10 / 2,
                      bottom: Dimensions.height10 / 2,
                      left: Dimensions.width20,
                      right: Dimensions.width20),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radius20 * 2),
                      topRight: Radius.circular(Dimensions.radius20 * 2),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: Dimensions.height20 / 1.5,
                        bottom: Dimensions.height20 / 1.5,
                        left: Dimensions.width20,
                        right: Dimensions.width20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntegerText(
                              text: 'R300.00',
                              size: Dimensions.font16 * 1.06,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mainBlackColor,
                            ),
                            SmallText(
                              text: 'k'!,
                              size: Dimensions.font16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.mainBlackColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                      color: AppColors.fontColor.withOpacity(0.1),
                    ),
                  ),
                ),
                SizedBox(
                  height: Dimensions.width10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const TermsOfUse(),
                              duration: Duration(milliseconds: 100));
                        },
                        child: IntegerText(
                          text: 'Terms & Conditions',
                          size: Dimensions.font16 / 1.2,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Dimensions.width10,
                ),
              ],
            ),
          ),
        );
      });
    });
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radius30 * 2),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 2.5,
          offset: Offset(1, 1),
        ),
        BoxShadow(
          color: Colors.black12,
          blurRadius: 2.5,
          offset: Offset(1, -1),
        ),
      ],
      color: Colors.white,
      image: DecorationImage(
        alignment: Alignment.topCenter,
        fit: BoxFit.fitWidth,
        image: AssetImage('assets/image/carsubscription_display.jpeg'),
      ),
    );
  }
}
