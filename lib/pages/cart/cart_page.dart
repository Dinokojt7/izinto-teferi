import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:izinto/base/show_snackbar.dart';
import 'package:izinto/controllers/popular_specialty_controller.dart';
import 'package:izinto/pages/checkout/order_received.dart';
import 'package:izinto/pages/checkout/payment_page.dart';
import 'package:izinto/pages/subscriptions/car_wash_subscription.dart';
import 'package:izinto/routes/route_helper.dart';
import 'package:izinto/utils/colors.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/texts/big_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/recommended_specialty_controller.dart';
import '../../models/user.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/subscription/subscription_in_cart/apply_sub.dart';
import '../../widgets/bottom_delete_sheet.dart';
import '../../widgets/subscription/subscription_in_cart/cart_sub_card.dart';
import '../../widgets/main_buttons/cart_checkout_button.dart';
import '../../widgets/texts/integers_and_doubles.dart';
import '../../widgets/texts/small_text.dart';
import '../../widgets/subscription/subscription_in_cart/sub_column_display.dart';
import '../../live/wrapper.dart';
import '../subscriptions/subscriptions.dart';
import '../auth/access.dart';
import '../auth/login.dart';

class CartPage extends StatefulWidget {
  DateTime? storedTime;
  DateTime? carTime;
  int? availableKilos;
  String? remainingWashes;
  CartPage(
      {this.storedTime,
      this.remainingWashes,
      this.availableKilos,
      this.carTime});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('addresses');
  late Stream<QuerySnapshot> _streamUserInfo;
  int? totalOrderAmount;
  List cart = Get.find<CartController>().getItems;
  List chatRoom = [];
  String quarterlyAmount = '';
  String byAnnualAmount = '';
  int carMonthlyAmount = 0;
  int carQuarterlyAmount = 0;
  bool isDiscounted = false;
  var setAmount = 0;
  String? _name;
  String? _surname;
  String? _phone;
  List? _previousChat;
  bool isProcessing = false;
  double rewardsBalance = 0.0;
  bool hasActiveOrder = false;

  //ApplySubscription
  bool isApplyCarWashSubscription = false;
  bool isApplyDiscount = false;

  //Subscriptions
  int planStatus = 0;
  String startDate = '';
  String carStartDate = '';
  int carPlanStatus = 0;
  bool isLoader = false;
  bool isLoadingLog = false;

  //Open sub panel
  String subType = '';
  bool isViewSubPanel = false;

  //Check last washes
  bool isLaundrySubscriptionActive = false;
  bool isCarWashSubscriptionActive = false;

  //UI
  bool isShowSubCards = false;

  //Check if Cart List has sub items

  @override
  void initState() {
    super.initState();
    ;
    _restrictOrder();
    _getCarSubscriptions();
    // storeDateInFirestore();
    _getSubscriptions();
    _streamUserInfo = _referenceUserInfo.snapshots();
    _getSubscriptionStatus();
    _getUser();
    _getCarWashSubscriptionStatus();
  }

  //Active order
  String orderId = '';
  String _eta = '';
  String orderDetail = 'laundry';
  int orderStatus = 0;

  _reOrder(int? totalOrderAmount, int itemCount) async {
    List cartItemMaps = cart.map((item) => item.toJson()).toList();
    DateTime orderTime = DateTime.now();
    String formattedOrderTime = DateFormat('dd MMM hh:mm').format(orderTime);
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Active")
        .doc('current order')
        .update({
      'total item count': itemCount,
      'New order': cartItemMaps,
      'total order amount': totalOrderAmount,
      'createdAt': formattedOrderTime,
    });
  }

  SendOrderToDatabase(int? totalOrderAmount, int totalItem, List cart,
      List orderMessages, newOrderNumber) async {
    DateTime orderTime = DateTime.now();
    String formattedOrderTime = DateFormat('dd MMM hh:mm').format(orderTime);

    User? user = await _firebaseAuth.currentUser;
    // Convert the list to a map
    List cartItemMaps = cart.map((item) => item.toJson()).toList();
    List chatRoomMaps = chatRoom.map((item) => item.toJson()).toList();

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Active")
        .doc('current order')
        .set({
      'New order': cartItemMaps,
      'fetched by': '',
      'chat room': chatRoomMaps,
      'total order amount': totalOrderAmount,
      'total item count': totalItem,
      'createdAt': formattedOrderTime,
      'order number': newOrderNumber,
      'eta': '',
      'payment type': '',
      'updated delivery slot': '',
      'order status': 0
    });
  }

  _restrictOrder() async {
    User? user = await _firebaseAuth.currentUser;
    // QuerySnapshot snapshot = await FirebaseFirestore.instance
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Active')
        .doc('current order')
        .snapshots()
        .listen((userData) {
      if (mounted) {
        setState(() {
          orderId = userData['order number'];
          orderStatus = userData['order status'];
        });
      }
    });
  }

  _resendToUs(int? totalOrderAmount, int itemCount) async {
    List cartItemMaps = cart.map((item) => item.toJson()).toList();
    DateTime orderTime = DateTime.now();
    String formattedOrderTime = DateFormat('dd MMM hh:mm').format(orderTime);
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'total item count': itemCount,
      'New order': cartItemMaps,
      'total order amount': totalOrderAmount,
      'createdAt': formattedOrderTime,
    });
  }

  SendOrderToUs(String? totalOrderAmount, int totalItem, List cart,
      List orderMessages, String newOrderNumber) async {
    DateTime orderTime = DateTime.now();
    String formattedOrderTime = DateFormat('dd MMM hh:mm').format(orderTime);

    User? user = await _firebaseAuth.currentUser;
    List cartItemMaps = cart.map((item) => item.toJson()).toList();
    List chatRoomMaps = chatRoom.map((item) => item.toJson()).toList();
// Convert the list to a map
    FirebaseFirestore.instance.collection('orders').doc(newOrderNumber).set({
      'user': '$_name $_surname',
      'phone': _phone,
      'chat room': chatRoomMaps,
      'New order': cartItemMaps,
      'fetched by': '',
      'total order amount': totalOrderAmount,
      'total item count': totalItem,
      'createdAt': formattedOrderTime,
      'order number': newOrderNumber,
      'payment type': '',
      'updated delivery slot': '',
      'userId': user?.uid,
      'order status': 0
    });
  }

  void _getUser() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          _name = userData['name'];
          _phone = userData['phone'];
          _surname = userData['surname'];
          rewardsBalance = userData['loyalty'];
        });
    });
  }

  _getDiscountedValue(int totalDiscountedAmount) async {
    final cart = await Get.find<CartController>();
    var totalOrderAmount = cart.totalAmount;

    setState(() {
      setAmount = totalOrderAmount - totalDiscountedAmount;
    });
  }

  _confirmRemove(String item, int index) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return BottomDeleteSheet(
          index: index,
          expected: 'Remove item',
          headerText: 'Remove $item from cart?',
          action: 'Remove',
        );
      },
    );
  }

  carWashDiscount() {
    setState(() {
      isProcessing = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        isProcessing = false;
        isApplyCarWashSubscription = true;
      });
    });
  }

  laundryDiscount() {
    setState(() {
      isProcessing = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        isProcessing = false;
        isApplyDiscount = true;
      });
    });
  }

  calculateRewards(int TotalAmount) async {
    final double currentRewards = await TotalAmount / 1000;
    final double updatedRewards = rewardsBalance + currentRewards;
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update({'loyalty': updatedRewards});
  }

  void _showSubscription(String title, Function applyDiscount) {
    bool isLoader = false;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        isScrollControlled: true,
        useSafeArea: true,
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                          vertical: Dimensions.width30),
                      width: double.infinity,
                      height: Dimensions.screenHeight / 4.5,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
                      ),
                      padding: EdgeInsets.fromLTRB(
                          Dimensions.width20, 0, Dimensions.width20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              title,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: Dimensions.font20,
                                fontFamily: 'Hind',
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          const Divider(
                            indent: 8,
                            endIndent: 8,
                            color: Colors.black26,
                            height: 20,
                          ),
                          SizedBox(
                            height: Dimensions.height30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: Dimensions.font20,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // final cart = await Get.find<CartController>();
                                  // var totalOrderAmount = cart.totalAmount;
                                  applyDiscount;

                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  width: Dimensions.screenWidth / 3.8,
                                  padding: EdgeInsets.only(
                                      left: Dimensions.width20 * 1.2,
                                      right: Dimensions.width15 * 1.2),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 2,
                                          offset: Offset(2, 2),
                                          color: AppColors.mainBlackColor
                                              .withOpacity(0.2),
                                        ),
                                        BoxShadow(
                                          blurRadius: 3,
                                          offset: Offset(-5, -5),
                                          color: AppColors.iconColor1
                                              .withOpacity(0.1),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius15),
                                      border: Border.all(
                                          width: 1,
                                          color: const Color(0xffB09B71)),
                                      color: Colors.white),
                                  child: isLoader
                                      ? Transform.scale(
                                          scale: 0.5,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 5,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(
                                            top: Dimensions.height20 / 1.8,
                                            bottom: Dimensions.height20 / 1.8,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Apply',
                                              style: TextStyle(
                                                fontSize:
                                                    Dimensions.font26 / 1.4,
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  _clearCart() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return BottomDeleteSheet(
          expected: 'Clear cart',
          headerText: 'Clear items?',
          action: 'Clear',
        );
      },
    );
  }

  //Update subscription wash date in Firestore
  Future<void> storeDateInFirestore() async {
    DateTime date = DateTime.now();
    DateTime sevenDaysFromNow =
        date.add(Duration(days: 7)); // Set seven days from now
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update({'date': sevenDaysFromNow});
  }

  //Update car subscription date
  Future<void> storeCarWashDateInFirestore() async {
    DateTime date = DateTime.now();
    DateTime sevenDaysFromNow =
        date.add(Duration(days: 7)); // Set seven days from now
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Subscriptions')
        .doc('car subscription')
        .update({'date': sevenDaysFromNow});
  }

  _getSubscriptionStatus() async {
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Subscriptions')
        .doc('plan')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          Timestamp _timestamp = userData['createdAt'];

          planStatus = userData['remainingKilograms'];
          startDate = _timestamp.toDate().toString();
        });
    });
  }

  _getCarWashSubscriptionStatus() async {
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Subscriptions')
        .doc('car subscription')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          Timestamp _timestamp = userData['createdAt'];

          carStartDate = _timestamp.toDate().toString();

          carPlanStatus = userData['remaining washes'];
        });
    });
  }

  _getSubscriptions() async {
    await FirebaseFirestore.instance
        .collection('plans')
        .doc('laundry')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          quarterlyAmount = userData['quarterly'];
          byAnnualAmount = userData['bi-annual'];
        });
    });
  }

  _getCarSubscriptions() async {
    await FirebaseFirestore.instance
        .collection('plans')
        .doc('car wash')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          carQuarterlyAmount = userData['quarterly'];
          carMonthlyAmount = userData['monthly'];
        });
    });
  }

  void _showSubscriptionPanel(String subType) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        isScrollControlled: true,
        useSafeArea: true,
        context: context,
        builder: (context) {
          return subType == 'laundry'
              ? SubscriptionPage(
                  quarterlyAmount: quarterlyAmount,
                  byAnnualAmount: byAnnualAmount,
                )
              : CarWashSubscription(
                  quarterlyAmount: carQuarterlyAmount,
                  carMonthlyAmount: carMonthlyAmount);
        });
  }

  showSubColumn() {
    setState(() {
      isShowSubCards = !isShowSubCards;
      if (isShowSubCards == false) {
        isViewSubPanel = isShowSubCards;
      }
    });
  }

  showCustomSnackBar(String errorMessage, bool missingUser) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 4),
        backgroundColor: Color(0xff9A9484).withOpacity(0.9),
        content: Container(
          margin: EdgeInsets.zero,
          child: Text(errorMessage),
        ),
        action: SnackBarAction(
          label: missingUser ? 'LOGIN' : 'ADD',
          disabledTextColor: Colors.white,
          textColor: Colors.white,
          onPressed: () {
            Get.to(() => const Wrapper(),
                transition: Transition.fade, duration: Duration(seconds: 1));
          },
        ),
      ),
    );
  }

  showCurrentOrderSnack(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 4),
        backgroundColor: Color(0xff9A9484).withOpacity(0.9),
        content: Container(
          margin: EdgeInsets.zero,
          child: Text(errorMessage),
        ),
        action: SnackBarAction(
          label: 'VIEW',
          disabledTextColor: Colors.white,
          textColor: Colors.white,
          onPressed: () {
            Get.to(() => const OrderReceived(),
                transition: Transition.fade, duration: Duration(seconds: 1));
          },
        ),
      ),
    );
  }

  showExceededLimitSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 4),
        backgroundColor: Color(0xff9A9484).withOpacity(0.9),
        content: Container(
          margin: EdgeInsets.zero,
          child: Text(errorMessage),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date
    DateTime currentDate = DateTime.now();
    widget.storedTime =
        widget.storedTime == null ? DateTime.now() : widget.storedTime;
    // Compare the current date with the target date
    if (currentDate.isAfter(widget.storedTime!)) {
      isLaundrySubscriptionActive = true;
    } else {
      isLaundrySubscriptionActive = false;
    }

    widget.carTime = widget.carTime == null ? DateTime.now() : widget.carTime;
    if (currentDate.isAfter(widget.carTime!)) {
      isCarWashSubscriptionActive = true;
    } else {
      isCarWashSubscriptionActive = false;
    }
    String carFormattedDate = DateFormat('E d MMMM').format(widget.carTime!);
    String formattedDate = DateFormat('E d MMMM').format(widget.storedTime!);
    final user = Provider.of<UserModel?>(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_sharp),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            iconTheme: IconThemeData(
                weight: 900,
                color: AppColors.fontColor,
                size: Dimensions.font20 * 1.5),
            titleTextStyle: TextStyle(
                fontSize: Dimensions.font20 * 1.5,
                color: AppColors.fontColor,
                fontWeight: FontWeight.w700),
            title: Text('Cart'),
            centerTitle: false,
            backgroundColor: Colors.white,
          ),

          body: Stack(
            children: [
              //Cart items list
              Padding(
                padding: EdgeInsets.only(top: Dimensions.height20),
                child: GetBuilder<CartController>(builder: (_cartController) {
                  return _cartController.getItems.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width20),
                          child: Container(
                            child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: GetBuilder<CartController>(
                                  builder: (cartController) {
                                    var _cartList = cartController.getItems;
                                    return ListView.builder(
                                        itemCount: _cartList.length,
                                        itemBuilder: (_, index) {
                                          return Container(
                                            margin: EdgeInsets.only(
                                                top: Dimensions.height30,
                                                bottom:
                                                    Dimensions.height15 / 4),
                                            width: double.maxFinite,
                                            height: Dimensions.height20 * 4,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radius20),
                                            ),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    var popularIndex = Get.find<
                                                            PopularSpecialtyController>()
                                                        .popularSpecialtyList
                                                        .indexOf(
                                                            _cartList[index]
                                                                .specialty!);

                                                    Get.toNamed(RouteHelper
                                                        .getPopularSpecialties(
                                                            popularIndex,
                                                            'cartpage'));

                                                    var recommendedIndex = Get.find<
                                                            RecommendedSpecialtyController>()
                                                        .recommendedSpecialtyList
                                                        .indexOf(
                                                            _cartList[index]
                                                                .specialty!);

                                                    Get.toNamed(RouteHelper
                                                        .getRecommendedSpecialities(
                                                            recommendedIndex,
                                                            'cartpage'));
                                                  },
                                                  //Image Container
                                                  child: Container(
                                                    width: Dimensions.height20 *
                                                        3.5,
                                                    height:
                                                        Dimensions.height20 *
                                                            3.5,
                                                    // margin: EdgeInsets.only(
                                                    //     bottom: Dimensions.height10),
                                                    decoration: BoxDecoration(
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: Colors.white,
                                                          spreadRadius: 1.0,
                                                        )
                                                      ],
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: AssetImage(
                                                              cartController
                                                                  .getItems[
                                                                      index]
                                                                  .img!)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Dimensions
                                                                  .radius15),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: Dimensions.width10,
                                                ),
                                                Expanded(
                                                    child: SizedBox(
                                                  height:
                                                      Dimensions.height20 * 6,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          IntegerText(
                                                            text: cartController
                                                                .getItems[index]
                                                                .name!,
                                                            size: Dimensions
                                                                .font16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .mainColor2,
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(
                                                                  top: Dimensions
                                                                          .height20 /
                                                                      1.3),
                                                              child:
                                                                  IntegerText(
                                                                text:
                                                                    'R ${cartController.getItems[index].price!.toString()}.00',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black54,
                                                                size: Dimensions
                                                                    .font16,
                                                              ),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top: Dimensions
                                                                    .height10,
                                                                bottom: Dimensions
                                                                        .height10 /
                                                                    2,
                                                                // left: Dimensions.width10,
                                                                // right:
                                                                //     Dimensions.width10
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        Dimensions
                                                                            .radius20),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          if (_cartList[index].quantity ==
                                                                              1) {
                                                                            _confirmRemove(_cartList[index].name!,
                                                                                index);
                                                                          } else {
                                                                            cartController.addItem(_cartList[index].specialty!,
                                                                                -1);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          // padding: EdgeInsets.symmetric(
                                                                          //   horizontal: Dimensions.width10,
                                                                          //   vertical: Dimensions.height10 / 2),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                            border:
                                                                                Border.all(width: 1.5, color: Color(0xffA0937D)),
                                                                          ),
                                                                          child:
                                                                              AppIcon(
                                                                            weight:
                                                                                10,
                                                                            size:
                                                                                22,
                                                                            iconSize:
                                                                                Dimensions.iconSize24,
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            iconColor:
                                                                                Color(0xffA0937D),
                                                                            icon:
                                                                                Icons.remove,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: Dimensions
                                                                            .width30,
                                                                      ),
                                                                      SizedBox(
                                                                        width: Dimensions
                                                                            .width30,
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          cartController.addItem(
                                                                              _cartList[index].specialty!,
                                                                              1);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          // padding: EdgeInsets.symmetric(
                                                                          //   horizontal: Dimensions.width10,
                                                                          //   vertical: Dimensions.height10 / 2),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                            border:
                                                                                Border.all(width: 1.5, color: const Color(0xff966C3B)),
                                                                          ),
                                                                          child:
                                                                              AppIcon(
                                                                            weight:
                                                                                10,
                                                                            size:
                                                                                22,
                                                                            iconSize:
                                                                                Dimensions.iconSize24,
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            iconColor:
                                                                                Color(0xff966C3B),
                                                                            icon:
                                                                                Icons.add,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Positioned(
                                                                    left: Dimensions
                                                                            .width30 *
                                                                        1.8,
                                                                    child:
                                                                        IntegerText(
                                                                      color: Colors
                                                                          .black54
                                                                          .withOpacity(
                                                                              0.7),
                                                                      text: _cartList[
                                                                              index]
                                                                          .quantity
                                                                          .toString(),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500, //recommendedSpecialty.inCartItems.toString(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ])
                                                    ],
                                                  ),
                                                ))
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                )),
                          ),
                        )
                      : Container(
                          height: Dimensions.screenHeight / 3,
                          child: Center(
                            child: SmallText(
                              text: "No items",
                              maxLines: 1,
                              color: AppColors.titleColor.withOpacity(0.5),
                              height: 1.5,
                              size: Dimensions.font16,
                              overFlow: TextOverflow.fade,
                            ),
                          ),
                        );
                }),
              ),
              Container(
                color: Colors.white,
                height: Dimensions.bottomHeightBar / 3.3,
              ),
              GetBuilder<CartController>(builder: (_cartController) {
                final String quantityText =
                    _cartController.totalItems == 1 ? 'item' : 'items';
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: Dimensions.width20),
                      alignment: Alignment.topCenter,
                      color: Colors.white,
                      width: Dimensions.screenWidth,
                      height: Dimensions.bottomHeightBar / 3.3,
                      child: _cartController.getItems.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IntegerText(
                                  text: _cartController.totalItems.toString() +
                                      ' ${quantityText}',
                                  size: Dimensions.font16 / 1.1,
                                  color: AppColors.fontColor,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.find<CartController>().clear();
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _clearCart();
                                        },
                                        child: IntegerText(
                                          height: 2,
                                          text: 'Clear cart',
                                          size: Dimensions.font16 / 1.2,
                                          color: Color(0xffA0937D),
                                        ),
                                      ),
                                      SizedBox(
                                        width: Dimensions.width10,
                                      ),
                                      Stack(
                                        children: [
                                          Icon(
                                            MdiIcons.delete,
                                            size: 18,
                                            color: Color(0xffA0937D),
                                          ),
                                          Positioned(
                                            top: 4,
                                            left: 3,
                                            child: Icon(
                                              Icons.close_outlined,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          : Container(),
                    ),
                  ],
                );
              }),
            ],
          ),

          //bottom bar
          bottomNavigationBar: GetBuilder<CartController>(
            builder: (cartController) {
              totalOrderAmount = cartController.totalAmount;
              int totalDiscount = 0;
              int totalDiscountedItems = 0;
              int totalDiscountedCarWashItems = 0;
              int totalCarWashDiscount = 0;
              List<dynamic> orderList = cart;
              List<dynamic> orderMessages = chatRoom;
              String laundryApplied = 'Apply laundry subscription?';

              //Check all subscription items
              final List<dynamic> carWashSubList = [];
              final List<dynamic> laundrySubList = [];

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
                    laundrySubList.add({
                      'img': cartController.getItems[i].img,
                      'name': cartController.getItems[i].name,
                    });

                    totalDiscountedItems +=
                        cartController.getItems[i].quantity!;
                    totalDiscount += (cartController.getItems[i].price! *
                        cartController.getItems[i].quantity!);
                    break;
                }
                switch (cartController.getItems[i].id) {
                  case 401:
                  case 402:
                  case 403:
                  case 404:
                    carWashSubList.add({
                      'img': cartController.getItems[i].img,
                      'name': cartController.getItems[i].name
                    });
                    totalDiscountedCarWashItems +=
                        cartController.getItems[i].quantity!;
                    totalCarWashDiscount += (cartController.getItems[i].price! *
                        cartController.getItems[i].quantity!);
                    break;
                }
              }

              int itemCount = cartController.totalItems;
              return cartController.getItems.isNotEmpty
                  ? Container(
                      height: isShowSubCards
                          ? Dimensions.bottomHeightBar * 2.35
                          : Dimensions.bottomHeightBar * 1.5,
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Container(
                              height: Dimensions.bottomHeightBar * 2.22,
                              padding:
                                  EdgeInsets.only(top: Dimensions.height15),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0,
                                  color: Color(0xff9A9484).withOpacity(0.4),
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                      Radius.circular(Dimensions.radius20 * 2),
                                  topRight:
                                      Radius.circular(Dimensions.radius20 * 2),
                                ),
                              ),
                              child: cartController.getItems.isNotEmpty
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        isShowSubCards
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    left: 8.0,
                                                    right: isViewSubPanel
                                                        ? 0
                                                        : 8.0),
                                                child: Stack(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        subType != 'car wash'
                                                            ? Expanded(
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    if (isLaundrySubscriptionActive &&
                                                                        totalDiscountedItems !=
                                                                            0) {
                                                                      setState(
                                                                          () {
                                                                        isViewSubPanel =
                                                                            !isViewSubPanel;
                                                                        subType =
                                                                            'laundry';
                                                                      });
                                                                    }
                                                                    ;

                                                                    if (user ==
                                                                        null) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          duration:
                                                                              Duration(seconds: 4),
                                                                          elevation:
                                                                              20,
                                                                          backgroundColor:
                                                                              Color(0xff9A9484).withOpacity(0.9),
                                                                          behavior:
                                                                              SnackBarBehavior.floating,
                                                                          content:
                                                                              Container(
                                                                            height:
                                                                                Dimensions.screenHeight / 4,
                                                                            margin:
                                                                                EdgeInsets.zero,
                                                                            child:
                                                                                const Text('Please login to proceed'),
                                                                          ),
                                                                          action:
                                                                              SnackBarAction(
                                                                            label:
                                                                                'LOGIN',
                                                                            disabledTextColor:
                                                                                Colors.white,
                                                                            textColor:
                                                                                Colors.white,
                                                                            onPressed:
                                                                                () {
                                                                              Get.to(() => const Login(), transition: Transition.fade, duration: Duration(seconds: 1));
                                                                            },
                                                                          ),
                                                                        ),
                                                                      );
                                                                    } else if (totalDiscountedItems !=
                                                                            0 &&
                                                                        !isLaundrySubscriptionActive) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              SnackBar(
                                                                        duration:
                                                                            Duration(seconds: 4),
                                                                        elevation:
                                                                            8,
                                                                        backgroundColor:
                                                                            Color(0xff9A9483),
                                                                        behavior:
                                                                            SnackBarBehavior.floating,
                                                                        content:
                                                                            Text('Next active subscription is on $formattedDate'),
                                                                      ));
                                                                    } else if (totalDiscountedItems ==
                                                                        0) {
                                                                      showSnackBar(
                                                                          context,
                                                                          'You don\'t have any laundry items in cart');
                                                                    }
                                                                  },
                                                                  child:
                                                                      cartSubCard(
                                                                    isApplyDiscount:
                                                                        isApplyDiscount,
                                                                    totalDiscountedItems:
                                                                        totalDiscountedItems,
                                                                    isViewSubCard:
                                                                        isViewSubPanel,
                                                                    widget:
                                                                        widget,
                                                                    planStatus:
                                                                        planStatus,
                                                                    isSubscriptionActive:
                                                                        isLaundrySubscriptionActive,
                                                                    formattedDate:
                                                                        formattedDate,
                                                                    type:
                                                                        'Laundry',
                                                                    capacity:
                                                                        'Weight',
                                                                    accountBalance: widget.availableKilos !=
                                                                            null
                                                                        ? '${widget.availableKilos!.toString()}/60kg'
                                                                        : 'N/A'
                                                                            '',
                                                                    icon: Icons
                                                                        .local_laundry_service_outlined,
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(),
                                                        subType != 'car wash'
                                                            ? VerticalDivider(
                                                                color: Color(
                                                                        0xff9A9483)
                                                                    .withOpacity(
                                                                        0.7))
                                                            : Container(),
                                                        isViewSubPanel &&
                                                                subType ==
                                                                    'laundry'
                                                            ? Container()
                                                            : Expanded(
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      isViewSubPanel =
                                                                          true;
                                                                      subType =
                                                                          'car wash';
                                                                    });
                                                                    _getDiscountedValue(
                                                                        totalDiscount);
                                                                    if (user ==
                                                                        null) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          duration:
                                                                              Duration(seconds: 4),
                                                                          elevation:
                                                                              20,
                                                                          backgroundColor:
                                                                              Color(0xff9A9484).withOpacity(0.9),
                                                                          behavior:
                                                                              SnackBarBehavior.floating,
                                                                          content:
                                                                              Container(
                                                                            margin:
                                                                                EdgeInsets.zero,
                                                                            child:
                                                                                const Text('Please login to proceed'),
                                                                          ),
                                                                          action:
                                                                              SnackBarAction(
                                                                            label:
                                                                                'LOGIN',
                                                                            disabledTextColor:
                                                                                Colors.white,
                                                                            textColor:
                                                                                Colors.white,
                                                                            onPressed:
                                                                                () {
                                                                              Get.to(() => const Login(), transition: Transition.fade, duration: Duration(seconds: 1));
                                                                            },
                                                                          ),
                                                                        ),
                                                                      );
                                                                    } else if (totalDiscountedCarWashItems !=
                                                                            0 &&
                                                                        isCarWashSubscriptionActive) {
                                                                      setState(
                                                                          () {
                                                                        isViewSubPanel =
                                                                            true;
                                                                        subType =
                                                                            'car wash';
                                                                      });
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        isApplyCarWashSubscription
                                                                            ? SnackBar(
                                                                                duration: Duration(seconds: 4),
                                                                                elevation: 8,
                                                                                backgroundColor: Color(0xff9A9483),
                                                                                behavior: SnackBarBehavior.floating,
                                                                                content: Text('Car wash subscription applied.'),
                                                                              )
                                                                            : SnackBar(
                                                                                duration: Duration(seconds: 4),
                                                                                elevation: 8,
                                                                                backgroundColor: Color(0xff9A9483),
                                                                                behavior: SnackBarBehavior.floating,
                                                                                content: Text('Apply car wash subscription?'),
                                                                                action: SnackBarAction(
                                                                                  label: carPlanStatus == 0 ? 'SUBSCRIBE' : 'APPLY',
                                                                                  disabledTextColor: Colors.white,
                                                                                  textColor: Colors.white,
                                                                                  onPressed: () {
                                                                                    // newAmount =
                                                                                    //     cartController.totalAmount -
                                                                                    //         totalDiscount;
                                                                                    carPlanStatus == 0 ? _showSubscriptionPanel('car wash') : _showSubscription('Car Wash Subscription', carWashDiscount());
                                                                                  },
                                                                                ),
                                                                              ),
                                                                      );
                                                                    } else if (totalDiscountedCarWashItems !=
                                                                            0 &&
                                                                        !isCarWashSubscriptionActive) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              SnackBar(
                                                                        duration:
                                                                            Duration(seconds: 4),
                                                                        elevation:
                                                                            8,
                                                                        backgroundColor:
                                                                            Color(0xff9A9483),
                                                                        behavior:
                                                                            SnackBarBehavior.floating,
                                                                        content:
                                                                            Text('Next active subscription is on $carFormattedDate'),
                                                                      ));
                                                                    } else if (totalDiscountedCarWashItems ==
                                                                        0) {
                                                                      SnackBar(
                                                                        duration:
                                                                            Duration(seconds: 4),
                                                                        elevation:
                                                                            8,
                                                                        backgroundColor:
                                                                            Color(0xff9A9483),
                                                                        behavior:
                                                                            SnackBarBehavior.floating,
                                                                        content:
                                                                            Text('Items in cart are not covered by car wash subscription.'),
                                                                      );
                                                                    }
                                                                  },
                                                                  child:
                                                                      cartSubCard(
                                                                    isApplyDiscount:
                                                                        isApplyCarWashSubscription,
                                                                    totalDiscountedItems:
                                                                        totalDiscountedCarWashItems,
                                                                    isViewSubCard:
                                                                        isViewSubPanel,
                                                                    widget:
                                                                        widget,
                                                                    planStatus:
                                                                        carPlanStatus,
                                                                    isSubscriptionActive:
                                                                        isCarWashSubscriptionActive,
                                                                    formattedDate:
                                                                        carFormattedDate,
                                                                    type:
                                                                        'Car Wash',
                                                                    capacity:
                                                                        'Washes',
                                                                    accountBalance:
                                                                        '${widget.remainingWashes.toString()}/24',
                                                                    icon: Icons
                                                                        .car_repair,
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                    isViewSubPanel
                                                        ? ApplySub(
                                                            closeSubView: () {
                                                              setState(() {
                                                                isViewSubPanel =
                                                                    false;
                                                              });
                                                            },
                                                            discountedAmount: subType ==
                                                                    'laundry'
                                                                ? totalDiscount
                                                                : totalCarWashDiscount,
                                                            planStatus: subType ==
                                                                    'laundry'
                                                                ? planStatus
                                                                : carPlanStatus,
                                                            subType: subType,
                                                            onSubmitted: subType ==
                                                                    'laundry'
                                                                ? laundryDiscount()
                                                                : carWashDiscount(),
                                                          )
                                                        : Container()
                                                  ],
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  if (user != null) {
                                                    showSubColumn();
                                                  } else {
                                                    showCustomSnackBar(
                                                        'Please login to proceed',
                                                        true);
                                                  }
                                                },
                                                child: Container(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      top: Dimensions.height10 /
                                                          2,
                                                      bottom:
                                                          Dimensions.height10 /
                                                              2,
                                                      left: Dimensions.width10,
                                                      right: Dimensions.width10,
                                                    ),
                                                    child: Container(
                                                      width: Dimensions
                                                          .screenWidth,
                                                      padding: EdgeInsets.only(
                                                        bottom: Dimensions
                                                                .height10 *
                                                            1.5,
                                                        top: Dimensions
                                                                .height10 *
                                                            1.5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black12,
                                                            blurRadius: 2.5,
                                                            offset: Offset(-2,
                                                                -1), // Top-left shadow
                                                          ),
                                                          BoxShadow(
                                                            color:
                                                                Colors.black12,
                                                            blurRadius: 2.5,
                                                            offset: Offset(1,
                                                                2), // Bottom-right shadow
                                                          ),
                                                        ],
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                Dimensions
                                                                    .radius15),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'View subscription details for more payment options',
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: Dimensions
                                                                    .font16 /
                                                                1.1,
                                                            fontFamily: 'Hind',
                                                            letterSpacing: 0.10,
                                                            height: 1.3,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        GestureDetector(
                                          onTap: () {
                                            if (user != null) {
                                              if (orderStatus > 0) {
                                                showCurrentOrderSnack(
                                                    'Please wait for the current order to complete.');
                                              } else {
                                                if (orderId != '') {
                                                  setState(() {
                                                    isLoadingLog = true;
                                                  });
                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 2),
                                                      () async {
                                                    await _reOrder(
                                                        (isApplyDiscount &&
                                                                isApplyCarWashSubscription
                                                            ? totalOrderAmount! -
                                                                (totalCarWashDiscount +
                                                                    totalDiscount)
                                                            : isApplyCarWashSubscription
                                                                ? totalOrderAmount! -
                                                                    totalCarWashDiscount
                                                                : isApplyDiscount
                                                                    ? totalOrderAmount! -
                                                                        totalDiscount
                                                                    : totalOrderAmount),
                                                        itemCount);
                                                    await _resendToUs(
                                                        (isApplyDiscount &&
                                                                isApplyCarWashSubscription
                                                            ? totalOrderAmount! -
                                                                (totalCarWashDiscount +
                                                                    totalDiscount)
                                                            : isApplyCarWashSubscription
                                                                ? totalOrderAmount! -
                                                                    totalCarWashDiscount
                                                                : isApplyDiscount
                                                                    ? totalOrderAmount! -
                                                                        totalDiscount
                                                                    : totalOrderAmount),
                                                        itemCount);
                                                  });
                                                  Get.to(
                                                    () => PaymentPage(),
                                                  );
                                                  setState(() {
                                                    isLoadingLog = false;
                                                  });
                                                } else {
                                                  if (totalOrderAmount! < 100) {
                                                    showExceededLimitSnackBar(
                                                        'Your order should be a minimum of 100 ZAR');
                                                  } else if (totalOrderAmount! >
                                                      12000) {
                                                    showExceededLimitSnackBar(
                                                        'Cart subtotal has exceeded limit');
                                                  } else if (totalOrderAmount! >=
                                                      100) {
                                                    setState(() {
                                                      isLoadingLog = true;
                                                    });
                                                    ;
                                                    final String orderNumber =
                                                        UniqueKey()
                                                            .hashCode
                                                            .toString();
                                                    final _random = Random();
                                                    final letters =
                                                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                                                    final randomLetters =
                                                        letters[_random.nextInt(
                                                                letters
                                                                    .length)] +
                                                            letters[_random
                                                                .nextInt(letters
                                                                    .length)];
                                                    final String
                                                        orderNumberFormatted =
                                                        randomLetters +
                                                            orderNumber.substring(
                                                                orderNumber
                                                                        .length -
                                                                    5);

                                                    Future.delayed(
                                                        const Duration(
                                                            seconds: 2),
                                                        () async {
                                                      await calculateRewards(
                                                          totalOrderAmount! -
                                                              (totalCarWashDiscount +
                                                                  totalDiscount));
                                                      await SendOrderToDatabase(
                                                          (isApplyDiscount &&
                                                                  isApplyCarWashSubscription
                                                              ? totalOrderAmount! -
                                                                  (totalCarWashDiscount +
                                                                      totalDiscount)
                                                              : isApplyCarWashSubscription
                                                                  ? totalOrderAmount! -
                                                                      totalCarWashDiscount
                                                                  : isApplyDiscount
                                                                      ? totalOrderAmount! -
                                                                          totalDiscount
                                                                      : totalOrderAmount),
                                                          itemCount,
                                                          orderList,
                                                          orderMessages,
                                                          orderNumberFormatted);
                                                      await SendOrderToUs(
                                                          (isApplyDiscount &&
                                                                      isApplyCarWashSubscription
                                                                  ? totalOrderAmount! -
                                                                      (totalCarWashDiscount +
                                                                          totalDiscount)
                                                                  : isApplyCarWashSubscription
                                                                      ? totalOrderAmount! -
                                                                          totalCarWashDiscount
                                                                      : isApplyDiscount
                                                                          ? totalOrderAmount! -
                                                                              totalDiscount
                                                                          : totalOrderAmount)
                                                              .toString(),
                                                          itemCount,
                                                          orderList,
                                                          orderMessages,
                                                          orderNumberFormatted);
                                                      if (isApplyDiscount) {
                                                        storeDateInFirestore();
                                                        if (isApplyCarWashSubscription) {
                                                          storeCarWashDateInFirestore();
                                                        }
                                                      }

                                                      //cartController.addToHistory();
                                                      Get.to(
                                                        () => PaymentPage(),
                                                      );

                                                      setState(() {
                                                        isLoadingLog = false;
                                                      });
                                                    });
                                                  }
                                                }
                                              }
                                            } else {
                                              showCustomSnackBar(
                                                  'Please login to proceed',
                                                  true);
                                            }
                                          },
                                          child: CartCheckoutButton(
                                              totalOrderAmount:
                                                  totalOrderAmount,
                                              isProcessing: isProcessing,
                                              isApplyDiscount: isApplyDiscount,
                                              isApplyCarWashSubscription:
                                                  isApplyCarWashSubscription,
                                              totalCarWashDiscount:
                                                  totalCarWashDiscount,
                                              totalDiscount: totalDiscount),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            left: 12,
                            top: 1,
                            child: Center(
                              child: SubColumnGesture(
                                closeSubView: user != null
                                    ? showSubColumn
                                    : showCustomSnackBar(
                                        'Please login to proceed', true),
                                icon: isShowSubCards
                                    ? Icons.keyboard_arrow_down_outlined
                                    : Icons.keyboard_arrow_up_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: Dimensions.screenHeight / 3,
                    );
            },
          ),
        ),
        isLoadingLog
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Center(
                  child: Container(
                    width: Dimensions.height20 * 5.4,
                    height: Dimensions.height20 * 5.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
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
                      border: Border.all(
                        width: 2,
                        color: Colors.white,
                      ),
                      color: Colors.white,
                    ),
                    child: Dialog(
                      insetPadding: EdgeInsets.all(0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Center(
                                child: CircularProgressIndicator(
                              color: const Color(0xffB09B71),
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
