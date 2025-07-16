import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:izinto/main.dart';
import 'package:izinto/pages/cart/post_checkout/cart_history_items.dart';
import 'package:izinto/pages/checkout/order_received.dart';
import 'package:izinto/pages/checkout/order_success.dart';
import 'package:izinto/pages/home/home_page.dart';
import 'package:izinto/utils/app_constants.dart';
import 'package:izinto/logger.dart';
import 'package:izinto/widgets/texts/big_text.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_model.dart';
import '../../models/order_model.dart';
import '../../models/user.dart';
import '../../routes/route_helper.dart';
import '../../services/location_manager.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/main_buttons/payment_checkout_button.dart';
import '../../widgets/payment_options/cash_pay.dart';
import '../../widgets/payment_options/rewards_pay.dart';
import '../../widgets/payment_options/yoco_pay.dart';
import '../../widgets/texts/small_text.dart';
import 'package:flutter/cupertino.dart';
import '../options/location_settings.dart';

class PaymentPage extends StatefulWidget {
  final OrderModel? orderModel;
  PaymentPage({this.orderModel});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late String selectedUrl;
  double value = 0.0;
  var instructionsController = TextEditingController();
  String instructions = '';
  dynamic hintArea = 'Leave a note for pickup';
  bool _canRedirect = true;
  bool _isLoading = false;
  //final Completer<WebViewController> _controller = Completer<WebViewController>;
  //late WebViewController controllerGlobal;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('addresses');
  late Stream<QuerySnapshot> _streamUserInfo;
  bool isLoading = false;
  String _street = '';
  String _area = '';
  String _address = '';
  String? totalOrderAmount;
  String? orderId;
  int? _previousTotalItem;
  int? _previousTotalOrderAmount;
  String? _previousTimeStamp;
  String? _previousOrderId;
  String? address = '';
  String? street = '';
  String? admin = '';
  String? zipCode = '';
  String? country = '';
  String? area = '';
  String? _admin;
  String? _country;
  String? _zipCode;
  String? paymentMethod = '';
  String? _arrivalTime = '';
  Map<String, dynamic> info = {};
  String timeValue = '08:00 - 10:00';
  Color selectPayment = Colors.black87;
  Color sendInstructions = Colors.black87;
  String notSent = '';
  String? deviceToken = '';
  String? messageTime = '';
  String? deliverySlot = '';
  bool isChangeTime = false;
  String _venueType = '';
  double? rewardsBalance = 0.0;
  bool isMissingPayment = false;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<dynamic> paymentMethodList = [
    {"paymentType": "yoco"},
    {"paymentType": "cash"},
    {"paymentType": "rewards"},
  ];

  //Rewards
  bool hasSurficientRewards = false;

  @override
  void initState() {
    super.initState();
    _getRewards();
    _getOrder();
    selectedUrl = '${AppConstants.BASE_URL}';
    _streamUserInfo = _referenceUserInfo.snapshots();

    instructionsController.addListener(() {
      setState(() {}); // setState every time text changes
    });
    _prefferedAddress();
    _getData();
    requestPermission();
    getToken();
    Future.delayed(const Duration(seconds: 4), () async {
      User? user = await _firebaseAuth.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Active')
          .doc('current order')
          .update({'address': address, 'street': street});
    });

    var deliveryDate = DateTime.now();
    String formattedDeliveryDate =
        DateFormat('dd MMM hh:mm a').format(deliveryDate);
    updateEta(formattedDeliveryDate);
    FlutterLocalNotificationsPlugin();
  }

  @override
  void dispose() {
    instructionsController.dispose();
    initInfo();
    super.dispose();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user granted provisional permission');
    } else {
      print('user declined or has not accepted permission');
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartHistoryItems(),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => CartHistoryItems()),
    );
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        deviceToken = token;
      });
      saveToken(deviceToken!);
    });
  }

  void saveToken(String token) async {
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('device tokens')
        .doc('current active')
        .set({
      'token': deviceToken,
    });
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitialize, iOS: initializationSettingsDarwin);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,

      //         (String? payload) async {
      //   try {
      //     if (payload != null && payload.isNotEmpty) {
      //     } else {}
      //   } catch (e) {}
      //   return;
      // }
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("................onMessage....................");
      print(
          "onMessage: ${message.notification?.title}/${message.notification?.body}}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(),
          htmlFormatContentTitle: true);
      AndroidNotificationDetails androidPlatformSpecifics =
          AndroidNotificationDetails(
        'Izinto',
        'Izinto',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: false,
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformSpecifics, iOS: DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  _alertUserOfOutstandingInformation() {
    String messageTime = DateFormat('H:mm').format(dateTime);
    if (!instructionsController.text.isEmpty) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            elevation: 8,
            backgroundColor: Color(0xff9A9484).withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            content: const Text('You haven\'t submitted your instructions'),
            action: SnackBarAction(
                label: 'SUBMIT',
                disabledTextColor: Colors.white,
                textColor: Colors.white,
                onPressed: () {
                  setState(() {
                    sendInstructions = Colors.black87;
                    hintArea = 'Your instructions are noted.';
                  });
                  instructionsController.clear();
                  updateChatRoom(instructions, messageTime);
                  FocusScope.of(context).unfocus();
                }),
          ),
        );
        // sendInstructions = Colors.red;
        // notSent = 'not sent press x to cancel';
      });
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          sendInstructions = Colors.black87;
          notSent = '';
        });
      });
    } else if (paymentMethod == '') {
      setState(() {
        isMissingPayment = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 4),
            elevation: 8,
            backgroundColor: Color(0xff9A9483).withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            content: const Text('Please select a payment method'),
          ),
        );

        //selectPayment = Colors.redAccent;
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () async {
        // await _deleteOrderOnNoActionTaken();
        // Get.offNamed(RouteHelper.getCartHistoryItems());
        //
        // Get.find<CartController>().clear();
      });
    }
  }

  void sendOrderNotification(String token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${AppConstants.GOOGLE_MESSAGING_SERVER_KEY}',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body':
                  'We are coming  \u{1F6B2} \u{1F4AA} \u{1F4AA} Order received, running a few checks and getting prepped up to deploy our A-Team.',
              'title': 'Hooorray!',
            },
            'notification': <String, dynamic>{
              'body':
                  'We are coming \u{1F6B2} \u{1F4AA} \u{1F4AA} Order received, running a few checks and getting prepped up to deploy our A-Team.',
              'title': 'Hooorray!',
              'android_channel_id': 'izinto'
            },
            'to': deviceToken,
          },
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  void _sendToCurrentOrder() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentReference =
        firestore.collection('orders').doc('order1');

    documentReference
        .update({
          'items': FieldValue.arrayUnion(['new_item'])
        })
        .then((value) => print('Item added successfully'))
        .catchError((error) => print('Failed to add item: $error'));
  }

  _clearCart() {
    Get.find<CartController>().clear();
    Get.find<CartController>().clearCartHistory();
  }

  void _getCurrentAddressMan() async {
    User? user = await _firebaseAuth.currentUser;
    if (user != null) {
      Position position = await determinePosition();
      print(position.latitude);
      _address = await GetAddressFromLatLong(position);
      print(_address);

      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemark[0];
      _street = '${place.street}';
      _address = '${place.subLocality}';
      _area = '${place.locality}';
      _admin = '${place.administrativeArea}';
      _country = '${place.country}';
      _zipCode = '${place.postalCode}';
      setState(() {});
    }
  }

  void _getRewards() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          rewardsBalance = userData['loyalty'];
        });
    });
  }

  GetAddressFromLatLong(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark);
    Placemark place = placemark[0];
    _street = '${place.street}';
    _address = '${place.subLocality}';
    _area = '${place.locality}';
    _admin = '${place.administrativeArea}';
    _country = '${place.country}';
    _zipCode = '${place.postalCode}';

    setState(() {});
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('current address')
        .set({
      'street': _street,
      'area': _area,
      'address': _address,
      'province': _admin,
      'country': _country,
      'postal Code': _zipCode,
      'createdAt': Timestamp.now(),
    });
  }

  void _prefferedAddress() async {
    User? user = await _firebaseAuth.currentUser;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('selected address')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          // _venueType = userData['venueType'];
          address = userData['address'];
          area = userData['area'];
          street = userData['street'];
          country = userData['country'];
          admin = userData['province'];
          zipCode = userData['postal Code'];
        });
    });
  }

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
          orderId = userData['order number'];
          _previousTotalItem = userData['total item count'];
          _previousTotalOrderAmount = userData['total order amount'];
          _previousTimeStamp = userData['createdAt'].toString();
          _previousOrderId = userData['Order Id'];
        });
    });
  }

  void updateChatRoom(String instructions, String time) async {
    User? user = await _firebaseAuth.currentUser;
    final documentReference =
        FirebaseFirestore.instance.collection('orders').doc(orderId);
    final documentSnapshot = await documentReference.get();
    final updatedChatRoom = await documentSnapshot.data()!['chat room'];
    final newMapItem = {
      '${user?.uid}': [instructions, time]
    };
    updatedChatRoom.add(newMapItem);
    documentReference.update({'chat room': updatedChatRoom});
  }

  void updateEta(String eta) async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Active')
        .doc('current order')
        .update({'eta': eta});
  }

  void updatePaymentMethod(String payment) async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Active')
        .doc('current order')
        .update({'payment type': paymentMethod});
  }

  void updateAddress() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Active')
        .doc('current order')
        .update({'address': address, 'street': street});
  }

  void updatePrice(String rewardsDiscounted) async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Active')
        .doc('current order')
        .update({'total order amount': rewardsDiscounted});
  }

  void updateStatus() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Active')
        .doc('current order')
        .update({'order status': 1});
  }

  void _getOrder() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Active")
        .doc('current order')
        .snapshots()
        .listen((userData) {
      if (mounted) {
        setState(() {
          orderId = userData['order number'];
        });
      }
    });
  }

  void updatePriceOnDashBoard(String rewardsDiscounted) async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'total order amount': rewardsDiscounted});
  }

  void changeDeliverySlot(String deliverySlot) async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Active')
        .doc('current order')
        .update({'updated delivery slot': deliverySlot});
  }

  SendOrderToDatabase(String? totalOrderAmount, int totalItem) async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Active")
        .doc('current order')
        .set({
      'order instructions': instructions,
      'total order amount': totalOrderAmount,
      'total item count': totalItem,
      'Order Id': DateTime.now().toIso8601String(),
      'createdAt': Timestamp.now(),
      'unique Id': UniqueKey().hashCode,
    });
  }

  //if the user takes more than the allocated time to take action the order will be removed from database
  _deleteOrderOnNoActionTaken() async {
    // Get a reference to the document to be deleted
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Active")
        .doc('current order')
        .delete();
  }

  SendOrderToUs(String? totalOrderAmount, int totalItem) async {
    User? user = await _firebaseAuth.currentUser;
    final keyValuePairs =
        // cart.map((item) => {'${item.name}': item.specialty}).toList();
        FirebaseFirestore.instance
            .collection('orders')
            .doc(user?.uid)
            .collection("Orders")
            .doc('current order')
            .set({
      //   'Items': keyValuePairs,
      'order instructions': instructions,
      'total order amount': totalOrderAmount,
      'total item count': totalItem,
      'Order Id': DateTime.now().toIso8601String(),
      'createdAt': Timestamp.now(),
      'unique Id': UniqueKey().hashCode,
    });
  }

  DateTime dateTime = DateTime.now();

  DateTime deliveryTime = DateTime.now().add(Duration(days: 1));

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: deliveryTime,
      firstDate: DateTime(2023, dateTime.month, dateTime.day),
      lastDate: DateTime(2024),
    ).then((value) {
      setState(() {
        isChangeTime = true;
        dateTime = value!;
        info['date'] = dateTime;

        deliverySlot = DateFormat('dd MMM ').format(dateTime);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 3),
          elevation: 8,
          backgroundColor: Color(0xff9A9484).withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          content: Text(
              'Your new date is ${DateFormat('dd MMM ').format(dateTime)} we\'ll contact you to arrange time'),
        ));
      });
    });
  }

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final displayRewards = (rewardsBalance! * 10).toInt();
    if (_address != null && (_address!.length + _area.length > 24)) {
      //     _address = _address!.replaceRange(13, _address!.length, '...');
      _area = _area.replaceRange(5, _area.length, '...');
    }

    DateTime deliveryDate = now.add(Duration(hours: 24));

    if (now.hour >= 18 || now.hour < 8) {
      // check if current time is between 6pm and 8am
      // if yes, add 24 hours to deliveryDate and set it to 8am of the following day
      deliveryDate = DateTime(
          deliveryDate.year, deliveryDate.month, deliveryDate.day + 1, 8);
    }

    String formattedDeliveryDate =
        DateFormat('dd MMM hh:mm a').format(deliveryDate);

    String messageTime = DateFormat('H:mm').format(dateTime);

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

    var listCounter = 0;

    return GetBuilder<CartController>(builder: (cartController) {
      return cartController.getItems.length == 0
          ? HomePage()
          : Stack(
              children: [
                StreamBuilder<QuerySnapshot>(
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
                      return Scaffold(
                        backgroundColor: Colors.white,
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
                          title: Text('Checkout'),
                          centerTitle: false,
                          backgroundColor: Colors.white,
                        ),
                        body: SafeArea(
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 10.0),
                                      child: Row(
                                        children: [
                                          BigText(
                                            text: 'Collection Info',
                                            color: AppColors.mainColor,
                                            size: Dimensions.font20,
                                            weight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 18.0, top: 20, bottom: 10),
                                      child: Row(
                                        children: [
                                          SmallText(
                                            text: 'Address',
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                            size: Dimensions.font16,
                                            height: 0.5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(() => const AddressSettings(),
                                            transition: Transition.fade,
                                            duration: Duration(seconds: 1));
                                      },
                                      child: Container(
                                        width: Dimensions.screenWidth / 1.12,
                                        margin: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.screenWidth / 20,
                                          vertical: Dimensions.screenWidth / 70,
                                        ),
                                        padding: EdgeInsets.only(
                                            top: Dimensions.height10,
                                            bottom: Dimensions.height10,
                                            left: Dimensions.screenWidth / 50,
                                            right: Dimensions.screenWidth / 40),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 1,
                                              offset: Offset(1, 2),
                                            ),
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 1,
                                              offset: Offset(0, -1),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius15),
                                        ),
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
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
                                            Wrap(
                                              children: [
                                                Wrap(
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 3.0),
                                                          child: SmallText(
                                                            text: _venueType,
                                                            color: Color(
                                                                0xff9A9483),
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            size: Dimensions
                                                                .font16,
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 3.0),
                                                          child: Wrap(
                                                            children: [
                                                              SmallText(
                                                                text: street!,
                                                                overFlow:
                                                                    TextOverflow
                                                                        .fade,
                                                                color: AppColors
                                                                    .titleColor,
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
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                height: 0.9,
                                                              ),
                                                              SizedBox(
                                                                width: Dimensions
                                                                        .width10 /
                                                                    2,
                                                              ),
                                                              SmallText(
                                                                text: address!,
                                                                maxLines: 1,
                                                                color: AppColors
                                                                    .titleColor,
                                                                height: 1.5,
                                                                size: Dimensions
                                                                        .font16 /
                                                                    1.1,
                                                                overFlow:
                                                                    TextOverflow
                                                                        .fade,
                                                              ),
                                                              SizedBox(
                                                                width: Dimensions
                                                                        .width10 /
                                                                    2,
                                                              ),
                                                              SmallText(
                                                                text: '.',
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                height: 0.9,
                                                              ),
                                                              SizedBox(
                                                                width: Dimensions
                                                                        .width10 /
                                                                    2,
                                                              ),
                                                              SmallText(
                                                                text: area!,
                                                                color: AppColors
                                                                    .titleColor,
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
                                                        Wrap(
                                                          children: [
                                                            SmallText(
                                                              text: admin!,
                                                              color: AppColors
                                                                  .titleColor,
                                                              height: 1.5,
                                                              size: Dimensions
                                                                      .font16 /
                                                                  1.1,
                                                              overFlow:
                                                                  TextOverflow
                                                                      .fade,
                                                            ),
                                                            SizedBox(
                                                              width: Dimensions
                                                                      .width10 /
                                                                  2,
                                                            ),
                                                            SmallText(
                                                              text: '.',
                                                              color: Colors
                                                                  .black87,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              height: 0.9,
                                                            ),
                                                            SizedBox(
                                                              width: Dimensions
                                                                      .width10 /
                                                                  2,
                                                            ),
                                                            SmallText(
                                                              text: country!,
                                                              color: AppColors
                                                                  .titleColor,
                                                              height: 1.5,
                                                              size: Dimensions
                                                                      .font16 /
                                                                  1.1,
                                                              overFlow:
                                                                  TextOverflow
                                                                      .fade,
                                                            ),
                                                            SizedBox(
                                                              width: Dimensions
                                                                      .width10 /
                                                                  2,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width:
                                                  Dimensions.screenWidth / 40,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: Dimensions.screenWidth / 10,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 18.0),
                                      child: Row(
                                        children: [
                                          SmallText(
                                            text: 'Instructions ${notSent}',
                                            color: sendInstructions,
                                            fontWeight: FontWeight.w500,
                                            size: Dimensions.font16,
                                            height: 0.5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: Dimensions.width20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                right: Dimensions.width10 +
                                                    Dimensions.screenWidth / 40,
                                              ),
                                              padding: EdgeInsets.only(
                                                left:
                                                    Dimensions.screenWidth / 30,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 2.5,
                                                    offset: Offset(1, 2),
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radius15),
                                              ),
                                              child: TextField(
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                onChanged: (val) {
                                                  setState(() {
                                                    instructions = val;
                                                  });
                                                },
                                                cursorColor:
                                                    AppColors.iconColor1,
                                                controller:
                                                    instructionsController,
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  suffixIcon: IconButton(
                                                    color:
                                                        instructionsController
                                                                .text.isEmpty
                                                            ? Colors.transparent
                                                            : AppColors
                                                                .iconColor1,
                                                    iconSize:
                                                        Dimensions.iconSize16,
                                                    onPressed:
                                                        instructionsController
                                                            .clear,
                                                    icon: Icon(Icons.close),
                                                  ),
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  hintStyle: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize:
                                                          Dimensions.font16),
                                                  hintText: hintArea,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              messageTime = DateFormat('H:mm a')
                                                  .format(dateTime);
                                              setState(() {
                                                sendInstructions =
                                                    Colors.black87;
                                                hintArea =
                                                    'Your instructions are noted.';
                                              });
                                              instructionsController.clear();
                                              updateChatRoom(
                                                  instructions, messageTime);
                                              FocusScope.of(context).unfocus();
                                            },
                                            child: Container(
                                              width: Dimensions.height45 * 1.8,
                                              height:
                                                  Dimensions.height45 * 1.25,
                                              decoration: BoxDecoration(
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 2.5,
                                                    offset: Offset(1, 2),
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radius15),
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  colors: [
                                                    Color(0xffA0937D),
                                                    Color(0xffA0937D),
                                                  ],
                                                ),

                                                // color: AppColors.titleColor)
                                              ),
                                              child: Center(
                                                child: SmallText(
                                                  text: 'Submit',
                                                  size: 13.0,
                                                  maxLines: 1,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: Dimensions.width10,
                                    ),
                                    const Divider(
                                      color: Colors.black12,
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 10.0),
                                      child: Row(
                                        children: [
                                          BigText(
                                            text: 'Payment',
                                            color: AppColors.mainColor,
                                            size: Dimensions.font20,
                                            weight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 18.0, top: 20, bottom: 10),
                                      child: Row(
                                        children: [
                                          SmallText(
                                            text: 'Select payment',
                                            color: isMissingPayment
                                                ? Colors.red
                                                : selectPayment,
                                            fontWeight: FontWeight.w500,
                                            size: Dimensions.font16,
                                            height: 0.5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    GetBuilder<CartController>(
                                      builder: (cartController) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.screenWidth / 25),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isMissingPayment = false;
                                                    paymentMethod = "Yoco";
                                                    selectPayment =
                                                        Colors.black87;
                                                  });
                                                },
                                                child: YocoPay(
                                                    paymentMethod:
                                                        paymentMethod),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isMissingPayment = false;
                                                    paymentMethod = "Cash";
                                                    selectPayment =
                                                        Colors.black87;
                                                  });
                                                },
                                                child: CashPay(
                                                  paymentMethod: paymentMethod,
                                                  price: 'R ' +
                                                      cartController.totalAmount
                                                          .toString() +
                                                      '.00 ',
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  if (displayRewards > 100) {
                                                    setState(() {
                                                      isMissingPayment = false;
                                                      hasSurficientRewards =
                                                          true;
                                                      paymentMethod = "rewards";
                                                      selectPayment =
                                                          Colors.black87;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          duration: Duration(
                                                              seconds: 4),
                                                          elevation: 8,
                                                          backgroundColor:
                                                              Color(0xff9A9483)
                                                                  .withOpacity(
                                                                      0.9),
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          content: const Text(
                                                              'Minimum balance to use rewards should be 100 ZAR'),
                                                        ),
                                                      );

                                                      //selectPayment = Colors.redAccent;
                                                    });
                                                  }
                                                },
                                                child: RewardsPay(
                                                    paymentMethod:
                                                        paymentMethod,
                                                    rewardsBalance:
                                                        'R ${displayRewards.toString()}.00'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: Dimensions.width10,
                                    ),
                                    const Divider(
                                      color: Colors.black12,
                                      height: 10,
                                    ),
                                    GetBuilder<CartController>(
                                      builder: (_cartController) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0, top: 10.0),
                                              child: Row(
                                                children: [
                                                  BigText(
                                                    text: 'Summary',
                                                    color: AppColors.mainColor,
                                                    size: Dimensions.font20,
                                                    weight: FontWeight.w600,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 18.0,
                                                  right: 18.0,
                                                  top: 20,
                                                  bottom: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SmallText(
                                                    text: 'Total items',
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                    size: Dimensions.font16,
                                                    height: 0.5,
                                                  ),
                                                  IntegerText(
                                                    text: _cartController
                                                        .totalItems
                                                        .toString(),
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    size: Dimensions.font16,
                                                    height: 0.5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 18.0,
                                                  right: 18.0,
                                                  top: 20,
                                                  bottom: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SmallText(
                                                    text:
                                                        'Estimated time of arrival',
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                    size: Dimensions.font16,
                                                    height: 0.5,
                                                  ),
                                                  SmallText(
                                                    fontWeight: FontWeight.w600,
                                                    size: Dimensions.font16,
                                                    height: 0.5,
                                                    text: !isChangeTime
                                                        ? formattedDeliveryDate
                                                        : DateFormat('dd MMM ')
                                                            .format(dateTime),
                                                    color:
                                                        const Color(0xFFB09B71),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    GetBuilder<CartController>(
                                        builder: (_cartController) {
                                      return Container(
                                        height:
                                            Dimensions.bottomHeightBar / 1.5,
                                        margin: EdgeInsets.only(
                                            left: Dimensions.width20,
                                            right: Dimensions.width20),
                                        child: MediaQuery.removePadding(
                                          removeTop: true,
                                          context: context,
                                          child: Container(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Wrap(
                                                  direction: Axis.horizontal,
                                                  children: List.generate(
                                                      _cartController.getItems
                                                          .length, (index) {
                                                    if (listCounter < 2) {
                                                      listCounter++;
                                                    }
                                                    return index <= 2
                                                        ? Container(
                                                            height: Dimensions
                                                                    .height20 *
                                                                3.5,
                                                            width: Dimensions
                                                                    .height20 *
                                                                3.5,
                                                            margin: EdgeInsets.only(
                                                                right: Dimensions
                                                                    .width10),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          Dimensions.radius15 /
                                                                              2),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius: 2,
                                                                  offset:
                                                                      Offset(
                                                                          2, 2),
                                                                  color: AppColors
                                                                      .mainBlackColor
                                                                      .withOpacity(
                                                                          0.2),
                                                                ),
                                                                BoxShadow(
                                                                  blurRadius: 3,
                                                                  offset:
                                                                      Offset(-5,
                                                                          -5),
                                                                  color: AppColors
                                                                      .iconColor1
                                                                      .withOpacity(
                                                                          0.1),
                                                                ),
                                                              ],
                                                              image:
                                                                  DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image: AssetImage(
                                                                    _cartController
                                                                        .getItems[
                                                                            index]
                                                                        .img!),
                                                              ),
                                                            ),
                                                          )
                                                        : Container();
                                                  }),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _showDatePicker();
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          Dimensions.width10,
                                                      vertical:
                                                          Dimensions.height10 /
                                                              2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .circular(Dimensions
                                                                  .radius15 /
                                                              3),
                                                      border: Border.all(
                                                        width: 1,
                                                        color:
                                                            AppColors.mainColor,
                                                      ),
                                                    ),
                                                    child: SmallText(
                                                      text: 'Change time',
                                                      color:
                                                          AppColors.mainColor,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            margin: EdgeInsets.only(
                                              bottom: Dimensions.height20,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    const Divider(
                                      color: Colors.black12,
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        bottomNavigationBar: GetBuilder<CartController>(
                          builder: (cartController) {
                            var totalOrderAmount = hasSurficientRewards
                                ? (_previousTotalOrderAmount! - displayRewards)
                                    .toString()
                                : _previousTotalOrderAmount.toString();

                            return GestureDetector(
                              onTap: () async {
                                User? user = await _firebaseAuth.currentUser;
                                //Get device token from user

                                if (paymentMethod != '' ||
                                    !instructionsController.text.isEmpty) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  updatePaymentMethod(paymentMethod!);
                                  updatePrice(totalOrderAmount);
                                  updateAddress();
                                  updateStatus();
                                  updatePriceOnDashBoard(totalOrderAmount);
                                  DocumentSnapshot snap =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user?.uid)
                                          .collection('device tokens')
                                          .doc('current active')
                                          .get();

                                  String deviceToken = snap['token'];
                                  sendOrderNotification(deviceToken);

                                  DocumentSnapshot snapData =
                                      await FirebaseFirestore.instance
                                          .collection('UserTokens')
                                          .doc('User1')
                                          .get();
                                  String izintoToken = snapData['token'];
                                  sendOrderNotification(izintoToken);

                                  updateEta(formattedDeliveryDate);
                                  updatePaymentMethod(paymentMethod!);

                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OrderSuccess(
                                                orderNumber: orderId!,
                                                finalOrderAmount:
                                                    totalOrderAmount,
                                                paymentMethod: paymentMethod!,
                                              )),
                                      (route) => false);
                                  _clearCart();
                                  setState(() {
                                    _isLoading = false;
                                  });

                                  changeDeliverySlot(deliverySlot!);
                                } else {
                                  _alertUserOfOutstandingInformation();
                                }
                              },
                              child: PaymentCheckoutButton(
                                instructionsController: instructionsController,
                                paymentMethod: paymentMethod,
                                totalOrderAmount: totalOrderAmount,
                                isLoading: _isLoading,
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xffB09B71),
                        ),
                      ),
                    );
                  },
                ),
                isLoading
                    ? Container(
                        child: Center(
                          child: Dialog(
                            backgroundColor: Colors.transparent,
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
                      )
                    : Container(),
              ],
            );
    });
  }
}
