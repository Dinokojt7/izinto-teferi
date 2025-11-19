import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/subscription_plans_controller.dart';
import 'package:izinto/paystack/payment_page.dart';
import 'package:http/http.dart' as http;
import 'package:izinto/widgets/main_buttons/phone_auth_button.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../pages/cart/cart_processes_and_widgets/cart_view_controller.dart';
import '../../../pages/cart/re_cart.dart';
import '../../../pages/options/settings_view/terms_of_use.dart';
import '../../../transaction/trasnaction_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../miscellaneous/app_icon.dart';
import '../../texts/integers_and_doubles.dart';
import '../../texts/small_text.dart';

class showSubscriptionSignUp extends StatefulWidget {
  const showSubscriptionSignUp({
    Key? key,
    required this.showDialog,
    // this.channel,
    required this.index,
    this.isShowCartLoader,
    this.showSubscriptionSignUpSwitch,
    this.switchValues,
  }) : super(key: key);

  final ValueNotifier<bool> showDialog;
  // final WebSocketChannel? channel;
  final ValueNotifier<bool>? isShowCartLoader;
  final int index;

  final ValueNotifier<bool>? showSubscriptionSignUpSwitch;
  final ValueNotifier<List<bool>>? switchValues;

  @override
  State<showSubscriptionSignUp> createState() => _showSubscriptionSignUpState();
}

class _showSubscriptionSignUpState extends State<showSubscriptionSignUp> {
  String publicKeyTest = AppConstants.THE_HILL;
  final isShowLoader = ValueNotifier<bool>(true);
  final isLoadThirdDialog = ValueNotifier<bool>(false);
  final bool isLoadingPayment = false;
  String payment = 'not went through';
  final reference = ValueNotifier<String>('');
  int currentSubscriptionOffer = 25;
  List<String> data = [];
  final ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.black87,
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      setState(() {
        isShowLoader.value = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionPlansController>(builder: (plan) {
      final List<Map<String, dynamic>> _content = [
        {
          'image': 'assets/image/subscription_display.jpeg',
          'type': 'LAUNDRY',
          'text': 'Wash a minimum of 5kg laundry per week!',
          'price': plan.subscriptionPlansList[1].laundryPlan!,
          'interval': plan.subscriptionPlansList[1].laundryInterval,
        },
        {
          'image': 'assets/image/carsubscription_display.jpeg',
          'type': 'CAR WASH',
          'text': 'Get a total of 12 standard washes plus 6 bonus callouts!',
          'price': plan.subscriptionPlansList[0].carWashPlan!,
          'interval': plan.subscriptionPlansList[0].carWashInterval,
        },
      ];
      return ValueListenableBuilder(
          valueListenable: isLoadThirdDialog,
          builder: (context, value, _) {
            return ValueListenableBuilder(
                valueListenable: isShowLoader,
                builder: (context, value, _) {
                  return Dialog(
                    backgroundColor: Colors.black38,
                    insetPadding: EdgeInsets.all(0),
                    elevation: 0,
                    child: DefaultTextStyle(
                      style: TextStyle(decoration: TextDecoration.none),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius20),
                            ),
                            child: isShowLoader.value
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  )
                                : Center(
                                    child: Container(
                                      height: Dimensions.screenHeight / 1.5,
                                      width: Dimensions.screenWidth / 1.08,
                                      margin: EdgeInsets.only(
                                          top: Dimensions.screenHeight / 8),
                                      decoration: _buildBoxDecoration(_content),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(
                                                Dimensions.width10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  onTap: () {
                                                    Provider.of<CartViewController>(
                                                            context,
                                                            listen: false)
                                                        .showDialog();
                                                    // widget.showDialog.value =
                                                    //     !widget
                                                    //         .showDialog.value;
                                                    // widget.showSubscriptionSignUpSwitch
                                                    //         ?.value =
                                                    //     !widget
                                                    //         .showSubscriptionSignUpSwitch!
                                                    //         .value;
                                                  },
                                                  child: AppIcon(
                                                    backgroundColor:
                                                        Colors.white,
                                                    weight: 20,
                                                    size: 30,
                                                    icon: Icons.close,
                                                    iconColor:
                                                        Color(0Xff353839),
                                                    iconSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Spacer(
                                            flex: Dimensions.height20.toInt(),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions.width10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IntegerText(
                                                  text: _content[widget.index]
                                                      ['type']!,
                                                  size: Dimensions.font16 * 2,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions.width10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IntegerText(
                                                  text: 'Subscription',
                                                  height: Dimensions.height20 /
                                                      Dimensions.height20,
                                                  size: Dimensions.font16 * 2.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Spacer(
                                            flex: Dimensions.height15 ~/ 2,
                                          ),
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      Dimensions.width10),
                                              child: IntegerText(
                                                align: TextAlign.center,
                                                text: _content[widget.index]
                                                    ['text']!,
                                                size: Dimensions.font16 * 1.4,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.mainBlackColor,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            height: Dimensions.bottomHeightBar /
                                                1.1,
                                            width: Dimensions.screenWidth,
                                            padding: EdgeInsets.only(
                                                top: Dimensions.height10 / 2,
                                                bottom: Dimensions.height10 / 2,
                                                left: Dimensions.width20,
                                                right: Dimensions.width20),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                    Dimensions.radius20 * 2),
                                                topRight: Radius.circular(
                                                    Dimensions.radius20 * 2),
                                              ),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  top:
                                                      Dimensions.height20 / 1.5,
                                                  bottom:
                                                      Dimensions.height20 / 1.5,
                                                  left: Dimensions.width20,
                                                  right: Dimensions.width20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      IntegerText(
                                                        text:
                                                            'R${_content[widget.index]['price'].toString()}',
                                                        size:
                                                            Dimensions.font16 *
                                                                1.06,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .mainBlackColor,
                                                      ),
                                                      SmallText(
                                                        text: _content[
                                                                widget.index]
                                                            ['interval']!,
                                                        size: Dimensions.font16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .mainBlackColor,
                                                      ),
                                                    ],
                                                  ),
                                                  isLoadingPayment
                                                      ? Container(
                                                          height: Dimensions
                                                                  .screenHeight /
                                                              15,
                                                          width: Dimensions
                                                                  .screenWidth /
                                                              2.6,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .topRight,
                                                              end: Alignment
                                                                  .bottomLeft,
                                                              colors: [
                                                                AppColors.six,
                                                                Color(
                                                                    0xff9A9483),
                                                              ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  Dimensions
                                                                          .radius20 *
                                                                      3),
                                                            ),
                                                          ),
                                                          child:
                                                              Transform.scale(
                                                            scale: 0.5,
                                                            child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 3,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.7),
                                                              ),
                                                            ),
                                                          ))
                                                      : SubscribeNowButton(
                                                          index: widget.index,
                                                          isShowSubscriptionSignUp:
                                                              widget.showDialog,
                                                          text: 'Subscribe now',
                                                          amount: _content[
                                                                  widget.index]
                                                              ['price']!,
                                                          isShowLoader:
                                                              isShowLoader,
                                                          isLoadThirdDialog:
                                                              isLoadThirdDialog,
                                                          reference: reference,
                                                          switchValues: widget
                                                              .switchValues!,
                                                        )
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radius30),
                                                color: AppColors.fontColor
                                                    .withOpacity(0.1),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimensions.width10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Get.to(
                                                        () =>
                                                            const TermsOfUse(),
                                                        duration: Duration(
                                                            milliseconds: 100));
                                                  },
                                                  child: IntegerText(
                                                    text: 'Terms & Conditions',
                                                    size:
                                                        Dimensions.font16 / 1.2,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimensions.width10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          });
    });
  }

  BoxDecoration _buildBoxDecoration(List<Map<String, dynamic>> _content) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radius30),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 2.5,
          offset: Offset(1, 1),
        ),
        BoxShadow(
          color: Colors.black12,
          blurRadius: 2.5,
          offset: Offset(1, -1),
        ),
      ],
      color: Colors.white,
      image: DecorationImage(
        alignment: Alignment.topCenter,
        fit: BoxFit.fitWidth,
        image: AssetImage(_content[widget.index]['image']!),
      ),
    );
  }

  @override
  void dispose() {
    // widget.channel?.sink.close();
    super.dispose();
  }
}

class SubscribeNowButton extends StatefulWidget {
  const SubscribeNowButton({
    super.key,
    required this.text,
    required this.amount,
    required this.isShowLoader,
    required this.isLoadThirdDialog,
    required this.reference,
    required this.isShowSubscriptionSignUp,
    required this.index,
    required this.switchValues,
  });

  final String text;
  final int amount;
  final ValueNotifier<bool> isShowLoader;
  final ValueNotifier<bool> isLoadThirdDialog;
  final ValueNotifier<String> reference;
  final ValueNotifier<bool> isShowSubscriptionSignUp;
  final int index;

  final ValueNotifier<List<bool>> switchValues;

  @override
  State<SubscribeNowButton> createState() => _SubscribeNowButtonState();
}

class _SubscribeNowButtonState extends State<SubscribeNowButton> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void _onCancel(Transact transaction) {

  }

  @override
  void initState() {
    super.initState();
  }

  sendConfirmation() async {
    final type = widget.index == 0 ? 'Laundry' : 'Car Wash';
    Map<String, dynamic> updateInitialized = {'$type initialized': 5};
    User? user = await _firebaseAuth.currentUser;
    // Convert the list to a map

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update(updateInitialized);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            setState(() {
              widget.isShowLoader.value = !widget.isShowLoader.value;
              widget.isLoadThirdDialog.value = !widget.isLoadThirdDialog.value;
              Future.delayed(const Duration(seconds: 3), () {
                widget.isShowLoader.value = !widget.isShowLoader.value;
                widget.isShowSubscriptionSignUp.value =
                    !widget.isShowSubscriptionSignUp.value;
              });
            });
            sendConfirmation();
            Get.to(
                () => PaymentPage(
                      amount: '${widget.amount}',
                      reference: widget.reference,
                      type: widget.index == 0 ? 'Laundry' : 'Car Wash',
                      switchValues: widget.switchValues,
                      index: widget.index,
                    ),
                transition: Transition.rightToLeft,
                duration: Duration(milliseconds: 100));
          },
          child: Container(
            height: Dimensions.screenHeight / 15,
            width: Dimensions.screenWidth / 2.6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.six,
                  Color(0xff9A9483),
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(Dimensions.radius20 * 3),
              ),
            ),
            child: Center(
              child: SmallText(
                text: widget.text,
                size: Dimensions.font16 * 1.06,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
