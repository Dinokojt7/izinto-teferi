import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/pages/options/settings_view/get_help_popup.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/laundry_specialty_controller.dart';
import '../../controllers/recommended_specialty_controller.dart';
import '../../routes/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/texts/big_text.dart';
import '../../widgets/texts/expandable_text.dart';
import '../../widgets/texts/integers_and_doubles.dart';
import '../../widgets/texts/small_text.dart';
import '../subscriptions/subscriptions.dart';

class LaundrySpecialtyDetail extends StatefulWidget {
  int pageId;
  final String page;
  LaundrySpecialtyDetail({Key? key, required this.page, required this.pageId})
      : super(key: key);

  @override
  State<LaundrySpecialtyDetail> createState() => _LaundrySpecialtyDetailState();
}

class _LaundrySpecialtyDetailState extends State<LaundrySpecialtyDetail> {
  bool _isTouching = false;
  @override
  Widget build(BuildContext context) {
    var specialty = Get.find<LaundrySpecialtyController>()
        .laundrySpecialtyList[widget.pageId];
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
                              ? Padding(
                                  padding:
                                      EdgeInsets.only(top: Dimensions.height20),
                                  child: Container(
                                    width: Dimensions.height20 * 4.3,
                                    height: Dimensions.height20 * 4.7,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 1,
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                        BoxShadow(
                                          offset: Offset(-1, -1),
                                          blurRadius: 1,
                                          color: Colors.black.withOpacity(0.2),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius20),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.height10 * 5),
                                              color: const Color(0xff966C3B),
                                              boxShadow: [
                                                BoxShadow(
                                                    offset: Offset(2, 1),
                                                    blurRadius: 1,
                                                    color:
                                                        const Color(0xff966C3B)
                                                            .withOpacity(0.2))
                                              ]),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              MdiIcons.pail,
                                              color: Colors.white,
                                              size: Dimensions.iconSize24 * 1,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: Dimensions.height10 / 2,
                                        ),
                                        GetBuilder<CartController>(
                                            builder: (controller) {
                                          return Text(
                                            '${controller.totalItems.toString()}',
                                            style: TextStyle(
                                                fontSize:
                                                    Dimensions.font16 / 1.1,
                                                fontFamily: 'Poppins',
                                                color: AppColors.fontColor,
                                                fontWeight: FontWeight.w600),
                                          );
                                        }),
                                        Text(
                                          'Checkout',
                                          style: TextStyle(
                                              fontSize: Dimensions.font16 / 1.3,
                                              fontFamily: 'Poppins',
                                              color: AppColors.fontColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
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

class QuantityHelper extends StatelessWidget {
  const QuantityHelper({
    super.key,
    required this.color,
    required this.icon,
  });
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(
      //   horizontal: Dimensions.width10,
      //   vertical: Dimensions.height10 / 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1.3, color: color),
      ),
      child: AppIcon(
        weight: 10,
        size: 30,
        iconSize: Dimensions.iconSize24,
        backgroundColor: Colors.white,
        iconColor: color,
        icon: icon,
      ),
    );
  }
}
