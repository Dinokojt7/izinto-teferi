import 'package:flutter/material.dart';
import 'package:izinto/pages/cart/cart_processes_and_widgets/price_display.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';

class PayWithSubscription extends StatefulWidget {
  const PayWithSubscription({
    super.key,
    required this.showDialog,
    required this.laundrySubscription,
    required this.carWashSubscription,
    required this.status,
    required this.washType,
    required this.laundryLastDate,
    required this.laundryNextDate,
    required this.carWashLastDate,
    required this.carWashNextDate,
    required this.lastDate,
    required this.nextDate,
    required this.itemCount,
    required this.discount,
    required this.laundryItemCount,
    required this.laundryDiscount,
    required this.carWashItemCount,
    required this.carWashDiscount,
    required this.switchValues,
    required this.index,
    required this.laundrySwitchValue,
    required this.carWashSwitchValue,
  });

  final ValueNotifier<bool> showDialog;
  final ValueNotifier<int> status;
  final ValueNotifier<int> index;
  final ValueNotifier<String> washType;
  final ValueNotifier<String> lastDate;
  final ValueNotifier<String> nextDate;
  final ValueNotifier<int> itemCount;
  final ValueNotifier<int> discount;
  final int laundrySubscription;
  final int carWashSubscription;
  final String laundryLastDate;
  final String laundryNextDate;
  final String carWashLastDate;
  final String carWashNextDate;
  final int laundryItemCount;
  final int laundryDiscount;
  final int carWashItemCount;
  final int carWashDiscount;
  final ValueNotifier<List<bool>> switchValues;
  final ValueNotifier<bool> laundrySwitchValue;
  final ValueNotifier<bool> carWashSwitchValue;
  @override
  State<PayWithSubscription> createState() => _PayWithSubscriptionState();
}

class _PayWithSubscriptionState extends State<PayWithSubscription> {
  // final bool switchValue = false;
  List<List<dynamic>> subscriptions = [];

  // final switchValues =
  //     ValueNotifier<List<bool>>(List.generate(2, (index) => false));
  List<List<dynamic>> subscriptionList = [
    [
      Icon(
        Icons.local_laundry_service_outlined,
        color: Colors.black54,
        size: Dimensions.iconSize16,
      ),
      'Laundry Subscription',
      '60 Kg'
    ],
    [
      Image(
        color: Colors.black54,
        image: AssetImage('assets/image/car-wash.png'),
        width: 30,
      ),
      'Car Wash Subscription',
      '18 Washes'
    ]
  ];

  @override
  void initState() {
    subscriptions = [
      [
        widget.laundrySubscription,
        'laundry',
        widget.laundryLastDate,
        widget.laundryNextDate,
        widget.laundryItemCount,
        widget.laundryDiscount,
      ],
      [
        widget.carWashSubscription,
        'car wash',
        widget.carWashLastDate,
        widget.carWashNextDate,
        widget.carWashItemCount,
        widget.carWashDiscount,
      ]
    ];
    super.initState();
  }

  void handleSwitchChange(int typeIndex) {
    if (subscriptions[typeIndex][0] == 0) {
      // setState(() {
      //   switchValues[typeIndex] = true;
      // });
    } else if (subscriptions[typeIndex][0] == 1) {
    } else if (subscriptions[typeIndex][0] == 2) {
    } else {

    }
  }

  @override
  Widget build(BuildContext context) {
    final switchValueNotifier =
        ValueNotifier<List<bool>>(widget.switchValues.value);
    return Wrap(
      children: [
        Container(
          height: Dimensions.screenWidth / 3,
          width: Dimensions.screenWidth / 1.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                width: Dimensions.screenWidth / 2,
                height: Dimensions.screenWidth / 3,
                margin: EdgeInsets.only(
                  left: Dimensions.width15,
                  right: Dimensions.width15,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius30 * 3),
                  color: AppColors.six.withOpacity(0.7),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextVaried(
                            text: 'Pay with',
                            size: Dimensions.height18 * 0.82,
                          ),
                          ValueListenableBuilder<bool>(
                              valueListenable: widget.laundrySwitchValue,
                              builder: (context, values, child) {
                                return Switch.adaptive(
                                    activeColor: Colors.white,
                                    activeTrackColor: Colors.white54,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    value: widget.laundrySwitchValue.value,
                                    onChanged: (value) {
                                      widget.laundrySwitchValue.value = value;
                                      widget.index.value = 0;
                                      widget.status.value = subscriptions[0][0];
                                      widget.washType.value =
                                          subscriptions[0][1];
                                      widget.showDialog.value =
                                          !widget.showDialog.value;
                                      widget.lastDate.value =
                                          subscriptions[0][2];
                                      widget.nextDate.value =
                                          subscriptions[0][3];
                                      widget.itemCount.value =
                                          subscriptions[0][4];
                                      widget.discount.value =
                                          subscriptions[0][5];
                                      // widget.switchValue.value = value;
                                    });
                              })
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              width: Dimensions.height45 / 1.4,
                              height: Dimensions.height45 / 1.8,
                              decoration: thisWidgetDecoration(),
                              child: subscriptionList[0][0]),
                          SizedBox(width: Dimensions.width10 / 2),
                          TextVaried(
                            text: subscriptionList[0][1],
                            size: Dimensions.height18 * 0.62,
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.height15),
                      Padding(
                        padding:
                            EdgeInsets.only(left: Dimensions.width10 / 2.5),
                        child: Row(
                          children: [
                            TextVaried(
                              text: '0 / ${subscriptionList[0][2]}',
                              size: Dimensions.height18 * 0.62,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: Dimensions.screenWidth / 2,
                height: Dimensions.screenWidth / 3,
                margin: EdgeInsets.only(
                  left: Dimensions.width15,
                  right: Dimensions.width15,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius30 * 3),
                  color: AppColors.six.withOpacity(0.7),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextVaried(
                            text: 'Pay with',
                            size: Dimensions.height18 * 0.82,
                          ),
                          ValueListenableBuilder<bool>(
                              valueListenable: widget.carWashSwitchValue,
                              builder: (context, values, child) {
                                return Switch.adaptive(
                                    activeColor: Colors.white,
                                    activeTrackColor: Colors.white54,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    value: widget.carWashSwitchValue.value,
                                    onChanged: (value) {
                                      widget.carWashSwitchValue.value = value;
                                      widget.index.value = 1;
                                      widget.status.value = subscriptions[1][0];
                                      widget.washType.value =
                                          subscriptions[1][1];
                                      widget.showDialog.value =
                                          !widget.showDialog.value;
                                      widget.lastDate.value =
                                          subscriptions[1][2];
                                      widget.nextDate.value =
                                          subscriptions[1][3];
                                      widget.itemCount.value =
                                          subscriptions[1][4];
                                      widget.discount.value =
                                          subscriptions[1][5];
                                      // widget.switchValue.value = value;
                                    });
                              })
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              width: Dimensions.height45 / 1.4,
                              height: Dimensions.height45 / 1.8,
                              decoration: thisWidgetDecoration(),
                              child: subscriptionList[1][0]),
                          SizedBox(width: Dimensions.width10 / 2),
                          TextVaried(
                            text: subscriptionList[1][1],
                            size: Dimensions.height18 * 0.62,
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.height15),
                      Padding(
                        padding:
                            EdgeInsets.only(left: Dimensions.width10 / 2.5),
                        child: Row(
                          children: [
                            TextVaried(
                              text: '0 / ${subscriptionList[1][2]}',
                              size: Dimensions.height18 * 0.62,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ListView.builder(
          //   scrollDirection: Axis.horizontal,
          //   itemCount: 2,
          //   itemBuilder: (context, index) {
          //     return Container(
          //       width: Dimensions.screenWidth / 2,
          //       height: Dimensions.screenWidth / 3,
          //       margin: EdgeInsets.only(
          //         left: Dimensions.width15,
          //         right: Dimensions.width15,
          //       ),
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(Dimensions.radius30 * 3),
          //         color: AppColors.six.withOpacity(0.7),
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.only(left: 8.0, right: 8),
          //         child: Column(
          //           children: [
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 TextVaried(
          //                   text: 'Pay with',
          //                   size: Dimensions.height18 * 0.82,
          //                 ),
          //                 ValueListenableBuilder<List<bool>>(
          //                     valueListenable: switchValueNotifier,
          //                     builder: (context, values, child) {
          //                       return Switch.adaptive(
          //                           activeColor: Colors.white,
          //                           activeTrackColor: Colors.white54,
          //                           materialTapTargetSize:
          //                               MaterialTapTargetSize.shrinkWrap,
          //                           value: switchValueNotifier.value[index],
          //                           onChanged: (value) {
          //                             // Update the value of switchValueNotifier
          //                             switchValueNotifier.value[index] = value;
          //                             //   widget.switchValues.value[index] = value;
          //                             widget.index.value = index;
          //                             widget.status.value =
          //                                 subscriptions[index][0];
          //                             widget.washType.value =
          //                                 subscriptions[index][1];
          //                             widget.showDialog.value =
          //                                 !widget.showDialog.value;
          //                             widget.lastDate.value =
          //                                 subscriptions[index][2];
          //                             widget.nextDate.value =
          //                                 subscriptions[index][3];
          //                             widget.itemCount.value =
          //                                 subscriptions[index][4];
          //                             widget.discount.value =
          //                                 subscriptions[index][5];
          //                             // widget.switchValue.value = value;
          //                           });
          //                     })
          //               ],
          //             ),
          //             Row(
          //               children: [
          //                 Container(
          //                     width: Dimensions.height45 / 1.4,
          //                     height: Dimensions.height45 / 1.8,
          //                     decoration: thisWidgetDecoration(),
          //                     child: subscriptionList[index][0]),
          //                 SizedBox(width: Dimensions.width10 / 2),
          //                 TextVaried(
          //                   text: subscriptionList[index][1],
          //                   size: Dimensions.height18 * 0.62,
          //                 ),
          //               ],
          //             ),
          //             SizedBox(height: Dimensions.height15),
          //             Padding(
          //               padding:
          //                   EdgeInsets.only(left: Dimensions.width10 / 2.5),
          //               child: Row(
          //                 children: [
          //                   TextVaried(
          //                     text: '0 / ${subscriptionList[index][2]}',
          //                     size: Dimensions.height18 * 0.62,
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ),
      ],
    );
  }

  BoxDecoration thisWidgetDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radius20 / 1.3),
      color: Colors.white.withOpacity(0.7),
    );
  }
}
