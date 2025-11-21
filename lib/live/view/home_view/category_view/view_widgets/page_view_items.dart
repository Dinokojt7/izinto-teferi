import 'package:flutter/material.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/try_this_service_widget.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../widgets/generic_header_row.dart';
import '../../../../widgets/text_widgets/description_text.dart';
import '../../../../widgets/text_widgets/heading_style_text.dart';
import '../../../../widgets/text_widgets/introduction_text.dart';
import '../../../../widgets/text_widgets/small_black_bold.dart';

class PageViewItems extends StatelessWidget {
  final String serviceViewed;
  const PageViewItems({Key? key, required this.serviceViewed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewController>(
        builder: (context, _homeController, child) {
      return Container(
        width: Dimensions.screenWidth,
        // color: Colors.red,
        child: Column(
          children: [
            serviceViewed != 'Best for Less'
                ? Container(
                    height: Dimensions.height45 * 1.8,
                    width: double.maxFinite,
                    child: Image.asset(
                      'assets/image/car-wash-category-view.jpeg',
                      width: double.maxFinite,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.only(
                  left: Dimensions.width15,
                  right: Dimensions.width15,
                  top: Dimensions.height30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DescriptionText(
                      text: 'EASY WASH MOBILE CAR WASH SERVICE',
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    IntroductionText(
                      text: 'Why Mobile Car Wash',
                      textSize: Dimensions.font20 * 1.1,
                    ),
                    notch(),
                    SizedBox(
                      height: Dimensions.height30,
                    ),
                    SmallBlackBald(
                      text: 'Save time and wash at your convenience',
                      isBold: true,
                    ),
                    SizedBox(
                      height: Dimensions.height20 * 1.1,
                    ),
                    SmallBlackBald(
                      text:
                          'Leave the hussle and tussle of driving through busy roads to get to the car wash. Easy wash lets you take care of the car wash with just a few clicks.',
                      isBold: false,
                    ),
                    SizedBox(
                      height: Dimensions.height20 * 1.1,
                    ),
                    SmallBlackBald(
                      text: 'How does it work?',
                      isBold: true,
                    ),
                    SizedBox(
                      height: Dimensions.height20 * 1.1,
                    ),
                    SmallBlackBald(
                      text:
                          'Leave the hussle and tussle of driving through busy roads to get to the car wash. Easy wash lets you take care of the car wash with just a few clicks.',
                      isBold: false,
                    ),
                    SizedBox(
                      height: Dimensions.height20 * 1.1,
                    ),
                    TryThisServiceWidget(),
                    SizedBox(
                      height: Dimensions.height20 * 1.1,
                    ),
                    // Padding(
                    //   padding:
                    //       EdgeInsets.symmetric(horizontal: Dimensions.width30),
                    //   child: GestureDetector(
                    //       onTap: () {
                    //         Get.to(() => CarWashView(),
                    //             transition: Transition.fade,
                    //             duration: Duration(seconds: 1));
                    //       },
                    //       child: CTAButton()),
                    // ),
                    SizedBox(
                      height: Dimensions.height20 * 1.1,
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

  Widget notch() => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          width: Dimensions.width30 * 1.4,
          height: Dimensions.height10 / 3.5,
          color: Colors.black87,
        ),
      );

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
