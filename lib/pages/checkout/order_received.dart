import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:izinto/pages/cart/post_checkout/cart_history.dart';
import 'package:izinto/pages/notifications/inbox_view.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';
import 'package:provider/provider.dart';
import '../../base/no_data_page.dart';
import '../../controllers/cart_controller.dart';
import '../../models/user.dart';
import '../../routes/route_helper.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/texts/big_text.dart';
import '../../widgets/flutter_analog.dart';
import '../../widgets/texts/small_text.dart';
import '../auth/email_sign_in.dart';
import '../home/home_page.dart';
import '../../live/wrapper.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

class OrderReceived extends StatefulWidget {
  const OrderReceived({Key? key}) : super(key: key);
  @override
  _OrderReceivedState createState() => _OrderReceivedState();
}

class _OrderReceivedState extends State<OrderReceived> {
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
  String paymentMethod = '';
  String orderStatus = '';
  DateTime dateTime = DateTime.now();
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
  late String _orderAmount = '';
  late String initialMessage = '';
  late List _messages;

  @override
  void initState() {
    super.initState();
    _streamUserInfo = _referenceUserInfo.snapshots();
    _orders();
    _getData();
    _getHelpInfo();
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
  List<List> orderStatusDescription = [
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
          _orderAmount = userData['total order amount'].toString();
          paymentMethod = userData['payment type'];
          orderStatusCode = userData['order status'];
          street = userData['street'];
          address = userData['address'];
          _getOrderMessages();
        });
    });
  }

  void _getOrderMessages() async {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .listen((userData) {
      if (mounted) {
        setState(() {
          _messages = userData['chat room'];
          _orderDate = userData['createdAt'];
        });
      }
    });
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
            final orderInitiated = (data as Map<String, dynamic>)['createdAt'];
            timeOfOrder = orderInitiated;
            orderSpecialties = items;
            final images =
                (data as Map<String, dynamic>)['order items'][0]['img'];

            print(images);
            thumb = images;
          }
        });
      });
  }

  _getHelpInfo() async {
    await FirebaseFirestore.instance
        .collection('contacts')
        .doc('primary contact')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          initialMessage = userData['hello'];
          //_subStatus = userData['subStatus'];
        });
    });
  }

  Future<dynamic> startChat(String time) async {
    final documentReference =
        FirebaseFirestore.instance.collection('orders').doc(orderId);
    final documentSnapshot = await documentReference.get();
    final updatedChatRoom = await documentSnapshot.data()!['chat room'];
    final newMapItem = {
      'Izinto': [initialMessage, time]
    };
    updatedChatRoom.add(newMapItem);
    documentReference.update({'chat room': updatedChatRoom});
  }

  bool shouldPop = true;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //top
                        Padding(
                            padding: EdgeInsets.only(
                                left: Dimensions.screenWidth / 25,
                                right: Dimensions.screenWidth / 25,
                                top: Dimensions.screenWidth / 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order Received',
                                      style: TextStyle(
                                          fontSize: Dimensions.height18 +
                                              Dimensions.height18,
                                          color: AppColors.fontColor,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 3),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: orderStatusCode == 0
                                                ? Colors.red
                                                : Color(0xff9A9484)
                                                    .withOpacity(0.7)),
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radius15),
                                        color: orderStatusCode == 0
                                            ? Colors.white
                                            : Colors.green,
                                      ),
                                      child: Text(
                                        '${orderId}',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: orderStatusCode == 0
                                                ? Colors.red
                                                : Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Divider(
                          color: Colors.black26.withOpacity(0.1),
                          height: 20,
                        ),

                        SizedBox(
                          height: Dimensions.height30 * 8.7,
                          width: Dimensions.width20 * 19,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width10,
                                vertical: Dimensions.height10 / 2.3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  width: 1,
                                  color: Color(0xff9A9484).withOpacity(0.4)),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IntegerText(
                                      color: const Color(0Xff353839),
                                      text: orderStatusDescription[
                                          orderStatusCode][0],
                                      fontWeight: FontWeight.w600,
                                      size: Dimensions.height15 +
                                          Dimensions.height10,
                                    ),
                                    IntegerText(
                                      color: const Color(0Xff353839),
                                      text: 'R ${_orderAmount}.00',
                                      size: Dimensions.height18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Dimensions.height15 / 2,
                                ),
                                Container(
                                  height: Dimensions.height15 / 3,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.green.withOpacity(0.2)),
                                      gradient: LinearGradient(
                                          colors: orderStatusProgressIndicator[
                                              orderStatusCode],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight)),
                                ),
                                SizedBox(
                                  height: Dimensions.height15 / 2,
                                ),
                                Row(
                                  children: [
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: Dimensions.height20,
                                            ),
                                            AppIcon(
                                              icon: (_venueType ==
                                                      'Business/Office'
                                                  ? Icons
                                                      .store_mall_directory_outlined
                                                  : _venueType ==
                                                          'Estate/Complex'
                                                      ? Icons.apartment_rounded
                                                      : Icons.home_outlined),
                                              backgroundColor: Colors.white,
                                              iconSize: Dimensions.height20 +
                                                  Dimensions.height10,
                                              size: Dimensions.height10 +
                                                  Dimensions.height30,
                                              iconColor: Color(0xff9A9483),
                                            ),
                                          ],
                                        ),
                                        Wrap(
                                          children: [
                                            Wrap(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 3.0),
                                                      child: SmallText(
                                                        text: _venueType,
                                                        color:
                                                            Color(0xff9A9483),
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        size: Dimensions.font16,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 3.0),
                                                      child: Wrap(
                                                        children: [
                                                          IntegerText(
                                                            text: street,
                                                            overFlow:
                                                                TextOverflow
                                                                    .fade,
                                                            color: Colors.black,
                                                            height: 1.5,
                                                            size: Dimensions
                                                                    .font16 /
                                                                1.1,
                                                          ),
                                                          SizedBox(
                                                            width: Dimensions
                                                                    .width10 /
                                                                2,
                                                          ),
                                                          SmallText(
                                                            text: '.',
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            height: 0.9,
                                                          ),
                                                          SizedBox(
                                                            width: Dimensions
                                                                    .width10 /
                                                                2,
                                                          ),
                                                          IntegerText(
                                                            text: address,
                                                            maxLines: 1,
                                                            color: Colors.black,
                                                            height: 1.5,
                                                            size: Dimensions
                                                                    .font16 /
                                                                1.1,
                                                            overFlow:
                                                                TextOverflow
                                                                    .fade,
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
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: Dimensions.height20,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: Dimensions.width10 / 2,
                                          right: Dimensions.width10 / 2),
                                      child: Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'ETA: $_eta',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    Dimensions.font16 / 1.3,
                                                fontFamily: 'Poppins',
                                                color: const Color(0Xff353839),
                                              ),
                                              children: [
                                                TextSpan(
                                                  style: TextStyle(
                                                      fontSize:
                                                          Dimensions.font16 /
                                                              1.4,
                                                      fontFamily: 'Poppins',
                                                      color: const Color(
                                                          0Xff353839),
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Dimensions.height20,
                                ),
                                Expanded(
                                    child: Container(
                                  height: Dimensions.bottomHeightBar / 1.5,
                                  margin: EdgeInsets.only(
                                      left: Dimensions.width10 / 2,
                                      right: Dimensions.width10 / 2),
                                  child: MediaQuery.removePadding(
                                    removeTop: true,
                                    context: context,
                                    child: Container(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Wrap(
                                                direction: Axis.horizontal,
                                                children: List.generate(
                                                    orderItems.length < 4
                                                        ? orderItems.length
                                                        : 3, (i) {
                                                  final item = orderItems[i];
                                                  String? itemImage =
                                                      item['img'];
                                                  String? quantity =
                                                      item['quantity']
                                                          .toString();

                                                  return Container(
                                                    height:
                                                        Dimensions.height20 * 3,
                                                    width:
                                                        Dimensions.height20 * 3,
                                                    margin: EdgeInsets.only(
                                                        right:
                                                            Dimensions.width10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 2,
                                                          offset: Offset(2, 2),
                                                          color: AppColors
                                                              .mainBlackColor
                                                              .withOpacity(0.2),
                                                        ),
                                                        BoxShadow(
                                                          blurRadius: 3,
                                                          offset:
                                                              Offset(-5, -5),
                                                          color: AppColors
                                                              .iconColor1
                                                              .withOpacity(0.1),
                                                        ),
                                                      ],
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: AssetImage(
                                                              itemImage!)),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      margin: EdgeInsets.only(
                                        bottom: Dimensions.height20,
                                      ),
                                    ),
                                  ),
                                )),
                                SizedBox(
                                  height: Dimensions.height18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Dimensions.height30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Dimensions.width10,
                            ),
                            SizedBox(
                              width: Dimensions.width10,
                            ),
                            IntegerText(
                              size: Dimensions.height15 + Dimensions.height10,
                              text: 'What\'s included',
                              color: const Color(0Xff353839),
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),

                        //list
                        Expanded(
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: orderItems.length,
                            itemBuilder: (context, index) {
                              // _orderHistory = docs;
                              final item = orderItems[index];
                              final String? itemImage = item['img'];
                              final itemName = item['name'];
                              final int quantity = item['quantity'];
                              final String provider = item['provider'];
                              final String? material = item['material'];

                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    // color: Colors.green,
                                    margin: EdgeInsets.only(
                                        left: Dimensions.width20,
                                        right: Dimensions.width20),
                                    child: MediaQuery.removePadding(
                                        removeTop: true,
                                        context: context,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: Dimensions.width10,
                                            ),
                                            SizedBox(
                                              height: Dimensions.height10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: Dimensions
                                                                  .height20 *
                                                              3.5,
                                                          width: Dimensions
                                                                  .height20 *
                                                              3.5,
                                                          margin: EdgeInsets.only(
                                                              right: Dimensions
                                                                      .width10 /
                                                                  2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
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
                                                            image: DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image: AssetImage(
                                                                    itemImage!)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: Dimensions
                                                              .width15,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            IntegerText(
                                                              text: itemName,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .titleColor,
                                                              size: Dimensions
                                                                  .font16,
                                                            ),
                                                            SizedBox(
                                                                width: Dimensions
                                                                        .screenWidth /
                                                                    20),
                                                            IntegerText(
                                                                text: provider,
                                                                size: Dimensions
                                                                    .font16,
                                                                color: AppColors
                                                                    .mainColor2),
                                                            Column(
                                                              children: [
                                                                IntegerText(
                                                                  text: quantity ==
                                                                          1
                                                                      ? quantity
                                                                              .toString() +
                                                                          ' item'
                                                                      : quantity
                                                                              .toString() +
                                                                          ' items',
                                                                  color: AppColors
                                                                      .mainColor,
                                                                  size: Dimensions
                                                                      .font16,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        )
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
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Center(
                    child: CircularProgressIndicator(
                  color: const Color(0xffB09B71),
                ));
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                final String time = DateFormat('H:mm a').format(dateTime);

                if (_messages.length < 1) {
                  startChat(time);

                  Get.to(() => InboxView(),
                      duration: Duration(milliseconds: 500));
                } else {
                  Get.to(() => InboxView(),
                      duration: Duration(milliseconds: 500));
                }
              },
              child: Icon(
                Icons.chat,
                color: const Color(0xFF966C3B),
                size: Dimensions.iconSize24 * 1.4,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
  }
}
