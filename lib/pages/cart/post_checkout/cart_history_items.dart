import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:izinto/pages/cart/post_checkout/cart_history.dart';
import 'package:izinto/pages/cart/re_cart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../../base/no_data_page.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/user.dart';
import '../../../routes/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/miscellaneous/app_icon.dart';
import '../../../widgets/texts/big_text.dart';
import '../../../widgets/flutter_analog.dart';
import '../../../widgets/texts/integers_and_doubles.dart';
import '../../../widgets/texts/small_text.dart';
import '../../auth/email_sign_in.dart';
import '../../auth/get_started.dart';
import '../../checkout/order_received.dart';
import '../../home/home_page.dart';
import '../../../live/wrapper.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

class CartHistoryItems extends StatefulWidget {
  const CartHistoryItems({Key? key}) : super(key: key);
  @override
  _CartHistoryItemsState createState() => _CartHistoryItemsState();
}

class _CartHistoryItemsState extends State<CartHistoryItems> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? totalOrderAmount;
  String? orderId;
  bool isPageReady = true;
  String street = '';
  String address = '';
  String admin = '';
  String area = '';
  String zipCode = '';
  String _venueType = '';
  String? _currentTime = DateTime.now().toString();
  var now = new DateTime.now();
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('users');
  late Stream<QuerySnapshot> _streamUserInfo;
  late List _orderHistory = [];
  late List<dynamic> _currentOrder = [];
  late String _orderDate = '';

  late List<dynamic> orderItems = [];
  late dynamic orderSpecialties = [];
  late String timeOfOrder = '';
  late String thumb = '';
  late String _eta = '';

  @override
  void initState() {
    super.initState();
    _deleteNull();
    _streamUserInfo = _referenceUserInfo.snapshots();
    _getData();
    _orders();

    // wait for the orders to load
    Future.delayed(Duration(seconds: 4)).then((_) {
      if (mounted) {
        setState(() {
          isPageReady = false;
        });
      }
    });
  }

  List<List<Color>> orderStatusProgressIndicator = [
    [
      //Pending or canceled
      Colors.red,
      Colors.red,
      Colors.red,
      Colors.red
    ],
    //Pickup
    [
      Colors.green,
      Colors.green.withOpacity(0.5),
      Colors.green.withOpacity(0.1),
      Colors.green.withOpacity(0.1)
    ],
    //Washing
    [
      Colors.green,
      Colors.green,
      Colors.green.withOpacity(0.1),
      Colors.green.withOpacity(0.1)
    ],

    //Delivery
    [
      Colors.green,
      Colors.green,
      Colors.green.withOpacity(0.5),
      Colors.green.withOpacity(0.5)
    ],

    //Completed
    [Colors.green, Colors.green, Colors.green, Colors.green],
  ];

  //Status of viewed order
  List<List<String>> orderStatusDescription = [
    ['Cancelled', 'There\'s been an error'],
    ['Pickup', 'Driver is on their way'],
    ['Washing', 'Your laundry is being washed'],
    ['Delivery', 'Clean laundry on its way to you'],
    ['Completed', 'This order has been completed']
  ];
  late int orderStatusCode;

  void _getData() async {
    User? user = await _firebaseAuth.currentUser;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Active")
        .doc('current order')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          orderItems = userData['New order'];
          _eta = userData['eta'];
          orderId = userData['order number'];
          orderStatusCode = userData['order status'];
          street = userData['street'];
          address = userData['address'];
        });
    });
  }

  void _deleteNull() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Orders")
        .doc('null')
        .delete();
  }

  void _orders() async {
    User? user = await _firebaseAuth.currentUser;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Orders")
        .get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;
    if (mounted)
      setState(() {
        _orderHistory = docs;
        docs.forEach((doc) {
          if (doc.id != 'current order') {
            Object? data = doc.data();

            print(doc.id);
            final items = (data as Map<String, dynamic>)['order items'][0];
            final orderInitiated = (data)['createdAt'];
            timeOfOrder = orderInitiated;
            orderSpecialties = items;
            final images = (data)['order items'][0]['img'];

            print(images);
            thumb = images;
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    var result = false;

    if (user == null) {
      return WithoutUser();
    } else {
      return isPageReady
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xffB09B71),
                ),
              ),
            )
          : Scaffold(
              body: StreamBuilder<QuerySnapshot>(
                stream: _streamUserInfo,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    print(
                      snapshot.error.toString(),
                    );
                    Center(
                      child: Text(
                        (snapshot.error.toString()),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.active) {
                    QuerySnapshot querySnapshot = snapshot.data;
                    return SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //top
                            Container(
                              height: Dimensions.height20 * 6,
                              width: double.maxFinite,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: Dimensions.width20,
                                      ),
                                      Text(
                                        'Orders',
                                        style: TextStyle(
                                            fontSize: Dimensions.height18 +
                                                Dimensions.height18,
                                            color: AppColors.fontColor,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: Dimensions.width20 - 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade100,
                                            spreadRadius: 1.2,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                orderId != null
                                    ? Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              orderStatusCode == 0
                                                  ? Get.to(
                                                      () => ReCart(),
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                    )
                                                  : Get.to(
                                                      () => OrderReceived(),
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                    );
                                            },
                                            child: SizedBox(
                                              height: Dimensions.height30 * 8.7,
                                              width: Dimensions.width20 * 19,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        Dimensions.width10,
                                                    vertical:
                                                        Dimensions.height10 /
                                                            2.3),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 2,
                                                      offset: Offset(2, 1),
                                                      color: AppColors
                                                          .mainBlackColor
                                                          .withOpacity(0.2),
                                                    ),
                                                    BoxShadow(
                                                      blurRadius: 3,
                                                      offset: Offset(-5, -5),
                                                      color: AppColors
                                                          .iconColor1
                                                          .withOpacity(0.1),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        IntegerText(
                                                          color: const Color(
                                                              0Xff353839),
                                                          text:
                                                              'Your current order',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          size: Dimensions
                                                                  .height15 +
                                                              Dimensions
                                                                  .height10,
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 3),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 1,
                                                                color: orderStatusCode ==
                                                                        0
                                                                    ? Colors.red
                                                                    : Color(0xff9A9484)
                                                                        .withOpacity(
                                                                            0.7)),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    2, 2),
                                                                color: AppColors
                                                                    .mainBlackColor
                                                                    .withOpacity(
                                                                        0.2),
                                                              ),
                                                              BoxShadow(
                                                                blurRadius: 3,
                                                                offset: Offset(
                                                                    -5, -5),
                                                                color: AppColors
                                                                    .iconColor1
                                                                    .withOpacity(
                                                                        0.1),
                                                              ),
                                                            ],
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    Dimensions
                                                                        .radius15),
                                                            color:
                                                                orderStatusCode == 0
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .green,
                                                          ),
                                                          child: Text(
                                                            '${orderId}',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
                                                                color: orderStatusCode ==
                                                                        0
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          Dimensions.height10,
                                                    ),
                                                    OrderAddress(
                                                        venueType: _venueType,
                                                        street: street,
                                                        address: address),
                                                    Column(
                                                      children: [
                                                        SizedBox(
                                                          height: Dimensions
                                                              .height15,
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                              left: Dimensions
                                                                      .width10 /
                                                                  2,
                                                              right: Dimensions
                                                                      .width10 /
                                                                  2),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height: Dimensions
                                                                        .height15 /
                                                                    2,
                                                              ),
                                                              Container(
                                                                height: Dimensions
                                                                        .height15 /
                                                                    3,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .green
                                                                            .withOpacity(
                                                                                0.2)),
                                                                    gradient: LinearGradient(
                                                                        colors: orderStatusProgressIndicator[
                                                                            orderStatusCode],
                                                                        begin: Alignment
                                                                            .centerLeft,
                                                                        end: Alignment
                                                                            .centerRight)),
                                                              ),
                                                              SizedBox(
                                                                height: Dimensions
                                                                        .height15 /
                                                                    2,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  IntegerText(
                                                                    color: const Color(
                                                                        0Xff353839),
                                                                    text:
                                                                        'Status: ${orderStatusDescription[orderStatusCode][0]}',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    size: Dimensions
                                                                            .font16 /
                                                                        1.3,
                                                                  ),
                                                                  RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      text:
                                                                          'ETA: $_eta',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            Dimensions.font16 /
                                                                                1.3,
                                                                        fontFamily:
                                                                            'Poppins',
                                                                        color: const Color(
                                                                            0Xff353839),
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          style: TextStyle(
                                                                              fontSize: Dimensions.font16 / 1.4,
                                                                              fontFamily: 'Poppins',
                                                                              color: const Color(0Xff353839),
                                                                              fontWeight: FontWeight.w300),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          Dimensions.height15,
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      height: Dimensions
                                                              .bottomHeightBar /
                                                          1.5,
                                                      margin: EdgeInsets.only(
                                                          left: Dimensions
                                                                  .width10 /
                                                              2,
                                                          right: Dimensions
                                                                  .width10 /
                                                              2),
                                                      child: MediaQuery
                                                          .removePadding(
                                                        removeTop: true,
                                                        context: context,
                                                        child: Container(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Wrap(
                                                                    direction: Axis
                                                                        .horizontal,
                                                                    children: List.generate(
                                                                        orderItems.length <
                                                                                4
                                                                            ? orderItems
                                                                                .length
                                                                            : 3,
                                                                        (i) {
                                                                      final item =
                                                                          orderItems[
                                                                              i];
                                                                      String?
                                                                          itemImage =
                                                                          item[
                                                                              'img'];
                                                                      String?
                                                                          quantity =
                                                                          item['quantity']
                                                                              .toString();

                                                                      return Container(
                                                                        height:
                                                                            Dimensions.height20 *
                                                                                3,
                                                                        width:
                                                                            Dimensions.height20 *
                                                                                3,
                                                                        margin: EdgeInsets.only(
                                                                            right:
                                                                                Dimensions.width10),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(4),
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
                                                                          image: DecorationImage(
                                                                              fit: BoxFit.cover,
                                                                              image: AssetImage(itemImage!)),
                                                                        ),
                                                                      );
                                                                    }),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          margin:
                                                              EdgeInsets.only(
                                                            bottom: Dimensions
                                                                .height20,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    SizedBox(
                                                      height:
                                                          Dimensions.height18,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : NoActiveOrder(),
                              ],
                            ),
                            SizedBox(
                              height: Dimensions.height30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: Dimensions.width20,
                                ),
                                IntegerText(
                                  size:
                                      Dimensions.height15 + Dimensions.height10,
                                  text: 'What you\'ve washed',
                                  color: const Color(0Xff353839),
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),

                            //list
                            _orderHistory.length == 0
                                ? Container(
                                    height: Dimensions.screenHeight / 3,
                                    child: Center(
                                      child: SmallText(
                                        text: "Nothing else",
                                        maxLines: 1,
                                        color: AppColors.titleColor
                                            .withOpacity(0.5),
                                        height: 1.5,
                                        size: Dimensions.font16,
                                        overFlow: TextOverflow.fade,
                                      ),
                                    ),
                                  )
                                : GetBuilder<CartController>(
                                    builder: (_cartController) {
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _orderHistory.length != 0
                                            ? _orderHistory.length
                                            : 0,
                                        itemBuilder: (context, index) {
                                          //_orderHistory = docs;

                                          if (_orderHistory.length != 0) {
                                            Object? data =
                                                _orderHistory[index].data();
                                            final basketValue = (data as Map<
                                                String,
                                                dynamic>)['total order amount'];

                                            final items =
                                                (data)['order items'][0];
                                            final orderInitiated =
                                                (data)['createdAt'];
                                            final orderDate =
                                                orderInitiated.substring(0, 6);

                                            final handledBy = (data)['fetcher'];
                                            orderSpecialties = items;
                                            final image =
                                                (data)['order items'][0]['img'];

                                            final material =
                                                (data)['order items'][0]
                                                    ['material'];

                                            final provider =
                                                (data)['order items'][0]
                                                    ['provider'];

                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  // color: Colors.green,
                                                  margin: EdgeInsets.only(
                                                      left: Dimensions.width20,
                                                      right:
                                                          Dimensions.width20),
                                                  child:
                                                      MediaQuery.removePadding(
                                                          removeTop: true,
                                                          context: context,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    Dimensions
                                                                        .width10,
                                                              ),
                                                              SizedBox(
                                                                height: Dimensions
                                                                    .height10,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        height: Dimensions.height20 *
                                                                            3.5,
                                                                        width: Dimensions.height20 *
                                                                            3.5,
                                                                        margin: EdgeInsets.only(
                                                                            right:
                                                                                Dimensions.width10 / 2),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(4),
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
                                                                          image: DecorationImage(
                                                                              fit: BoxFit.cover,
                                                                              image: AssetImage(image!)),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: Dimensions
                                                                            .width15,
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          SmallText(
                                                                              text: '$provider',
                                                                              fontWeight: FontWeight.w600,
                                                                              color: AppColors.mainColor2),
                                                                          SizedBox(
                                                                              width: Dimensions.screenWidth / 20),
                                                                          SmallText(
                                                                            text:
                                                                                'Fetched by $handledBy',
                                                                            color:
                                                                                AppColors.titleColor,
                                                                          ),
                                                                          Column(
                                                                            children: [
                                                                              IntegerText(
                                                                                color: AppColors.mainColor,
                                                                                //color: const Color(0Xff353839),
                                                                                text: orderDate,
                                                                                fontWeight: FontWeight.w600,
                                                                                size: Dimensions.font16 / 1.2,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          )),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(
                      child: CircularProgressIndicator(
                    color: const Color(0xffB09B71),
                  ));
                },
              ),
            );
    }
  }
}

class NoActiveOrder extends StatelessWidget {
  const NoActiveOrder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Dimensions.height30 * 11,
      width: Dimensions.width20 * 18,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width10,
            vertical: Dimensions.height10 / 2.3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BigText(
              color: const Color(0Xff353839),
              text: 'You don\'t have any order!',
              weight: FontWeight.w600,
              size: Dimensions.font20,
            ),
            const Center(
              child: NoDataPage(
                text:
                    'Start to prepare your laundry, and wait for a driver to come and collect',
                imgPath: 'assets/image/laundry-machine11.png',
                softWrap: true,
              ),
            ),
            SizedBox(
              height: Dimensions.height20 / 1.5,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()));
              },
              child: Container(
                height: Dimensions.screenHeight / 15,
                width: Dimensions.width30 * 8 + 5,
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
                    text: 'Get started',
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

class OrderAddress extends StatelessWidget {
  const OrderAddress({
    super.key,
    required String venueType,
    required this.street,
    required this.address,
  }) : _venueType = venueType;

  final String _venueType;
  final String street;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  height: Dimensions.height20,
                ),
                AppIcon(
                  icon: (_venueType == 'Business/Office'
                      ? Icons.store_mall_directory_outlined
                      : _venueType == 'Estate/Complex'
                          ? Icons.apartment_rounded
                          : Icons.home_outlined),
                  backgroundColor: Colors.white,
                  iconSize: Dimensions.height20 + Dimensions.height10,
                  size: Dimensions.height10 + Dimensions.height30,
                  iconColor: Color(0xff9A9483),
                ),
              ],
            ),
            Wrap(
              children: [
                Wrap(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: SmallText(
                            text: _venueType,
                            color: Color(0xff9A9483),
                            fontWeight: FontWeight.w900,
                            size: Dimensions.font16,
                            height: 1.4,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Wrap(
                            children: [
                              IntegerText(
                                text: street,
                                overFlow: TextOverflow.fade,
                                color: Colors.black,
                                height: 1.5,
                                size: Dimensions.font16 / 1.1,
                              ),
                              SizedBox(
                                width: Dimensions.width10 / 2,
                              ),
                              SmallText(
                                text: '.',
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                height: 0.9,
                              ),
                              SizedBox(
                                width: Dimensions.width10 / 2,
                              ),
                              IntegerText(
                                text: address,
                                maxLines: 1,
                                color: Colors.black,
                                height: 1.5,
                                size: Dimensions.font16 / 1.1,
                                overFlow: TextOverflow.fade,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: Dimensions.screenWidth / 40,
            ),
          ],
        ),
      ],
    );
  }
}

class WithoutUser extends StatelessWidget {
  const WithoutUser({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.maxFinite,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BigText(
                  size: Dimensions.height18 + Dimensions.height18,
                  text: 'Orders',
                  color: const Color(0Xff353839),
                  weight: FontWeight.w600,
                ),
                SizedBox(
                  width: Dimensions.width10,
                ),
                const Divider(
                  color: Colors.black26,
                  height: 20,
                ),
                SizedBox(
                  width: Dimensions.width30,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Log in to see your orders.',
                    style: TextStyle(
                      fontSize: Dimensions.font16 / 1.04,
                      fontFamily: 'Hind',
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Wrapper()));
                  },
                  child: Container(
                    height: Dimensions.screenHeight / 14.5,
                    width: Dimensions.width30 * 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xffCFC5A5),
                          Color(0xff9A9483),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                      // color: const Color(0xff8d7053),
                    ),
                    child: Center(
                      child: BigText(
                        text: 'Log in',
                        size: Dimensions.font20,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Dimensions.height30,
                ),

                //sign up page
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account?',
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.2,
                          fontFamily: 'Hind',
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const GetStarted(),
                            transition: Transition.fade,
                            duration: Duration(milliseconds: 1100));
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: Dimensions.font16 / 1.2,
                            fontFamily: 'Hind',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
