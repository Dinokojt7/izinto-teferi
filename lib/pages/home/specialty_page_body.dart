import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/laundry_specialty_controller.dart';
import 'package:izinto/controllers/recommended_specialty_controller.dart';
import 'package:izinto/pages/specialty/item_screen.dart';
import 'package:izinto/services/firebase_storage_service.dart';
import 'package:izinto/utils/colors.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/miscellaneous/App_column.dart';
import 'package:izinto/widgets/texts/big_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/popular_specialty_controller.dart';
import '../../live/utilities/colors.dart';
import '../../models/cart_model.dart';
import '../../models/popular_specialty_model.dart';
import '../../models/selection_model.dart';
import '../../routes/route_helper.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/texts/flexible_font.dart';
import '../../widgets/texts/integers_and_doubles.dart';
import '../../widgets/texts/small_text.dart';

class SpecialtyPageBody extends StatefulWidget {
  final String? area;
  const SpecialtyPageBody({Key? key, this.area}) : super(key: key);

  @override
  _SpecialtyPageBodyState createState() => _SpecialtyPageBodyState();
}

class _SpecialtyPageBodyState extends State<SpecialtyPageBody> {
  PageController pageController = PageController(viewportFraction: 0.9);
  var _currPageValue = 0.0;
  final double _scaleFactor = 0.8;
  final double _height = Dimensions.pageViewContainer;
  late final String? _area;
  bool selected = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _area = widget.area;
    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void showCartControllers(bool isShow) {
    setState(() {
      isShow = true;
    });
    Future.delayed(const Duration(seconds: 4), () async {
      setState(() {
        isShow = false;
      });
    });
  }

  Future<void> _reloadDependencies() {
    return Future.delayed(const Duration(seconds: 6), () {});
  }

  @override
  Widget build(BuildContext context) {
    // if (_area == 'Midrand') {}

    return LayoutBuilder(builder: (context, constraints) {
      double logicalPixels = 411.0;
      double screenWidth = MediaQuery.of(context).size.width;
      bool isSmallestDevice = screenWidth <= logicalPixels;
      return StreamProvider<List<SpecialtyModel>>.value(
        value: DatabaseService().specialties,
        initialData: [],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ///Top Slider Section
            recommended(),

            ///Add To Cart
            ItemScreen(),

            /// Laundry Categories
            // list of services and images
            GetBuilder<CartController>(builder: (_cartController) {
              return Stack(
                children: [
                  GetBuilder<LaundrySpecialtyController>(
                    builder: (laundrySpecialties) {
                      return laundrySpecialties.isLoaded
                          ? Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: Dimensions.width10,
                                    top: Dimensions.height15,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: Dimensions.width20,
                                      ),
                                      BigText(
                                        text: 'Easy Laundry',
                                        weight: FontWeight.w600,
                                        color: AppColors.fontColor,
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      color: Colors.transparent,
                                      width: double.maxFinite,
                                      height: Dimensions.screenHeight / 3,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: Dimensions.width10),
                                      width: double.maxFinite,
                                      //color: Colors.grey.withOpacity(0.2),
                                      child: Column(
                                        children: [
                                          Wrap(
                                            children: [
                                              GetBuilder<
                                                      RecommendedSpecialtyController>(
                                                  builder: (controller) {
                                                return Container(
                                                  color: Colors.transparent,
                                                  height:
                                                      Dimensions.screenWidth /
                                                          1.5,
                                                  width:
                                                      Dimensions.screenWidth /
                                                          1.0,
                                                  child: RefreshIndicator(
                                                    onRefresh:
                                                        _reloadDependencies,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: laundrySpecialties
                                                          .laundrySpecialtyList
                                                          .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        SpecialtyModel
                                                            specialty =
                                                            laundrySpecialties
                                                                    .laundrySpecialtyList[
                                                                index];
                                                        var quantity = (_cartController
                                                            .getQuantity(
                                                                laundrySpecialties
                                                                        .laundrySpecialtyList[
                                                                    index]));
                                                        var price =
                                                            laundrySpecialties
                                                                .laundrySpecialtyList[
                                                                    index]
                                                                .price;
                                                        var itemPrice = _cartController.getQuantity(
                                                                    laundrySpecialties
                                                                            .laundrySpecialtyList[
                                                                        index]) !=
                                                                0
                                                            ? quantity * price
                                                            : laundrySpecialties
                                                                .laundrySpecialtyList[
                                                                    index]
                                                                .price!;

                                                        return GestureDetector(
                                                          onTap: () {
                                                            Get.toNamed(RouteHelper
                                                                .getLaundrySpecialties(
                                                                    index,
                                                                    'home'));
                                                          },
                                                          child: Padding(
                                                            padding: EdgeInsets.only(
                                                                top: Dimensions
                                                                    .height20),
                                                            child: Stack(
                                                              children: [
                                                                //laundry text section
                                                                Container(
                                                                  width: Dimensions
                                                                          .screenWidth /
                                                                      2,
                                                                  height: Dimensions
                                                                          .screenWidth /
                                                                      1.7,
                                                                  margin: EdgeInsets.only(
                                                                      left: Dimensions
                                                                          .width15,
                                                                      right: isSmallestDevice
                                                                          ? Dimensions
                                                                              .width15
                                                                          : Dimensions
                                                                              .width15),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      width:
                                                                          0.5,
                                                                      color: const Color(
                                                                              0xff9A9483)
                                                                          .withOpacity(
                                                                              0.5),
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.radius30),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Spacer(),
                                                                      Spacer(),
                                                                      //Item details
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8,
                                                                            vertical:
                                                                                12),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Container(
                                                                                width: Dimensions.height20 * 4.5,
                                                                                height: Dimensions.height20 * 4.5,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(Dimensions.radius30 * 3),
                                                                                  color: AppColors.fontColor.withOpacity(0.1),
                                                                                ),
                                                                                child: Center(
                                                                                  child: Image(
                                                                                    height: 40,
                                                                                    image: AssetImage(laundrySpecialties.laundrySpecialtyList[index].createAt!),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: Dimensions.height15 / 2,
                                                                              ),
                                                                              IntegerText(
                                                                                size: Dimensions.font20 / 1.2,
                                                                                text: laundrySpecialties.laundrySpecialtyList[index].name!,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: AppColors.fontColor,
                                                                              ),
                                                                              SizedBox(
                                                                                height: Dimensions.height15 / 2,
                                                                              ),
                                                                              IntegerText(
                                                                                size: Dimensions.font20 / 1.4,
                                                                                text: laundrySpecialties.laundrySpecialtyList[index].type!,
                                                                              ),
                                                                              SizedBox(
                                                                                height: Dimensions.height15 / 3,
                                                                              ),
                                                                              IntegerText(size: Dimensions.font20 / 1.4, text: 'R ${itemPrice}.00', fontWeight: FontWeight.w600, color: AppColors.fontColor),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                                //Cart controllers
                                                                Container(
                                                                  width: Dimensions
                                                                          .screenWidth /
                                                                      2,
                                                                  height: Dimensions
                                                                          .screenWidth /
                                                                      1.7,
                                                                  margin: EdgeInsets.only(
                                                                      left: Dimensions
                                                                          .width15,
                                                                      right: isSmallestDevice
                                                                          ? Dimensions
                                                                              .width15
                                                                          : Dimensions
                                                                              .width15),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            12),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment: _cartController.getQuantity(laundrySpecialties.laundrySpecialtyList[index]) == 0
                                                                          ? MainAxisAlignment
                                                                              .end
                                                                          : MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        _cartController.getQuantity(laundrySpecialties.laundrySpecialtyList[index]) !=
                                                                                0
                                                                            ? GestureDetector(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    specialty.isSelected = false;
                                                                                  });
                                                                                  controller.removeSpecialty(laundrySpecialties.laundrySpecialtyList[index]);
                                                                                },
                                                                                child: Container(
                                                                                  width: 35,
                                                                                  height: 35,
                                                                                  child: Center(
                                                                                    child: Icon(
                                                                                      MdiIcons.delete,
                                                                                      size: 30,
                                                                                      color: AppColors.iconColor2,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Container(
                                                                                height: 35,
                                                                              ),
                                                                        specialty.isSelected!
                                                                            ? AnimatedContainer(
                                                                                width: specialty.isSelected! ? 80 : 35,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(40 / 2),
                                                                                  color: Colors.transparent,
                                                                                ),
                                                                                duration: Duration(seconds: 10),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(right: 8.0, bottom: 2),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      GestureDetector(
                                                                                        onTap: () async {
                                                                                          if (_cartController.getQuantity(laundrySpecialties.laundrySpecialtyList[index]) == 1) {
                                                                                            controller.setQuantity(false);
                                                                                            controller.addItem(laundrySpecialties.laundrySpecialtyList[index]);
                                                                                            setState(() {
                                                                                              specialty.isSelected = false;
                                                                                            });
                                                                                          } else {
                                                                                            // Add item
                                                                                            controller.setQuantity(false);
                                                                                            controller.addItem(laundrySpecialties.laundrySpecialtyList[index]);
                                                                                            // Set isSelected to true
                                                                                            setState(() {
                                                                                              specialty.isSelected = true;
                                                                                            });
                                                                                            // Cancel the previous timer if it exists
                                                                                            if (timer != null && timer!.isActive) {
                                                                                              timer!.cancel();
                                                                                            }
                                                                                            // Start a new timer
                                                                                            timer = Timer(Duration(seconds: 4), () {
                                                                                              // Reset isSelected to false after timerDuration seconds
                                                                                              setState(() {
                                                                                                specialty.isSelected = false;
                                                                                              });
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                        child: Container(
                                                                                          width: 32,
                                                                                          height: 32,
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(40 / 1.5),
                                                                                            color: Colors.transparent,
                                                                                            border: Border.all(
                                                                                              color: AppColors.secondary,
                                                                                            ),
                                                                                          ),
                                                                                          child: Icon(
                                                                                            Icons.remove,
                                                                                            color: Color(0xffA0937D),
                                                                                            size: Dimensions.iconSize26 * 1.2,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        '${_cartController.getQuantity(laundrySpecialties.laundrySpecialtyList[index])}',
                                                                                        style: TextStyle(fontSize: Dimensions.font16 * 1.2, fontFamily: 'Poppins', color: AppColors.fontColor, fontWeight: FontWeight.w600),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Container(),
                                                                        Stack(
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () async {
                                                                                Get.toNamed(RouteHelper.getLaundrySpecialties(index, 'home'));
                                                                                // //Initialize timer if it's null
                                                                                // timer ??= Timer(Duration(seconds: 4), () {
                                                                                //   // Reset isSelected to false after timerDuration seconds
                                                                                //   setState(() {
                                                                                //     specialty.isSelected = false;
                                                                                //   });
                                                                                // });
                                                                                //
                                                                                // // Add item
                                                                                //
                                                                                // if (timer!.isActive) {
                                                                                //   // Cancel the previous timer if it exists
                                                                                //   timer!.cancel();
                                                                                //   controller.setQuantity(true);
                                                                                //   controller.addItem(laundrySpecialties.laundrySpecialtyList[index]);
                                                                                //   // Set isSelected to true
                                                                                //   setState(() {
                                                                                //     specialty.isSelected = true;
                                                                                //   });
                                                                                //   // Start a new timer
                                                                                //   timer = Timer(Duration(seconds: 4), () {
                                                                                //     // Reset isSelected to false after timerDuration seconds
                                                                                //     setState(() {
                                                                                //       specialty.isSelected = false;
                                                                                //     });
                                                                                //   });
                                                                                // } else {
                                                                                //   // Start a new timer
                                                                                //   timer = Timer(Duration(seconds: 4), () {
                                                                                //     // Reset isSelected to false after timerDuration seconds
                                                                                //     setState(() {
                                                                                //       specialty.isSelected = false;
                                                                                //     });
                                                                                //   });
                                                                                //   // Set isSelected to true
                                                                                //   setState(() {
                                                                                //     specialty.isSelected = true;
                                                                                //   });
                                                                                //   controller.setQuantity(true);
                                                                                //   controller.addItem(laundrySpecialties.laundrySpecialtyList[index]);
                                                                                // }
                                                                              },
                                                                              child: !specialty.isSelected!
                                                                                  ? Container(
                                                                                      width: 32,
                                                                                      height: 32,
                                                                                      decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(Dimensions.radius15),
                                                                                          gradient: LinearGradient(
                                                                                            begin: Alignment.topRight,
                                                                                            end: Alignment.bottomLeft,
                                                                                            colors: [
                                                                                              AppColors.fontColor.withOpacity(0.2),
                                                                                              const Color(0xff9A9483),
                                                                                            ],
                                                                                          ),
                                                                                          border: _cartController.getQuantity(laundrySpecialties.laundrySpecialtyList[index]) != 0
                                                                                              ? Border.all(
                                                                                                  color: LiveColors.whiteTextColor,
                                                                                                )
                                                                                              : Border.all(
                                                                                                  width: 0.5,
                                                                                                  color: const Color(0xff9A9483).withOpacity(0.5),
                                                                                                )),
                                                                                      child: Center(
                                                                                          child: _cartController.getQuantity(laundrySpecialties.laundrySpecialtyList[index]) != 0
                                                                                              ? Text(
                                                                                                  '${_cartController.getQuantity(laundrySpecialties.laundrySpecialtyList[index])}',
                                                                                                  style: TextStyle(fontSize: Dimensions.font16 * 1.2, fontFamily: 'Mukta', color: LiveColors.whiteTextColor, fontWeight: FontWeight.w600),
                                                                                                )
                                                                                              : Text(
                                                                                                  '+',
                                                                                                  style: TextStyle(fontSize: Dimensions.font16 * 1.2, fontFamily: 'Mukta', color: LiveColors.whiteTextColor, fontWeight: FontWeight.w600),
                                                                                                )
                                                                                          // Icon(
                                                                                          //     Icons.add,
                                                                                          //     color: LiveColors.whiteTextColor,
                                                                                          //     size: Dimensions.iconSize26 * 1.2,
                                                                                          //   ),
                                                                                          ),
                                                                                    )
                                                                                  : Container(
                                                                                      width: 32,
                                                                                      height: 32,
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(40 / 1.5),
                                                                                        color: Colors.transparent,
                                                                                        border: Border.all(
                                                                                          color: AppColors.six,
                                                                                        ),
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: Icon(
                                                                                          Icons.add,
                                                                                          color: AppColors.six,
                                                                                          size: Dimensions.iconSize26 * 1.2,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                            ),
                                                                            // _cartController.getQuantity(laundrySpecialties.laundrySpecialtyList[index]) > 0 && specialty.isSelected == false
                                                                            //     ? GestureDetector(
                                                                            //         onTap: () {
                                                                            //           setState(() {
                                                                            //             specialty.isSelected = true;
                                                                            //           });
                                                                            //           // Start a new timer
                                                                            //           timer = Timer(Duration(seconds: 4), () {
                                                                            //             // Reset isSelected to false after timerDuration seconds
                                                                            //             setState(() {
                                                                            //               specialty.isSelected = false;
                                                                            //             });
                                                                            //           });
                                                                            //         },
                                                                            //         child: Container(
                                                                            //           width: 32,
                                                                            //           height: 32,
                                                                            //           decoration: BoxDecoration(
                                                                            //             borderRadius: BorderRadius.circular(40 / 2),
                                                                            //             color: Colors.transparent,
                                                                            //             border: Border.all(
                                                                            //               color: AppColors.six,
                                                                            //             ),
                                                                            //           ),
                                                                            //           child: Center(
                                                                            //             child: Text(
                                                                            //               '${_cartController.getQuantity(laundrySpecialties.laundrySpecialtyList[index])}',
                                                                            //               style: TextStyle(fontSize: Dimensions.font16 * 1.2, fontFamily: 'Poppins', color: const Color(0xff966C3B), fontWeight: FontWeight.w600),
                                                                            //             ),
                                                                            //           ),
                                                                            //         ),
                                                                            //       )
                                                                            //     : Container()
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : LaundrySkeleton();
                    },
                  ),
                ],
              );
            }),

            ///popular specialties
            //list of services and images
            PopularSpecialtiesSection(
                isSmallestDevice: isSmallestDevice, selected: selected),
            SizedBox(
              height: Dimensions.height20 / 5,
            ),
          ],
        ),
      );
    });
  }

  Container recommended() {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height10 / 2),
      child: Stack(
        children: [
          GetBuilder<RecommendedSpecialtyController>(
              builder: (recommendedSpecialties) {
            return recommendedSpecialties.isLoaded
                ? Container(
                    color: Colors.transparent,
                    height: Dimensions.pageView / 1.4,
                    child: PageView.builder(
                        controller: pageController,
                        itemCount: recommendedSpecialties
                            .recommendedSpecialtyList.length,
                        itemBuilder: (context, position) {
                          return _buildPageItem(
                              position,
                              recommendedSpecialties
                                  .recommendedSpecialtyList[position]);
                        }),
                  )
                : RecommendedSkeleton();
          }),
          GetBuilder<RecommendedSpecialtyController>(
            builder: (recommendedSpecialties) {
              return recommendedSpecialties.isLoaded
                  ? Padding(
                      padding:
                          EdgeInsets.only(top: Dimensions.screenWidth / 1.9),
                      child: Center(
                        child: GetBuilder<RecommendedSpecialtyController>(
                            builder: (recommendedSpecialties) {
                          return DotsIndicator(
                            dotsCount: recommendedSpecialties
                                    .recommendedSpecialtyList.isEmpty
                                ? 1
                                : recommendedSpecialties
                                    .recommendedSpecialtyList.length,
                            position: _currPageValue,
                            decorator: DotsDecorator(
                              activeColor: Color(0xff966C3B),
                              color: Colors.grey[300]!,
                              size: const Size.square(6.5),
                              activeSize: const Size(8, 8),
                              activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                          );
                        }),
                      ),
                    )
                  : Container();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageItem(int index, SpecialtyModel recommendedSpecialty) {
    Matrix4 matrix = Matrix4.identity();
    if (index == _currPageValue.floor()) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currScale, 0);
    } else if (index == _currPageValue.floor() + 1) {
      var currScale =
          _scaleFactor + (_currPageValue - index + 1) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1);
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currScale, 0);
    } else if (index == _currPageValue.floor() - 1) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1);
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currScale, 0);
    } else {
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    }

    return Transform(
      transform: matrix,
      child: GestureDetector(
        onTap: () {
          Get.toNamed(RouteHelper.getRecommendedSpecialities(index, 'home'));
          // RouteHelper.getRecommendedSpecialtyGridView());
        },
        child: Stack(children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(
                  RouteHelper.getRecommendedSpecialities(index, 'home'));
              // RouteHelper.getRecommendedSpecialtyGridView());
            },
            child: Stack(
              children: [
                Container(
                  height: Dimensions.pageViewContainer,
                  margin: EdgeInsets.only(
                      left: Dimensions.width10 / 3,
                      right: Dimensions.width10 / 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xff966C3B).withOpacity(0.4),
                        Color(0xffA0937D).withOpacity(0.4),
                      ],
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(recommendedSpecialty.img!),
                    ),
                    // boxShadow: const [
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     blurRadius: 0.5,
                    //     offset: Offset(1, 2),
                    //   ),
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     blurRadius: 0.5,
                    //     offset: Offset(0, -1),
                    //   ),
                    // ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            height: Dimensions.pageViewContainer,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radius30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Wrap(
                  children: [
                    Container(
                      width: Dimensions.screenWidth / 2,
                      height: Dimensions.height30 * 1.3,
                      padding: EdgeInsets.all(Dimensions.width10 / 1.3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(Dimensions.radius30),
                          topRight: Radius.circular(Dimensions.radius30 * 1.5),
                        ),
                        color: Colors.white.withOpacity(0.85),
                      ),
                      child: Image(
                        fit: BoxFit.fitHeight,
                        image: AssetImage(recommendedSpecialty.time!),
                      ),
                    ),
                  ],
                ),
                // Padding(
                //   padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                //   child: Container(
                //     height: Dimensions.height30 * 1.2,
                //     width: Dimensions.height30 * 3,
                //     padding: EdgeInsets.all(Dimensions.width10 / 1.3),
                //     decoration: BoxDecoration(
                //       borderRadius:
                //           BorderRadius.circular(Dimensions.radius30 * 1.5),
                //       color: Colors.white.withOpacity(0.85),
                //     ),
                //     child: selected
                //         ? PopularCartUpdate(index: index)
                //         : GetWashPopular(
                //             index: index,
                //             selected: selected,
                //           ),
                //   ),
                // ),
              ],
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomRight,
          //   child: Padding(
          //     padding: EdgeInsets.all(Dimensions.height10),
          //     child: Container(
          //       width: Dimensions.screenWidth / 2.2,
          //       height: Dimensions.height30 * 1.1,
          //       decoration: BoxDecoration(
          //         border: Border.all(
          //           width: 1,
          //           color: AppColors.six.withOpacity(0.7),
          //         ),
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(Dimensions.radius30),
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.only(bottom: 3.0),
          //         child: Image(
          //           fit: BoxFit.fitHeight,
          //           image: AssetImage(recommendedSpecialty.time!),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ]),
      ),
    );
  }
}

class PopularSpecialtiesSection extends StatelessWidget {
  const PopularSpecialtiesSection({
    super.key,
    required this.isSmallestDevice,
    required this.selected,
  });

  final bool isSmallestDevice;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (_cartController) {
      return GetBuilder<PopularSpecialtyController>(
        builder: (popularSpecialties) {
          return popularSpecialties.isLoaded
              ? Container(
                  padding: EdgeInsets.only(
                      left: Dimensions.width10, top: Dimensions.height15),
                  width: double.maxFinite,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SizedBox(
                        height: Dimensions.height15 / 3,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: Dimensions.width20,
                          ),
                          BigText(
                            text: 'Popular',
                            weight: FontWeight.w600,
                            color: AppColors.fontColor,
                          ),
                          SizedBox(
                            width: Dimensions.width10,
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            child: BigText(
                              text: '.',
                              color: Colors.black26,
                              weight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            width: Dimensions.width10,
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 1),
                            child: SmallText(
                              text: 'Services',
                              maxLines: 1,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: Dimensions.width10,
                      ),
                      Wrap(
                        children: [
                          Container(
                            color: Colors.transparent,
                            height: Dimensions.screenWidth / 3,
                            width: Dimensions.screenWidth / 1.0,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: popularSpecialties
                                  .popularSpecialtyList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Get.toNamed(
                                        RouteHelper.getPopularSpecialties(
                                            index, 'home'));
                                    // setState(() {
                                    //   selected = !selected;
                                    // });
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: Dimensions.height20 * 14,
                                        height: Dimensions.height20 * 7.2,
                                        margin: EdgeInsets.only(
                                            left: Dimensions.width15,
                                            right: isSmallestDevice
                                                ? Dimensions.width15
                                                : Dimensions.width15),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                popularSpecialties
                                                    .popularSpecialtyList[index]
                                                    .material!,
                                              ),
                                              fit: BoxFit.cover),
                                          gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                            colors: [
                                              Color(0xffA0937D)
                                                  .withOpacity(0.4),
                                              AppColors.six.withOpacity(0.6),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          color: Colors.brown.withOpacity(0.3),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.bottomLeft,
                                        height: Dimensions.height20 * 7.2,
                                        margin: EdgeInsets.only(
                                            left: Dimensions.width15,
                                            right: isSmallestDevice
                                                ? Dimensions.width15
                                                : Dimensions.width15),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: _cartController.getQuantity(
                                                            popularSpecialties
                                                                    .popularSpecialtyList[
                                                                index]) >
                                                        0
                                                    ? 25
                                                    : null,
                                                height: _cartController.getQuantity(
                                                            popularSpecialties
                                                                    .popularSpecialtyList[
                                                                index]) >
                                                        0
                                                    ? 25
                                                    : null,
                                                padding: _cartController.getQuantity(
                                                            popularSpecialties
                                                                    .popularSpecialtyList[
                                                                index]) >
                                                        0
                                                    ? null
                                                    : EdgeInsets.all(
                                                        Dimensions.width10 /
                                                            1.3),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: _cartController.getQuantity(
                                                                popularSpecialties
                                                                        .popularSpecialtyList[
                                                                    index]) >
                                                            0
                                                        ? AppColors.six
                                                        : Colors.black12,
                                                  ),
                                                  borderRadius: _cartController
                                                              .getQuantity(
                                                                  popularSpecialties
                                                                          .popularSpecialtyList[
                                                                      index]) >
                                                          0
                                                      ? BorderRadius.circular(
                                                          40 / 1.5)
                                                      : BorderRadius.circular(
                                                          Dimensions.radius30 *
                                                              1.5),
                                                  color: Colors.transparent,
                                                ),
                                                child: GetWashPopular(
                                                  index: index,
                                                  selected: selected,
                                                ),
                                              ),
                                            ),
                                            Wrap(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(
                                                      Dimensions.width10 / 1.3),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(
                                                              Dimensions
                                                                  .radius30),
                                                      topRight: Radius.circular(
                                                          Dimensions.radius30 *
                                                              1.5),
                                                    ),
                                                    gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topRight,
                                                        end: Alignment
                                                            .bottomLeft,
                                                        colors: [
                                                          Color(0xff9A9483),
                                                          Color(0xffB09B71)
                                                        ]),
                                                  ),
                                                  child: IntegerText(
                                                    maxLines: 3,
                                                    text: popularSpecialties
                                                        .popularSpecialtyList[
                                                            index]
                                                        .name!,
                                                    size:
                                                        Dimensions.font16 / 1.2,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : PopularSkeleton();
        },
      );
    });
  }
}

class PopularCartUpdate extends StatefulWidget {
  const PopularCartUpdate({
    super.key,
    required this.index,
  });
  final int index;

  @override
  State<PopularCartUpdate> createState() => _PopularCartUpdateState();
}

class _PopularCartUpdateState extends State<PopularCartUpdate> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendedSpecialtyController>(builder: (controller) {
      return GetBuilder<CartController>(builder: (_cartController) {
        return GetBuilder<PopularSpecialtyController>(
            builder: (popularSpecialties) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  controller.setQuantity(false);
                  controller.addItem(
                      popularSpecialties.popularSpecialtyList[widget.index]);
                },
                child: Container(
                  // padding: EdgeInsets.symmetric(
                  //   horizontal: Dimensions.width10,
                  //   vertical: Dimensions.height10 / 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 0.5, color: Colors.transparent),
                  ),
                  child: AppIcon(
                    weight: 10,
                    size: 22,
                    iconSize: Dimensions.iconSize24,
                    backgroundColor: Colors.transparent,
                    iconColor: Color(0xffA0937D),
                    icon: Icons.remove,
                  ),
                ),
              ),
              Text(
                '${_cartController.getQuantity(popularSpecialties.popularSpecialtyList[widget.index])}',
                style: TextStyle(
                    fontSize: Dimensions.font16 / 1.2,
                    fontFamily: 'Poppins',
                    color: AppColors.fontColor,
                    fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  controller.setQuantity(true);
                  controller.addItem(
                      popularSpecialties.popularSpecialtyList[widget.index]);
                },
                child: Container(
                  // padding: EdgeInsets.symmetric(
                  //   horizontal: Dimensions.width10,
                  //   vertical: Dimensions.height10 / 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 0.5, color: Colors.transparent),
                  ),
                  child: AppIcon(
                    weight: 10,
                    size: 22,
                    iconSize: Dimensions.iconSize24,
                    backgroundColor: Colors.transparent,
                    iconColor: AppColors.six,
                    icon: Icons.add,
                  ),
                ),
              ),
            ],
          );
        });
      });
    });
  }
}

class GetWashPopular extends StatefulWidget {
  GetWashPopular({
    super.key,
    required this.index,
    required this.selected,
  });

  final int index;
  bool selected;

  @override
  State<GetWashPopular> createState() => _GetWashPopularState();
}

class _GetWashPopularState extends State<GetWashPopular> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendedSpecialtyController>(builder: (controller) {
      return GetBuilder<CartController>(builder: (_cartController) {
        return GetBuilder<PopularSpecialtyController>(
            builder: (popularSpecialties) {
          return GestureDetector(
            child: Center(
              child: IntegerText(
                overFlow: TextOverflow.ellipsis,
                size: Dimensions.font16 / 1.2,
                text: _cartController.getQuantity(popularSpecialties
                            .popularSpecialtyList[widget.index]) !=
                        0
                    ? '${_cartController.getQuantity(popularSpecialties.popularSpecialtyList[widget.index])}'
                    : 'Wash',
                fontWeight: FontWeight.w600,
                color: _cartController.getQuantity(popularSpecialties
                            .popularSpecialtyList[widget.index]) !=
                        0
                    ? AppColors.six
                    : AppColors.fontColor,
              ),
            ),
          );
        });
      });
    });
  }
}
