import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/user.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../auth/get_started.dart';
import '../../options/settings_view/get_help_popup.dart';
import 'cart_view_controller.dart';
import 'dialog_text.dart';

class SubscriptionDialog extends StatefulWidget {
  const SubscriptionDialog({
    super.key,
    required this.subscriptionStatus,
    required this.laundryOffer,
    required this.nextDate,
    required this.carWashOffer,
    required this.washType,
    required this.itemCount,
    required this.discount,
    required this.showDialog,
    required this.showSubscriptionSignUp,
    required this.switchValues,
    required this.index,
    this.isToggleSwitch,
    this.lastDate,
    required this.laundrySwitchValue,
    required this.carWashSwitchValue,
  });
  final int subscriptionStatus;
  final int? laundryOffer;
  final int? carWashOffer;
  final String? washType;
  final String? nextDate;
  final String? lastDate;
  final int itemCount;
  final int discount;

  final ValueNotifier<int> index;
  final ValueNotifier<bool> showDialog;
  final ValueNotifier<bool> showSubscriptionSignUp;
  final ValueNotifier<List<bool>> switchValues;
  final ValueNotifier<bool> laundrySwitchValue;
  final ValueNotifier<bool> carWashSwitchValue;
  final ValueNotifier<bool>? isToggleSwitch;

  @override
  State<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getHelpPage() {
    Get.to(() => const GetHelpPopUp(),
        transition: Transition.rightToLeft,
        duration: Duration(milliseconds: 100));
  }

  void _getSubscription(bool isDismissDialog) {
    isDismissDialog = !isDismissDialog;
  }

  //Update subscription wash date in Firestore
  Future<void> storeDateInFirestore(String subscriptionType) async {
    DateTime date = DateTime.now();
    DateTime sevenDaysFromNow =
        date.add(Duration(days: 7)); // Set seven days from now
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
      'last $subscriptionType date': sevenDaysFromNow,
      'current $subscriptionType wash date': date
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    return Consumer<CartViewController>(
        builder: (context, cartViewController, child) {
      final bool isSubscriptionSelected =
          cartViewController.isSubscriptionPayment;
      return GetBuilder<CartController>(builder: (cartController) {
        int totalDiscount = 0;
        int totalDiscountedItems = 0;
        int totalDiscountedCarWashItems = 0;
        int totalCarWashDiscount = 0;
        for (var i = 0; i < cartController.getItems.length; i++) {
          switch (cartController.getItems[i].id) {
            case 59:
            case 16:
            case 17:
            case 10:
            case 11:
            case 14:
            case 13:
            case 15:
            case 58:
              totalDiscountedItems += cartController.getItems[i].quantity!;
              totalDiscount += (cartController.getItems[i].price! *
                  cartController.getItems[i].quantity!);
              break;
          }
          switch (cartController.getItems[i].id) {
            case 401:
            case 402:
            case 403:
            case 404:
              totalDiscountedCarWashItems +=
                  cartController.getItems[i].quantity!;
              totalCarWashDiscount += (cartController.getItems[i].price! *
                  cartController.getItems[i].quantity!);
              break;
          }
        }
        final discountedAmount =
            widget.washType == 'laundry' ? totalDiscount : totalCarWashDiscount;
        final discountedItems = widget.washType == 'laundry'
            ? totalDiscountedItems
            : totalDiscountedCarWashItems;
        final status = widget.subscriptionStatus;
        final String washText = widget.washType == 'laundry'
            ? 'wash up to 5kg of laundry per week.'
            : 'book a weekly wash, and 2 callouts a month.';

        //  final int index = washText == 'laundry' ? 0 : 1;

        final String suffix = discountedItems > 1 ? 'items' : 'item';
        final List<List<String>> switchStates = [
          [
            'Choose ${widget.washType} subscription to apply R${discountedAmount}.00 discount for ${discountedItems} ${widget.washType} ${suffix}?',
            'Apply Discount',
            'Cancel',
            'Pay with subscription'
          ],
          [
            'Are you sure you want to remove the subscription payment for ${widget.washType}?',
            'Remove Discount',
            'Cancel',
            'Remove'
          ]
        ];

        ///This method helps us determine if the payment context is laundry or car wash
        ///it further examine the state of that payment context, upon conclusion it will return a list of Strings
        List<String> choosePayment() {
          if (widget.index.value == 0) {
            return widget.laundrySwitchValue.value
                ? switchStates[0]
                : switchStates[1];
          } else {
            return widget.carWashSwitchValue.value
                ? switchStates[0]
                : switchStates[1];
          }
        }

        final List<List<String>> content = [
          [
            'Your ${widget.washType} subscription plan is not yet active.',
            'Subscribe',
            'Maybe Later',
            'Get Subscription'
          ],
          [
            'You last used your subscription on ${widget.lastDate}, this means your next active subscription is on ${widget.nextDate}.',
            'Get help',
            'Got it',
            'Not Active'
          ],
          choosePayment(),
          [
            'Your current cart does not have any ${widget.washType} items in it. This payment option is not available!',
            'Get help',
            'Got it',
            'Not Available'
          ],
          [
            'Please sign in to continue.',
            'Sign In',
            'Maybe Later',
            'Not Signed In'
          ]
        ];
        return Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 1200),
                  child: isSubscriptionSelected
                      ? dialogText(
                          key: UniqueKey(),
                          text: 'Payment selected',
                          weight: FontWeight.w600,
                          color: AppColors.fontColor,
                          size: Dimensions.font26 / 1.1,
                        )
                      : dialogText(
                          key: UniqueKey(),
                          text: content[status][3],
                          weight: FontWeight.w600,
                          color: AppColors.fontColor,
                          size: Dimensions.font26 / 1.1,
                        ),
                ),
                isSubscriptionSelected
                    ? Center(
                        child: Lottie.asset('assets/image/black-check.json',
                            width: Dimensions.height45 * 1.7,
                            height: Dimensions.height45 * 1.7,
                            controller: _controller, onLoaded: (composition) {
                          _controller
                            ..duration = composition.duration
                            ..forward();
                        }),
                      )
                    : Container(),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 1200),
                  child: isSubscriptionSelected
                      ? dialogText(
                          key: UniqueKey(),
                          text: widget.index.value == 0
                              ? 'Payment selected, your clothes will be weighed upon collection and we\'ll update the capacity on your subscription plan.'
                              : 'Payment selected, we\'ll update the capacity on your subscription plan.',
                          size: Dimensions.font16 / 1.1,
                          color: AppColors.fontColor,
                        )
                      : dialogText(
                          key: UniqueKey(),
                          text: content[status][0],
                          size: Dimensions.font16 / 1.1,
                          color: AppColors.fontColor,
                        ),
                ),
                Column(
                  children: [
                    widget.subscriptionStatus == 1 ||
                            widget.subscriptionStatus == 3 ||
                            isSubscriptionSelected
                        ? Container()
                        : GestureDetector(
                            onTap: () async {
                              if (status == 0) {
                                widget.showDialog.value =
                                    !widget.showDialog.value;
                                // widget.showSubscriptionSignUp.value =
                                //     !widget.showSubscriptionSignUp.value;
                                Provider.of<CartViewController>(context,
                                        listen: false)
                                    .showDialog();
                              } else if (status == 4) {
                                widget.showDialog.value =
                                    !widget.showDialog.value;
                                await Get.to(() => const GetStarted(),
                                    transition: Transition.fade,
                                    duration: Duration(seconds: 1));
                                if (user == null) {
                                  if (widget.index.value == 0) {
                                    widget.laundrySwitchValue.value =
                                        !widget.laundrySwitchValue.value;
                                  } else {
                                    widget.carWashSwitchValue.value =
                                        !widget.carWashSwitchValue.value;
                                  }
                                }
                              } else if (status == 2) {
                                Provider.of<CartViewController>(context,
                                        listen: false)
                                    .changeHeight();
                                widget.isToggleSwitch!.value =
                                    widget.isToggleSwitch!.value;
                                // widget.showDialog.value =
                                //     !widget.showDialog.value;
                                storeDateInFirestore(widget.washType!);
                                // Future.delayed(const Duration(seconds: 2), () {
                                //   widget.isToggleSwitch!.value =
                                //       widget.isToggleSwitch!.value;
                                //   if (widget.index.value == 0) {
                                //     widget.laundrySwitchValue.value =
                                //         !widget.laundrySwitchValue.value;
                                //   } else {
                                //     widget.carWashSwitchValue.value =
                                //         !widget.carWashSwitchValue.value;
                                //   }
                                // });
                              }
                              // widget.subscriptionStatus == 2 ||
                              //         widget.subscriptionStatus == 3
                              //     ? _getHelpPage()
                              //     : _showLoader();
                            },
                            child: dialogLocalButton(
                              text: content[status][1],
                              callAction: 1,
                              color: Colors.white,
                              index: widget.subscriptionStatus,
                            ),
                          ),
                    SizedBox(
                      height: Dimensions.width20 / 1.5,
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.showDialog.value = !widget.showDialog.value;
                        if (widget.index.value == 0) {
                          isSubscriptionSelected
                              ? null
                              : widget.laundrySwitchValue.value =
                                  !widget.laundrySwitchValue.value;
                        } else {
                          if (widget.index.value == 1) {
                            isSubscriptionSelected
                                ? null
                                : widget.carWashSwitchValue.value =
                                    !widget.carWashSwitchValue.value;
                          }
                          // else {
                          //   isSubscriptionSelected
                          //       ? null
                          //       : widget.laundrySwitchValue.value =
                          //           !widget.laundrySwitchValue.value;
                          // }
                        }
                      },
                      child: dialogLocalButton(
                        text: isSubscriptionSelected
                            ? 'Awesome'
                            : content[status][2],
                        callAction: 0,
                        color: AppColors.fontColor,
                        index: widget.subscriptionStatus,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
    });
  }
}
