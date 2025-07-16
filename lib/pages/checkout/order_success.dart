import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:izinto/pages/checkout/order_received.dart';
import 'package:izinto/live/wrapper.dart';
import 'package:izinto/widgets/main_buttons/success_to_order_button.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/gestures.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/big_text.dart';
import '../../widgets/texts/small_text.dart';
import '../notifications/inbox_view.dart';

class OrderSuccess extends StatefulWidget {
  final String orderNumber;
  final String finalOrderAmount;
  final String paymentMethod;
  const OrderSuccess(
      {Key? key,
      required this.orderNumber,
      required this.finalOrderAmount,
      required this.paymentMethod})
      : super(key: key);

  @override
  State<OrderSuccess> createState() => _OrderSuccessState();
}

class _OrderSuccessState extends State<OrderSuccess>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

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

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(now);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: Dimensions.screenWidth / 25,
                  right: Dimensions.screenWidth / 25,
                  top: Dimensions.screenWidth / 20,
                  bottom: Dimensions.screenWidth / 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IntegerText(
                        fontWeight: FontWeight.w600,
                        size: Dimensions.height18,
                        text: 'Confirmation',
                        color: Color(0xFF474745),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Divider(
              color: Colors.black26.withOpacity(0.2),
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              padding: EdgeInsets.only(
                  top: Dimensions.height30,
                  bottom: Dimensions.height30,
                  left: Dimensions.width10,
                  right: Dimensions.width10),
              decoration: BoxDecoration(
                  color: Colors.white,
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
                  borderRadius: BorderRadius.circular(Dimensions.radius15)),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Image(
                          image: const AssetImage('assets/image/easy.png'),
                          width: Dimensions.height20 * 10.0,
                        ),
                      ),
                      Center(
                        child: Lottie.asset('assets/image/check.json',
                            width: Dimensions.height45 * 4,
                            height: Dimensions.height45 * 4,
                            controller: _controller, onLoaded: (composition) {
                          _controller
                            ..duration = composition.duration
                            ..forward();
                        }),
                      ),
                    ],
                  ),
                  SmallText(
                    fontWeight: FontWeight.w600,
                    size: Dimensions.height18,
                    text: 'Thanks, we\'ve received your order.',
                    color: Color(0xFF474745),
                  ),
                  SizedBox(
                    height: Dimensions.screenHeight / 60,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Your order number is ',
                      style: TextStyle(
                        fontSize: Dimensions.height15 * 1.1,
                        fontFamily: 'Hind',
                        color: Color(0xFF474745),
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          // recognizer: TapGestureRecognizer()
                          //   ..onTap = () {
                          //     Get.to(() => const OrderReceived(),
                          //         transition: Transition.fade,
                          //         duration: Duration(seconds: 1));
                          //   },
                          text: widget.orderNumber,
                          style: TextStyle(
                              fontSize: Dimensions.height15 * 1.1,
                              fontFamily: 'Hind',
                              color: Color(0xff966C3B),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  SmallText(
                    fontWeight: FontWeight.w600,
                    size: Dimensions.height15 * 1.1,
                    text: 'Our driver is on the way.',
                    color: Color(0xFF474745),
                  ),
                  SizedBox(
                    height: Dimensions.screenHeight / 60,
                  ),
                  GestureDetector(
                      onTap: () {
                        Get.to(
                          () => OrderReceived(),
                        );
                      },
                      child: SuccessToOrderButton()),
                  SizedBox(
                    height: Dimensions.screenHeight / 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(
                      color: Colors.black26.withOpacity(0.3),
                      height: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SmallText(
                          fontWeight: FontWeight.w600,
                          size: Dimensions.height18,
                          text: 'Izinto On Demand',
                          color: AppColors.mainBlackColor,
                        ),
                        SmallText(
                          fontWeight: FontWeight.w600,
                          size: Dimensions.height18,
                          text: 'R${widget.finalOrderAmount}.00',
                          color: AppColors.mainBlackColor,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(
                      color: Colors.black26.withOpacity(0.3),
                      height: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SmallText(
                          fontWeight: FontWeight.w600,
                          size: Dimensions.height18,
                          text: 'Payment method',
                          color: AppColors.mainBlackColor,
                        ),
                        SmallText(
                          fontWeight: FontWeight.w600,
                          size: Dimensions.height18,
                          text: widget.paymentMethod == 'Cash'
                              ? 'Cash on delivery'
                              : widget.paymentMethod,
                          color: AppColors.mainBlackColor,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(
                      color: Colors.black26.withOpacity(0.3),
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Wrapper()),
                    (route) => false);
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height15,
                ),
                height: Dimensions.screenHeight / 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xffCFC5A5),
                      Color(0xff9A9483),
                    ],
                  ),
                ),
                child: Center(
                  //register
                  child: BigText(
                    text: 'Done',
                    size: Dimensions.font20,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
