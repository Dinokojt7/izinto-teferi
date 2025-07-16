import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/laundry_specialty_controller.dart';
import '../../../../controllers/recommended_specialty_controller.dart';
import '../../../../utils/dimensions.dart';
import '../../../auxiliery_classes/cart_recommended_items_controller.dart';
import '../../../widgets/buttons/blue_text_button.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/hyperText_row.dart';
import '../../../widgets/hypertext_column.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../../../widgets/text_widgets/small_black_text.dart';
import '../../home_view/category_view/view_widgets/add_to_basket.dart';

class CartRecommendedSection extends StatefulWidget {
  const CartRecommendedSection({Key? key}) : super(key: key);

  @override
  State<CartRecommendedSection> createState() => _CartRecommendedSectionState();
}

class _CartRecommendedSectionState extends State<CartRecommendedSection> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendedSpecialtyController>(
        builder: (specialtyController) {
      return Consumer<CartRecommendedItemsController>(
          builder: (context, _cartRecommendedItemsController, child) {
        final List recommendedItems =
            _cartRecommendedItemsController.recommended;
        return Padding(
          padding: EdgeInsets.only(left: 16.0, top: 25.0, right: 16.0),
          child: Column(
            children: [
              GenericHeaderRow(
                headingChild: HeadingStyleText(
                  text: 'Recommended for you \u{1F917}',
                  weight: FontWeight.w600,
                ),
                actionButtonChild: BlueTextButton(
                  text: 'See all',
                  onTap: () {},
                ),
              ),
              Container(
                height: Dimensions.screenHeight / 2.8,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedItems.length,
                  itemBuilder: (_, index) {
                    final item = recommendedItems[index];
                    return Padding(
                      padding: EdgeInsets.only(
                          right: Dimensions.width10 * 1.3,
                          top: Dimensions.height15,
                          bottom: Dimensions.height10 / 2),
                      child: Container(
                        width: Dimensions.screenWidth / 3.50,
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
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15),
                          color: Colors.white,
                        ),
                        child: buildSpecialtyWidget(
                            specialtyController,
                            item['img'],
                            item['price'].toString(),
                            item['introduction'],
                            item['type'],
                            index,
                            recommendedItems,
                            context),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: Dimensions.height15,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: HyperTextColumn(
                      preText: '*Prices include VAT.',
                      firstLink: 'Delivery fee',
                      middleText: 'not included. We accept these ',
                      secondLink: 'means of payment',
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: Dimensions.height20,
              ),
            ],
          ),
        );
      });
    });
  }

  Widget buildSpecialtyWidget(
      var specialtyController,
      String image,
      String price,
      String name,
      String type,
      int index,
      List itemsList,
      BuildContext context) {
    var recommendedListItems =
        Get.find<LaundrySpecialtyController>().laundrySpecialtyList;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image(
            height: 60,
            image: AssetImage(image),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(left: 8.0, top: Dimensions.height10, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallBlackText(
                  text: 'R${price},00*',
                  size: Dimensions.font20 / 1.1,
                  font: 'Poppins',
                  fontWeight: FontWeight.w600),
              SmallBlackText(
                text: name,
                size: Dimensions.font20 / 1.5,
                font: 'Poppins',
                fontWeight: FontWeight.w500,
                overFlow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
              SmallBlackText(
                text: type,
                size: Dimensions.font20 / 1.7,
                font: 'Poppins',
                fontWeight: FontWeight.w300,
                overFlow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        Padding(
          padding:
              EdgeInsets.only(left: 6.0, top: Dimensions.height10, right: 6.0),
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
                        recommendedListItems[index],
                      );
                    },
                    child: AddToBasket(
                      specialtyList: recommendedListItems,
                      index: index,
                      viewContext: context,
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
}
