import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/home_view/car_wash_view/car_wash_view.dart';
import '../../../../../utils/dimensions.dart';
import '../../../../../widgets/texts/small_text.dart';
import '../../../../utilities/colors.dart';
import '../../../../widgets/text_widgets/heading_style_text.dart';
import '../../../../widgets/text_widgets/small_black_text.dart';

class TryThisServiceWidget extends StatelessWidget {
  const TryThisServiceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimensions.width15,
        right: Dimensions.width15,
      ),
      child: Container(
        width: double.maxFinite,
        height: Dimensions.bottomHeightBar * 1.2,
        padding: EdgeInsets.only(left: Dimensions.width30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.5),
          color: LiveColors.accent.withOpacity(0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.only(right: Dimensions.width30),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SmallText(
                            overFlow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            maxLines: 1,
                            color: Colors.black,
                            size: Dimensions.font16 / 1.15,
                            text: 'Get Car Wash'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => CarWashView(),
                              transition: Transition.fade,
                              duration: Duration(seconds: 1));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius15),
                            border: Border.all(color: Colors.white60, width: 2),
                            color: LiveColors.accent.withOpacity(0.05),
                          ),
                          child: Center(
                            child: HeadingStyleText(
                                text: 'Wash Now',
                                size: Dimensions.font20 / 1.5,
                                family: 'Poppins',
                                weight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(Dimensions.radius15),
                      bottomRight: Radius.circular(Dimensions.radius15)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      'assets/image/car-wash-category.png',
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
