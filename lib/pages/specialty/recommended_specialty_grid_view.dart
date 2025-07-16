import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/widgets/miscellaneous/App_column.dart';
import 'package:izinto/widgets/miscellaneous/app_icon.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../controllers/popular_specialty_controller.dart';
import '../../controllers/recommended_specialty_controller.dart';
import '../../routes/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/small_text.dart';

class RecommendedSpecialtyGridView extends StatelessWidget {
  const RecommendedSpecialtyGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var specialty = Get.find<RecommendedSpecialtyController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteHelper.getInitial());
                  },
                  child: AppIcon(
                    icon: Icons.keyboard_backspace_outlined,
                    backgroundColor: Colors.white,
                    iconColor: AppColors.mainBlackColor,
                    size: 35,
                    iconSize: Dimensions.iconSize24 * 1.1,
                  ),
                ),
                // GetBuilder<RecommendedSpecialtyController>(
                //   builder: (controller) {
                //     return GestureDetector(
                //       onTap: () {
                //         if (controller.totalItems >= 1)
                //           Get.toNamed(RouteHelper.getCartPage());
                //       },
                //       child: controller.totalItems >= 1
                //           ? Stack(
                //         children: [
                //           AppIcon(
                //             icon: Icons.shopping_cart_outlined,
                //           ),
                //           controller.totalItems >= 1
                //               ? Positioned(
                //             right: 0,
                //             top: 0,
                //             child: AppIcon(
                //                 icon: Icons.circle,
                //                 size: 20,
                //                 iconColor: Colors.transparent,
                //                 backgroundColor: Colors.black26),
                //           )
                //               : Container(),
                //           if (Get.find<RecommendedSpecialtyController>()
                //               .totalItems >=
                //               10)
                //             Positioned(
                //               right: 2,
                //               top: 0,
                //               child: BigText(
                //                 text: Get.find<
                //                     RecommendedSpecialtyController>()
                //                     .totalItems
                //                     .toString(),
                //                 size: 14,
                //                 color: Color(0xff785c44),
                //                 weight: FontWeight.w700,
                //               ),
                //             )
                //           else
                //             Positioned(
                //               right: 5,
                //               top: 0,
                //               child: BigText(
                //                 text: Get.find<
                //                     RecommendedSpecialtyController>()
                //                     .totalItems
                //                     .toString(),
                //                 size: 14,
                //                 color: Color(0xff785c44),
                //                 weight: FontWeight.w700,
                //               ),
                //             )
                //         ],
                //       )
                //           : AppIcon(
                //         icon: Icons.shopping_cart_outlined,
                //       ),
                //     );
                //   },
                // ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xfffefafa),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xffCFC5A5),
                            blurRadius: 2.0,
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius:
                            BorderRadius.circular(Dimensions.height10 * 5),
                        border: Border.all(
                          width: 1,
                          color: Color(0xffCFC5A5),
                        )),
                    child: AppIcon(
                      icon: (MdiIcons.pail),
                      backgroundColor: Colors.white,
                      iconSize: Dimensions.height20 + 4,
                      size: Dimensions.height10 * 4,
                      iconColor: Color(0xFFCFC5A5),
                    ),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Container(
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: Dimensions.width15),
                    child: Container(child: AppColumn())),
                width: double.maxFinite,
                padding: const EdgeInsets.only(top: 5, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radius20),
                    topRight: Radius.circular(Dimensions.radius20),
                  ),
                ),
              ),
            ),
            pinned: true,
            backgroundColor: Colors.white,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Image.asset(
                // specialty.img,
                'assets/image/offbeat2.png',
                width: double.maxFinite,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: GetBuilder<PopularSpecialtyController>(
              builder: (popularSpecialties) {
                return popularSpecialties.isLoaded
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            popularSpecialties.popularSpecialtyList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              // color: Color(0xfffefafa),
                              // boxShadow: const [
                              //   BoxShadow(
                              //     color: Colors.black12,
                              //     blurRadius: 1.0,
                              //     offset: Offset(1, 2),
                              //   ),
                              // ],
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                            ),
                            height: Dimensions.height30 * 3.8,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            margin: EdgeInsets.only(
                              left: Dimensions.width20,
                              right: Dimensions.width20,
                              bottom: Dimensions.height20,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(RouteHelper.getPopularSpecialties(
                                    index, 'home'));
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //image section
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.all(8),
                                    width: Dimensions.height20 * 4.5,
                                    height: Dimensions.height20 * 4.5,
                                    decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 5.0,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radius15),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage(popularSpecialties
                                                .popularSpecialtyList[index]
                                                .img!)),
                                        color: Colors.white),
                                  ),
                                  SizedBox(width: Dimensions.width10),
                                  //text container
                                  Expanded(
                                    child: SizedBox(
                                      height: Dimensions.listViewTextContSize,
                                      // margin: EdgeInsets.symmetric(
                                      //     horizontal: Dimensions.width15),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: Dimensions.width10),
                                        child: Stack(
                                          children: [
                                            SmallText(
                                              size: Dimensions.font16,
                                              text: popularSpecialties
                                                  .popularSpecialtyList[index]
                                                  .name,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.mainColor2,
                                            ),
                                            Positioned(
                                              top: 27,
                                              child: SmallText(
                                                overFlow: TextOverflow.ellipsis,
                                                text: popularSpecialties
                                                        .popularSpecialtyList[
                                                            index]
                                                        .provider +
                                                    ', Bryanston',
                                                color: AppColors.titleColor,
                                                size: Dimensions.font16,
                                              ),
                                            ),
                                            Positioned(
                                              top: 55,
                                              child: SmallText(
                                                text:
                                                    'R ${popularSpecialties.popularSpecialtyList[index].price!.toString()}.00',
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.mainColor,
                                                size: Dimensions.font16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Container(
                                      // padding: EdgeInsets.symmetric(
                                      //   horizontal: Dimensions.width10,
                                      //   vertical: Dimensions.height10 / 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0xffCFC5A5)),
                                      ),
                                      child: AppIcon(
                                        size: Dimensions.iconSize26 + 2,
                                        iconSize: Dimensions.iconSize24,
                                        backgroundColor: Colors.white,
                                        iconColor: const Color(0xffCFC5A5),
                                        icon: Icons.add,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : CircularProgressIndicator(
                        strokeWidth: 2.1,
                        color: AppColors.mainColor,
                      );
              },
            ),
          )
        ],
      ),
    );
  }
}
