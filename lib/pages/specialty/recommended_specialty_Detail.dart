import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/cart_controller.dart';
import 'package:izinto/controllers/recommended_specialty_controller.dart';
import 'package:izinto/routes/route_helper.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/miscellaneous/App_column.dart';
import 'package:izinto/widgets/miscellaneous/app_icon.dart';
import 'package:izinto/widgets/texts/expandable_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../utils/colors.dart';
import '../../widgets/texts/big_text.dart';
import '../../widgets/texts/integers_and_doubles.dart';
import '../../widgets/texts/small_text.dart';
import '../home/main_components/view_cart_button.dart';
import 'laundry_specialty_detail.dart';

class RecommendedSpecialtyDetail extends StatefulWidget {
  final int pageId;
  final String page;
  RecommendedSpecialtyDetail(
      {Key? key, required this.pageId, required this.page})
      : super(key: key);

  @override
  State<RecommendedSpecialtyDetail> createState() =>
      _RecommendedSpecialtyDetailState();
}

class _RecommendedSpecialtyDetailState
    extends State<RecommendedSpecialtyDetail> {
  bool _isTouching = false;
  @override
  Widget build(BuildContext context) {
    var specialty = Get.find<RecommendedSpecialtyController>()
        .recommendedSpecialtyList[widget.pageId];
    Get.find<RecommendedSpecialtyController>()
        .initSpecialty(specialty, Get.find<CartController>());
    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 100,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.page == 'cartpage') {
                        Get.toNamed(RouteHelper.getCartPage());
                      } else {
                        Get.toNamed(RouteHelper.getInitial());
                      }
                    },
                    child: AppIcon(
                      icon: Icons.keyboard_backspace_outlined,
                      backgroundColor: Colors.white,
                      iconColor: AppColors.mainBlackColor,
                      size: 35,
                      iconSize: Dimensions.iconSize24 * 1.1,
                    ),
                  ),
                  GetBuilder<RecommendedSpecialtyController>(
                    builder: (controller) {
                      return GestureDetector(
                          onTap: () {
                            if (controller.totalItems >= 1)
                              Get.toNamed(RouteHelper.getCartPage());
                          },
                          child: controller.totalItems >= 1
                              ? ViewCartFloating()
                              : Container());
                    },
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Container(
                  child: Center(
                    child: IntegerText(
                      color: AppColors.mainColor2,
                      size: Dimensions.font20 + 4,
                      text: specialty.name,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  width: double.maxFinite,
                  padding: EdgeInsets.only(top: 5, bottom: 10),
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
              backgroundColor: Colors.grey.withOpacity(0.11),
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  specialty.img,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    child: ExpandableText(text: specialty.introduction),
                    margin: EdgeInsets.only(
                        left: Dimensions.width20, right: Dimensions.width20),
                  ),
                ],
              ),
            )
          ],
        ),
        bottomNavigationBar:
            GetBuilder<RecommendedSpecialtyController>(builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                    left: Dimensions.width20 * 2.5,
                    right: Dimensions.width20 * 2.5,
                    top: Dimensions.height10,
                    bottom: Dimensions.height10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IntegerText(
                      text: ' R${specialty.price}',
                      color: AppColors.mainBlackColor,
                      size: Dimensions.font26,
                      fontWeight: FontWeight.w500,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.setQuantity(false);
                          },
                          child: QuantityHelper(
                            color: Color(0xffA0937D),
                            icon: Icons.remove,
                          ),
                        ),
                        SizedBox(
                          width: Dimensions.width20,
                        ),
                        Container(
                          height: Dimensions.height20 * 2.5,
                          width: Dimensions.height20 * 2.5,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Dimensions.height10 * 5),
                            gradient: LinearGradient(colors: [
                              AppColors.four,
                              AppColors.six,
                            ]),
                          ),
                          child: Center(
                            child: IntegerText(
                              text: ' ${controller.inCartItems} ',
                              color: Colors.white,
                              size: Dimensions.font20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Dimensions.width20,
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.setQuantity(true);
                          },
                          child: QuantityHelper(
                            color: AppColors.six,
                            icon: Icons.add,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: Dimensions.height10,
              ),
              Container(
                height: Dimensions.bottomHeightBar,
                width: Dimensions.screenWidth,
                padding: EdgeInsets.only(
                    top: Dimensions.height20,
                    bottom: Dimensions.height20,
                    left: Dimensions.width20,
                    right: Dimensions.width20),
                decoration: BoxDecoration(
                  color: AppColors.fontColor.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radius20 * 2),
                    topRight: Radius.circular(Dimensions.radius20 * 2),
                  ),
                ),
                child: GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      _isTouching = true;
                    });
                    controller.addItem(specialty);
                  },
                  onTapUp: (details) {
                    setState(() {
                      _isTouching = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        top: Dimensions.height20 / 1.5,
                        bottom: Dimensions.height20 / 1.5,
                        left: Dimensions.width20,
                        right: Dimensions.width20),
                    child: Center(
                      child: IntegerText(
                        size: Dimensions.font16,
                        text: 'Add to cart',
                        color: AppColors.fontColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                        color: _isTouching
                            ? Colors.black12.withOpacity(0.08)
                            : Colors.white),
                  ),
                ),
              )
            ],
          );
        }));
  }
}
