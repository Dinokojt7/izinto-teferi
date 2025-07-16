import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:izinto/pages/auth/email_sign_in.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/big_text.dart';
import '../auth/get_started.dart';
import '../../live/wrapper.dart';
import 'package:flutter/cupertino.dart';

class InboxView extends StatefulWidget {
  const InboxView({Key? key}) : super(key: key);

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? deviceToken = '';
  bool? isChatReady = false;
  String? orderId;
  int? _size = 0;
  bool _isLoading = true;
  bool isSentByMe = true;
  String? messageTime = '';
  String contact = '';

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //Firebase order object
  late List<dynamic> _messages = [];
  late List<dynamic> _items = [];
  late String _orderDate = '';

  final TextEditingController _textEditingController = TextEditingController();
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('izinto');
  late Stream<QuerySnapshot> _streamUserInfo;

  @override
  void initState() {
    super.initState();
    requestPermission();
    _streamUserInfo = _referenceUserInfo.snapshots();
    _getPrimaryContact();

    _getData();
    getToken();
    initInfo();

    // wait for the messages to load
    Future.delayed(Duration(seconds: 3)).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void sendOrderNotification(String token, String message) async {
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
              'body': message,
              'title': orderId,
            },
            'notification': <String, dynamic>{
              'body': message,
              'title': orderId,
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

  _getPrimaryContact() async {
    await FirebaseFirestore.instance
        .collection('contacts')
        .doc('primary contact')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          contact = userData['mobile'];
          //_subStatus = userData['subStatus'];
        });
    });
  }

  _launchPhoneDialer(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch phone dialer';
    }
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

  void _getData() async {
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
          _getOrderMessages();
        });
      }
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
          _items = userData['New order'];
          _size = _messages.length;
          _orderDate = userData['createdAt'];
        });
      }
    });
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
                  builder: (context) => InboxView(),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@drawable/ic_stat_output');
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

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => InboxView()),
    );
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        deviceToken = token;
        print('Device token is $deviceToken');
      });
      saveToken(deviceToken!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection('UserTokens').doc('User1').set({
      'token': deviceToken,
    });
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

  void sendPushMessage(String token, String body, String title) async {
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
              'body': body,
              'title': orderId,
            },
            'notification': <String, dynamic>{
              'title': orderId,
              'body': body,
              'android_channel_id': 'izinto'
            },
            'to': deviceToken,
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    //return either settings or authenticate widget
    if (user == null) {
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
                    text: 'Inbox',
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
                      text: 'Log in to see your messages.',
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
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
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
    } else {
      return StreamBuilder<QuerySnapshot>(
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
            return _isLoading
                ? Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xffB09B71),
                      ),
                    ),
                  )
                : Scaffold(
                    body: _size! < 1
                        ? SafeArea(
                            child: Container(
                              width: double.maxFinite,
                              child: Column(
                                children: [
                                  //Second row
                                  Container(
                                    decoration: BoxDecoration(
                                        // border: Border(
                                        //   bottom: BorderSide(color: Theme.of(context).dividerColor),
                                        // ),
                                        ),
                                    width: double.maxFinite,
                                    padding: EdgeInsets.only(
                                        top: Dimensions.height20),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: Dimensions.width30),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          BigText(
                                            size: Dimensions.height18 +
                                                Dimensions.height18,
                                            text: 'Inbox',
                                            color: const Color(0Xff353839),
                                            weight: FontWeight.w600,
                                          ),
                                          SizedBox(
                                            height: Dimensions.width20 * 2,
                                          ),
                                          Image(
                                            image: AssetImage(
                                                'assets/image/chat.png'),
                                            width: Dimensions.screenWidth / 2.5,
                                          ),
                                          SizedBox(
                                            height: Dimensions.width20 * 2,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: 'No messages to display',
                                              style: TextStyle(
                                                fontSize: Dimensions.font26,
                                                fontFamily: 'Hind',
                                                color: Colors.black87
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimensions.width30,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: 'You have no new messages',
                                              style: TextStyle(
                                                fontSize:
                                                    Dimensions.font16 / 1.01,
                                                fontFamily: 'Hind',
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: Dimensions.width10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: Dimensions.height30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : SafeArea(
                            child: Column(
                              children: [
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
                                          Row(
                                            children: [
                                              Text(
                                                'Order No. ',
                                                style: TextStyle(
                                                    fontSize: Dimensions.font20,
                                                    color: AppColors.fontColor,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5, vertical: 3),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Color(0xff9A9484)
                                                          .withOpacity(0.7)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                  color: Colors.green,
                                                ),
                                                child: Text(
                                                  '${orderId}',
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                _launchPhoneDialer('$contact'),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    Dimensions.width10 / 2,
                                                vertical:
                                                    Dimensions.height10 / 4,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radius15 /
                                                            3),
                                                border: Border.all(
                                                  width: 0.5,
                                                  color: AppColors.mainColor,
                                                ),
                                              ),
                                              child: SmallText(
                                                  color: Colors.black87,
                                                  size:
                                                      Dimensions.height18 / 1.2,
                                                  text: 'Dial'),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.black26.withOpacity(0.1),
                                  height: 20,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    reverse: false,
                                    itemCount: _messages.length,
                                    itemBuilder: (_, i) {
                                      final message = _messages[i];
                                      String? messageText =
                                          message.values.first[0];
                                      final messageTime =
                                          message.values.first[1];
                                      final isUserMessage =
                                          message.keys.first == user.uid;

                                      DateTime newTextTime = DateTime.now();
                                      String formattedOrderTime =
                                          DateFormat('dd MMM')
                                              .format(newTextTime);
                                      return Column(
                                        children: [
                                          // Center(
                                          //   child: DateFormat('dd MMM').format(
                                          //               message
                                          //                   .values.first[1]) ==
                                          //           DateFormat('dd MMM')
                                          //               .format(newTextTime)
                                          //       ? Container()
                                          //       : Text(
                                          //           formattedOrderTime
                                          //               .toString(),
                                          //           style: TextStyle(
                                          //             color: Colors.black87,
                                          //             fontSize:
                                          //                 Dimensions.height18 /
                                          //                     1.2,
                                          //           ),
                                          //         ),
                                          // ),
                                          Align(
                                            alignment: isUserMessage
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8.0,
                                                  right: 12.0,
                                                  top: 8.0),
                                              padding: const EdgeInsets.only(
                                                  left: 5.0,
                                                  top: 3,
                                                  bottom: 3,
                                                  right: 16),
                                              decoration: BoxDecoration(
                                                color: isUserMessage
                                                    ? Color(0xff9A9484)
                                                        .withOpacity(0.7)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radius15),
                                                border: Border.all(
                                                    width: 0.1,
                                                    color: Color(0xff966C3B)),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SmallText(
                                                    color: isUserMessage
                                                        ? Colors.white
                                                        : AppColors.mainColor2,
                                                    size: Dimensions.font16,
                                                    text: messageText!,
                                                  ),
                                                  IntegerText(
                                                    color: Color(0xff966C3B),
                                                    text: messageTime,
                                                    size:
                                                        Dimensions.font16 / 1.4,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 8.0, right: 3.0, top: 8.0),
                                  decoration: BoxDecoration(
                                      color:
                                          Color(0xff9A9484).withOpacity(0.07)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller: _textEditingController,
                                          decoration: InputDecoration(
                                            hintText: 'Type a message...',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      IconButton(
                                          icon: Icon(Icons.send),
                                          onPressed: () {
                                            String messageTime =
                                                DateFormat('H:mm a')
                                                    .format(dateTime);
                                            final instructions =
                                                _textEditingController.text
                                                    .trim();
                                            sendOrderNotification(
                                                deviceToken!, instructions);
                                            updateChatRoom(
                                                instructions, messageTime);
                                            _textEditingController.clear();
                                            FocusScope.of(context).unfocus();
                                          }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
      );
    }
  }
}

class TapGestureRecognizer {
  set onTap(Null Function() onTap) {}
}
