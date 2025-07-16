import 'package:flutter/material.dart';
import 'package:izinto/pages/cart/cart_processes_and_widgets/pay_with_subscription.dart';
import 'package:izinto/pages/cart/cart_processes_and_widgets/price_display.dart';
import '../../../utils/dimensions.dart';
import 'bottom_bar_lever.dart';

class MainBottomContainer extends StatefulWidget {
  const MainBottomContainer({
    super.key,
    required this.totalOrderAmount,
    required this.totalDiscountedCarWashItems,
    required this.totalDiscountedItems,
    required this.isShowDialog,
    required this.laundrySubscription,
    required this.carWashSubscription,
    required this.status,
    required this.washType,
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
    required this.laundryLastDate,
    required this.laundryNextDate,
    required this.carWashLastDate,
    required this.carWashNextDate,
    required this.laundrySwitchValue,
    required this.carWashSwitchValue,
  });

  final int? totalOrderAmount;
  final int totalDiscountedCarWashItems;
  final int totalDiscountedItems;
  final ValueNotifier<bool> isShowDialog;
  final ValueNotifier<int> status;
  final ValueNotifier<int> index;
  final ValueNotifier<String> washType;
  final ValueNotifier<String> lastDate;
  final ValueNotifier<String> nextDate;
  final ValueNotifier<int> itemCount;
  final ValueNotifier<int> discount;
  final ValueNotifier<List<bool>> switchValues;
  final ValueNotifier<bool> laundrySwitchValue;
  final ValueNotifier<bool> carWashSwitchValue;
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

  @override
  State<MainBottomContainer> createState() => _MainBottomContainerState();
}

class _MainBottomContainerState extends State<MainBottomContainer> {
  @override
  Widget build(BuildContext context) {
    final totalDiscountedLaundryItems =
        widget.laundrySwitchValue.value ? widget.totalDiscountedItems : 0;
    final totalDiscountedCarWashItems = widget.carWashSwitchValue.value
        ? widget.totalDiscountedCarWashItems
        : 0;
    return Column(
      children: [
        bottomBarLever(),
        SizedBox(height: Dimensions.height20),
        PriceDisplay(
          totalOrderAmount: widget.totalOrderAmount,
          totalItems:
              (totalDiscountedLaundryItems + totalDiscountedCarWashItems),
        ),
        SizedBox(height: Dimensions.height20 / 1.5),
        PayWithSubscription(
          showDialog: widget.isShowDialog,
          laundrySubscription: widget.laundrySubscription,
          carWashSubscription: widget.carWashSubscription,
          lastDate: widget.lastDate,
          nextDate: widget.nextDate,
          status: widget.status,
          washType: widget.washType,
          itemCount: widget.itemCount,
          discount: widget.discount,
          laundryItemCount: widget.laundryItemCount,
          laundryDiscount: widget.laundryDiscount,
          carWashItemCount: widget.carWashItemCount,
          carWashDiscount: widget.carWashDiscount,
          switchValues: widget.switchValues,
          index: widget.index,
          laundryLastDate: widget.laundryLastDate,
          laundryNextDate: widget.laundryNextDate,
          carWashLastDate: widget.carWashLastDate,
          carWashNextDate: widget.carWashNextDate,
          laundrySwitchValue: widget.laundrySwitchValue,
          carWashSwitchValue: widget.carWashSwitchValue,
        ),
      ],
    );
  }
}
