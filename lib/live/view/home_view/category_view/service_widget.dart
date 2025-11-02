import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/add_to_basket.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../controllers/laundry_specialty_controller.dart';
import '../../../../controllers/popular_specialty_controller.dart';
import '../../../../controllers/recommended_specialty_controller.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/miscellaneous/app_icon.dart';
import '../../../widgets/text_widgets/small_black_text.dart';
import '../controller/home_view_controller.dart';
import '../view_specialty_info/view_specialty_info.dart';

class ServiceWidget extends StatelessWidget {
  final int index;
  final List homeItemList;
  const ServiceWidget({
    Key? key,
    required this.index,
    required this.homeItemList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (_cartController) {
      return GetBuilder<RecommendedSpecialtyController>(
          builder: (specialtyController) {
        return GetBuilder<PopularSpecialtyController>(
            builder: (popularSpecialties) {
          return GestureDetector(
            onTap: () {
              Provider.of<HomeViewController>(context, listen: false)
                  .navigateToNestedWidget(
                context,
                ViewSpecialtyInfo(
                  index: index,
                  homeItemList: homeItemList,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 0.5,
                    offset: Offset(0, 0.8),
                  ),
                ],
                border: Border.all(
                  width: 0.5,
                  color: Colors.black.withOpacity(0.04),
                ),
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                color: Colors.white,
              ),
              child: buildSpecialtyWidget(specialtyController, context),
            ),
          );
        });
      });
    });
  }

  Widget buildSpecialtyWidget(
      var specialtyController, BuildContext viewContext) {
    return GetBuilder<LaundrySpecialtyController>(
        builder: (laundrySpecialties) {
      return GetBuilder<NewCartController>(builder: (_cartController) {
        var _quantity = _cartController.getQuantity(homeItemList[index]);
        var _isInCart = _quantity > 0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image(
                height: 60,
                image: AssetImage(homeItemList[index].img),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 8.0, top: Dimensions.height10, right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmallBlackText(
                      text: 'R${homeItemList[index].price},00*',
                      size: Dimensions.font20 / 1.1,
                      font: 'Poppins',
                      fontWeight: FontWeight.w600),
                  SmallBlackText(
                    text: homeItemList[index].introduction,
                    size: Dimensions.font20 / 1.5,
                    font: 'Poppins',
                    fontWeight: FontWeight.w500,
                    overFlow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  SmallBlackText(
                    text: homeItemList[index].type,
                    size: Dimensions.font20 / 1.7,
                    font: 'Poppins',
                    fontWeight: FontWeight.w300,
                    overFlow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 6.0,
                  // top: Dimensions.height10,
                  right: 6.0),
              child: Container(
                height: Dimensions.height45 / 1.2,
                width: double.maxFinite,
                child: Stack(
                  children: [
                    Positioned(
                      top: 10.0,
                      child: SmallBlackText(
                        text: 'More info',
                        decoration: TextDecoration.underline,
                        size: Dimensions.font20 / 1.8,
                        font: 'Poppins',
                        fontWeight: FontWeight.w600,
                        overFlow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: GestureDetector(
                        onTap: () {
                          specialtyController.setQuantity(true);
                          specialtyController.addItem(
                            homeItemList[index],
                          );
                        },
                        child: AddToBasket(
                          specialtyList: homeItemList,
                          index: index,
                          viewContext: viewContext,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: Dimensions.height10 / 3,
            ),
          ],
        );
      });
    });
  }
}

class BasketButton extends StatelessWidget {
  final IconData icon;
  const BasketButton({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppIcon(
      weight: 10,
      size: 22,
      iconSize: Dimensions.iconSize24,
      backgroundColor: Colors.black,
      iconColor: Colors.white,
      icon: icon,
      //icon: Icons.remove,
    );
  }
}
