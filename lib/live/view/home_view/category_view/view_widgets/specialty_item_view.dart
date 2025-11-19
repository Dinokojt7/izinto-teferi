import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/home_view/car_wash_view/car_wash_view.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/service_detail_display.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/try_this_service_widget.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../../widgets/texts/small_text.dart';
import '../../../../widgets/generic_header_row.dart';
import '../../../../widgets/text_widgets/description_text.dart';
import '../../../../widgets/text_widgets/heading_style_text.dart';
import '../../../../widgets/text_widgets/introduction_text.dart';
import '../../../../widgets/text_widgets/small_black_bold.dart';
import 'cta_button.dart';

class SpecialityItemView extends StatelessWidget {
  final String serviceViewed;
  const SpecialityItemView({Key? key, required this.serviceViewed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewController>(
        builder: (context, _homeController, child) {
      return Container(
        width: Dimensions.screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radius15),
          ),
          //  color: Colors.redAccent
        ),
        // color: Colors.red,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: Dimensions.height30 / 10),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: Dimensions.width15,
                        top: Dimensions.height20,
                        right: Dimensions.width15,
                      ),
                      child: Column(
                        children: [
                          DescriptionText(
                            text: 'EASY WASH MOBILE CAR WASH SERVICE',
                          ),
                          SizedBox(
                            height: Dimensions.height20 / 1.5,
                          ),
                          IntroductionText(
                            text: 'Why Mobile Car Wash?',
                            textSize: Dimensions.font20 * 1.1,
                          ),
                          SizedBox(
                            height: Dimensions.height30 / 1.2,
                          ),
                          SecondaryBoldText(
                              text: 'Save time and wash at your convenience'),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          SmallBlackBald(
                            text:
                                "Skip the traffic and queues. Get your car washed with just a few taps - we bring the car wash to you.",
                            isBold: false,
                          ),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                        ],
                      ),
                    ),
                    ServiceDetailDisplay(),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: Dimensions.width15,
                      ),
                      child: Row(
                        children: [
                          IntroductionText(
                            text: 'Get Started',
                            textSize: Dimensions.font20 * 1.1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    TryThisServiceWidget(),
                    SizedBox(
                      height: Dimensions.height20 / 1.1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildHeading(String viewedService) => Padding(
        padding: EdgeInsets.only(
            top: 10.0, left: Dimensions.width10, bottom: Dimensions.height20),
        child: Row(
          children: [
            GenericHeaderRow(
              headingChild: HeadingStyleText(
                text: viewedService,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class SecondaryBoldText extends StatelessWidget {
  final String text;
  const SecondaryBoldText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SmallText(
        overFlow: TextOverflow.ellipsis,
        fontWeight: FontWeight.w600,
        height: 1.5,
        maxLines: 1,
        color: Colors.black,
        size: Dimensions.font16 / 1.15,
        text: text);
  }
}
