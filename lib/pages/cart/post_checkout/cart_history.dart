import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/base/no_data_page.dart';
import 'package:izinto/controllers/cart_controller.dart';
import 'package:intl/intl.dart';
import 'package:izinto/routes/route_helper.dart';
import 'package:izinto/utils/colors.dart';
import 'package:izinto/widgets/miscellaneous/app_icon.dart';
import 'package:izinto/widgets/texts/big_text.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import '../../../models/cart_model.dart';
import '../../../utils/dimensions.dart';

class CartHistory extends StatelessWidget {
  const CartHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var getCartHistoryList =
        Get.find<CartController>().getCartHistoryList().reversed.toList();

    Map<String, int> cartItemsPerOrder = Map();

    for (int i = 0; i < getCartHistoryList.length; i++) {
      if (cartItemsPerOrder.containsKey(getCartHistoryList[i].time)) {
        cartItemsPerOrder.update(
            getCartHistoryList[i].time!, (value) => ++value);
      } else {
        cartItemsPerOrder.putIfAbsent(getCartHistoryList[i].time!, () => 1);
      }
    }

    List<int> cartItemsPerOrderToList() {
      return cartItemsPerOrder.entries.map((e) => e.value).toList();
    }

    List<String> cartOrderTimeToList() {
      return cartItemsPerOrder.entries.map((e) => e.key).toList();
    }

    List<int> itemsPerOrder = cartItemsPerOrderToList(); //3, 2

    var listCounter = 0;
    return Scaffold(
        body: Column(
      children: [
        //header or app bar
        Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor))),
          height: Dimensions.height20 * 5,
          width: double.maxFinite,
          padding: EdgeInsets.only(top: Dimensions.height45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BigText(
                text: 'Cart history',
                color: AppColors.mainColor,
                weight: FontWeight.normal,
              ),
              AppIcon(
                icon: Icons.checkroom,
                iconColor: Colors.white54,
                iconSize: 30,
                backgroundColor: Color(0xffa77243),
              )
            ],
          ),
        ),

        //body
        GetBuilder<CartController>(builder: (_cartController) {
          return _cartController.getCartHistoryList().isNotEmpty
              ? Expanded(
                  child: Container(
                  height: Dimensions.height10 * 13,
                  margin: EdgeInsets.only(
                      top: Dimensions.height20,
                      left: Dimensions.width20,
                      right: Dimensions.width20),
                  child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView(
                      children: [
                        for (int i = 0; i < itemsPerOrder.length; i++)
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (() {
                                  DateTime parseDate =
                                      DateFormat('yyyy-MM-dd HH:mm:ss').parse(
                                          getCartHistoryList[listCounter]
                                              .time!);
                                  var inputDate =
                                      DateTime.parse(parseDate.toString());
                                  var outputFormat =
                                      DateFormat('dd MMMM HH:mm');
                                  var outputDate =
                                      outputFormat.format(inputDate);
                                  return SmallText(
                                      text: 'Completed: ' + outputDate,
                                      color: AppColors.iconColor1);
                                }()),
                                SizedBox(
                                  height: Dimensions.height10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Wrap(
                                      direction: Axis.horizontal,
                                      children: List.generate(itemsPerOrder[i],
                                          (index) {
                                        if (listCounter <
                                            getCartHistoryList.length) {
                                          listCounter++;
                                        }
                                        return index <= 2
                                            ? Container(
                                                height: Dimensions.height20 * 4,
                                                width: Dimensions.height20 * 4,
                                                margin: EdgeInsets.only(
                                                    right:
                                                        Dimensions.width10 / 2),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15 /
                                                              2),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,

                                                    //       // image: NetworkImage(
                                                    //       //    AppConstants.BASE_URL+AppConstants.UPLOAD_URL+getCartHistoryList[listCounter-1].img!
                                                    //       // )
                                                    image: AssetImage(
                                                        getCartHistoryList[
                                                                listCounter - 1]
                                                            .img!),
                                                  ),
                                                ),
                                              )
                                            : Container();
                                      }),
                                    ),
                                    Container(
                                      height: Dimensions.height10 * 12,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SmallText(
                                              text: 'Total',
                                              color: AppColors.mainColor2),
                                          BigText(
                                              text:
                                                  itemsPerOrder[i].toString() +
                                                      ' Items',
                                              color: AppColors.titleColor,
                                              weight: FontWeight.normal),
                                          GestureDetector(
                                            onTap: () {
                                              var orderTime =
                                                  cartOrderTimeToList();
                                              Map<int, CartModel> moreOrder =
                                                  {};
                                              for (int j = 0;
                                                  j < getCartHistoryList.length;
                                                  j++) {
                                                if (getCartHistoryList[j]
                                                        .time ==
                                                    orderTime[i]) {
                                                  moreOrder.putIfAbsent(
                                                      getCartHistoryList[j].id!,
                                                      () => CartModel.fromJson(
                                                          (jsonDecode(jsonEncode(
                                                              getCartHistoryList[
                                                                  j])))));
                                                }
                                              }
                                              Get.find<CartController>()
                                                  .setItems = moreOrder;
                                              Get.find<CartController>()
                                                  .addToCartList();
                                              Get.toNamed(
                                                  RouteHelper.getCartPage());
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      Dimensions.width10,
                                                  vertical:
                                                      Dimensions.height10 / 2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radius15 /
                                                            3),
                                                border: Border.all(
                                                    width: 1,
                                                    color: AppColors.mainColor),
                                              ),
                                              child: SmallText(
                                                text: 'one more',
                                                color: AppColors.mainColor,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                            margin: EdgeInsets.only(
                              bottom: Dimensions.height20,
                            ),
                          )
                      ],
                    ),
                  ),
                ))
              : SizedBox(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child:  const Center(
                    child: NoDataPage(
                      text: 'You don\'t have any orders',
                      imgPath: 'assets/image/empty_tub.png', softWrap: true,
                    ),
                  ),
                );
        })
      ],
    ));
  }
}
