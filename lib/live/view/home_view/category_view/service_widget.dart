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
import '../../../../models/new_specialty_model.dart';
import '../../../../models/popular_specialty_model.dart';
import '../../../../models/recommended_specialty_model.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/miscellaneous/app_icon.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../../widgets/text_widgets/small_black_text.dart';
import '../controller/home_view_controller.dart';
import '../view_specialty_info/view_specialty_info.dart';

class ServiceWidget extends StatefulWidget {
  final int index;
  final List homeItemList;
  const ServiceWidget({
    Key? key,
    required this.index,
    required this.homeItemList,
  }) : super(key: key);

  @override
  State<ServiceWidget> createState() => _ServiceWidgetState();
}

class _ServiceWidgetState extends State<ServiceWidget> {
  @override
  Widget build(BuildContext context) {
    // ✅ Add bounds checking at the start
    if (widget.index >= widget.homeItemList.length) {
      return Container(); // Return empty container if index is out of bounds
    }

    return GetBuilder<NewCartController>(builder: (_cartController) {
      return GestureDetector(
        onTap: () {
          setState(() {
            SystemNavigation().applyCustomSystemChromeSettings(
                Colors.white, Brightness.dark, Colors.white, Brightness.dark);
          });
          Get.to(
            () => ViewSpecialtyInfo(
              index: widget.index,
              homeItemList: widget.homeItemList,
              shouldReturnToBlack: true,
            ),
            transition: Transition.native,
            duration: Duration(milliseconds: 500),
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
          child: buildSpecialtyWidget(_cartController, context),
        ),
      );
    });
  }

  Widget buildSpecialtyWidget(
      NewCartController cartController, BuildContext viewContext) {
    // ✅ Add bounds checking here too
    if (widget.index >= widget.homeItemList.length) {
      return Container();
    }

    var item = widget.homeItemList[widget.index];
    var _quantity = cartController.getQuantity(item);
    var _isInCart = _quantity > 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image(
            height: 60,
            image: AssetImage(_getImage(item)),
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 60,
                child: Icon(Icons.error_outline, color: Colors.grey),
              );
            },
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(left: 8.0, top: Dimensions.height10, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallBlackText(
                  text: 'R${_getPrice(item)},00*',
                  size: Dimensions.font20 / 1.1,
                  font: 'Poppins',
                  fontWeight: FontWeight.w600),
              SmallBlackText(
                text: _getIntroduction(item),
                size: Dimensions.font20 / 1.5,
                font: 'Poppins',
                fontWeight: FontWeight.w500,
                overFlow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
              SmallBlackText(
                text: _getType(item),
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
          padding: EdgeInsets.only(left: 6.0, right: 6.0),
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
                  left: _quantity > 0 ? 0.0 : null,
                  right: 0.0,
                  bottom: 0.0,
                  child: GestureDetector(
                    onTap: () {
                      cartController.addItem(item, 1);
                    },
                    child: AddToBasket(
                      specialtyList: widget.homeItemList,
                      index: widget.index,
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
  }

  // Helper methods to handle both model types
  String _getImage(dynamic item) {
    if (item is NewSpecialtyModel) return item.img ?? '';
    if (item is SpecialtyModel) return item.img ?? '';
    if (item is Specialties) return item.img ?? '';
    return '';
  }

  int _getPrice(dynamic item) {
    if (item is NewSpecialtyModel) return item.firstPrice;
    if (item is SpecialtyModel) return item.price ?? 0;
    if (item is Specialties) return item.price ?? 0;
    return 0;
  }

  String _getIntroduction(dynamic item) {
    if (item is NewSpecialtyModel) return item.introduction ?? '';
    if (item is SpecialtyModel) return item.introduction ?? '';
    if (item is Specialties) return item.introduction ?? '';
    return '';
  }

  String _getType(dynamic item) {
    if (item is NewSpecialtyModel) return item.type ?? '';
    if (item is SpecialtyModel) return item.type ?? '';
    if (item is Specialties) return item.type ?? '';
    return '';
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
