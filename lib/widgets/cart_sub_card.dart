import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:izinto/utils/colors.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/texts/big_text.dart';
import 'package:izinto/widgets/texts/small_text.dart';

import '../pages/cart/cart_page.dart';

class cartSubCard extends StatelessWidget {
  const cartSubCard({
    Key? key,
    required this.isApplyDiscount,
    required this.totalDiscountedItems,
    required this.isViewSubCard,
    required this.widget,
    required this.planStatus,
    required this.isSubscriptionActive,
    required this.formattedDate,
    required this.type,
    required this.capacity,
    required this.accountBalance,
    required this.icon,
  }) : super(key: key);

  final bool isApplyDiscount;
  final int totalDiscountedItems;
  final String type;
  final IconData icon;
  final String capacity;
  final String accountBalance;
  final bool isViewSubCard;
  final CartPage widget;
  final int planStatus;
  final bool isSubscriptionActive;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenHeight / 5.2,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              offset: Offset(2, 2),
              color: AppColors.mainBlackColor.withOpacity(0.2),
            ),
            BoxShadow(
              blurRadius: 3,
              offset: Offset(-5, -5),
              color: AppColors.iconColor1.withOpacity(0.1),
            ),
          ],
          border: Border.all(
              width: 1.2,
              color: isApplyDiscount
                  ? const Color(0xffCFC5A5)
                  : Color(0xff9A9484).withOpacity(0.4)),
          color: totalDiscountedItems != 0 ? Colors.white : Colors.black12,
          borderRadius: BorderRadius.circular(Dimensions.radius15)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BigText(
                    size: Dimensions.font16,
                    color: totalDiscountedItems != 0
                        ? isApplyDiscount
                            ? AppColors.titleColor
                            : AppColors.titleColor
                        : Colors.white,
                    weight: FontWeight.w600,
                    text: 'Use subscription',
                  ),
                  isViewSubCard
                      ? Container()
                      : Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: Dimensions.font16,
                          color: isApplyDiscount
                              ? AppColors.titleColor
                              : AppColors.titleColor,
                        ),
                ],
              ),
              Row(
                children: [
                  BigText(
                    size: Dimensions.font16,
                    color: totalDiscountedItems != 0
                        ? isApplyDiscount
                            ? const Color(0xffCFC5A5)
                            : Color(0xff9A9483)
                        : Colors.white,
                    weight: FontWeight.w600,
                    text: type,
                  ),
                ],
              ),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                        text: '${capacity}: ',
                        style: TextStyle(
                          color: AppColors.titleColor,
                          fontFamily: 'Hind',
                          letterSpacing: 0.10,
                          fontSize: 14.0,
                          height: 1.8,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: accountBalance,
                            style: TextStyle(
                              color: AppColors.titleColor,
                              fontFamily: 'Hind',
                              letterSpacing: 0.10,
                              fontSize: 14.0,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ]),
                  ),
                ],
              ),
              SizedBox(
                height: Dimensions.height15,
              ),
              planStatus != 0 && isSubscriptionActive
                  ? Row(
                      children: [
                        Container(
                          width: Dimensions.width30 * 3.4,
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 1,
                                offset: Offset(1, 1),
                                color:
                                    AppColors.mainBlackColor.withOpacity(0.2),
                              ),
                              BoxShadow(
                                blurRadius: 1,
                                offset: Offset(-1, -1),
                                color: AppColors.iconColor1.withOpacity(0.1),
                              ),
                            ],
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius20 / 2),
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                totalDiscountedItems != 0
                                    ? Color(0xffCFC5A5)
                                    : Colors.black12,
                                totalDiscountedItems != 0
                                    ? Color(0xff9A9483)
                                    : Colors.black12,
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_laundry_service_outlined,
                                color: Colors.white,
                                size: Dimensions.iconSize16,
                              ),
                              SizedBox(
                                width: Dimensions.width10,
                              ),
                              Text(
                                'Active',
                                style: TextStyle(
                                    fontFamily: 'Hind',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : planStatus != 0 && !isSubscriptionActive
                      ? Row(
                          children: [
                            Row(
                              children: [
                                SmallText(
                                  text: 'Next active: ',
                                  color: AppColors.titleColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: SmallText(
                                    size: Dimensions.font16 / 1.6,
                                    fontWeight: FontWeight.w600,
                                    text: formattedDate,
                                    color: AppColors.titleColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                              width: Dimensions.width30 * 3.8,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 1,
                                    offset: Offset(1, 1),
                                    color: AppColors.mainBlackColor
                                        .withOpacity(0.2),
                                  ),
                                  BoxShadow(
                                    blurRadius: 1,
                                    offset: Offset(-1, -1),
                                    color:
                                        AppColors.iconColor1.withOpacity(0.1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radius20 / 2),
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Colors.black12,
                                    Colors.black12,
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    icon,
                                    color: Colors.white,
                                    size: Dimensions.iconSize16,
                                  ),
                                  SizedBox(
                                    width: Dimensions.width10,
                                  ),
                                  Text(
                                    'Not active',
                                    style: TextStyle(
                                        fontFamily: 'Hind',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
