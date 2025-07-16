import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/pages/home/main_components/main_specialty_page.dart';
import 'package:izinto/pages/notifications/inbox_view.dart';
import 'package:izinto/pages/options/settings_view/main_settings_view.dart';
import 'package:izinto/utils/colors.dart';
import 'package:izinto/widgets/dialogs/subscription_dialogs/subscription_dialog.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../live/widgets/text_widgets/heading_style_text.dart';
import '../../models/user.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/dialogs/login_dialog.dart';
import '../../widgets/dialogs/main_dialog.dart';
import '../cart/post_checkout/cart_history_items.dart';
import '../options/profile_settings.dart';
import 'main_components/view_cart_button.dart';
import 'main_components/view_cart_item_count.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String publicKeyTest = AppConstants.THE_HILL;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  late PersistentTabController _controller;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('plans');
  late Stream<QuerySnapshot> _streamUserInfo;
  String _name = 'Guest';
  String _address = '';
  String _surname = '';
  DateTime? storedTime;
  DateTime? carTime;
  String _email = '';
  bool isLoadingButton = true;
  int laundryInitialized = 0;
  int carWashInitialized = 0;
  String carWashReference = '';
  String laundryReference = '';
  final showLogin = ValueNotifier<bool>(false);
  final _showSubscriptionSignUp = ValueNotifier<bool>(false);
  final index = ValueNotifier<int>(0);
  final _isLoadingLog = ValueNotifier<bool>(false);

  void onTapNav(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _carWashInitialization();
    _laundryInitialization();

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isLoadingButton = false;
        showExitConfirmationDialog(carWashReference, 'Car Wash');
        showExitConfirmationDialog(laundryReference, 'Laundry');
      });
      //   if (_carWashInitialization == 5) {
      //     showExitConfirmationDialog(carWashReference, 'Car Wash');
      //   }
      if (_laundryInitialization() == 5) {
        showExitConfirmationDialog(laundryReference, 'Laundry');
      }
    });

    _streamUserInfo = _referenceUserInfo.snapshots();
    _prefferedAddress();

    _controller = PersistentTabController(initialIndex: 0);
  }

  Future<int> _carWashInitialization() async {
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      setState(() {
        carWashInitialized = userData['Car Wash initialized'];
        // Check if 'Laundry' key exists and is not null
        if (userData['Car Wash reference'] != null) {
          // Check if 'Laundry' value is of type int
          if (userData['Car Wash reference'] is String) {
            carWashReference = userData['Car Wash reference'];
          } else {
            // Handle unexpected data type
            carWashReference = ''; // Or assign a default value
          }
        } else {
          // Handle case where 'Laundry' key is missing or value is null
          carWashReference = ''; // Or assign a default value
        }
      });
    });
    return carWashInitialized;
  }

  Future<int> _laundryInitialization() async {
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      setState(() {
        laundryReference = userData['Laundry reference'];
        laundryInitialized = userData['Laundry initialized'];

        print('Here is the status here: $laundryInitialized');
      });
    });
    return laundryInitialized;
  }

  void _getData() async {
    User? user = await _firebaseAuth.currentUser;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      setState(() {
        _name = userData['name'];
        _surname = userData['surname'];
        _email = userData['email'];
      });
    });
  }

  void _prefferedAddress() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('preffered address')
        .snapshots()
        .listen((userData) {
      setState(() {
        _address = userData['address'];
      });
    });
  }

  List<Widget> buildScreens() {
    return [
      MainSpecialtyPage(
        showDialog: showLogin,
        showSubscriptionSignUp: _showSubscriptionSignUp,
      ),
      // HubView(),
      CartHistoryItems(),
      InboxView(),
      Container(
        child: Text('Next next next nextpage'),
      ),
    ];
  }

  updateConfirmation(status, type) async {
    Map<String, dynamic> updateInitialized = {'$type initialized': status};
    User? user = await _firebaseAuth.currentUser;
    // Convert the list to a map

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update(updateInitialized);
  }

  sendSubscription(type) async {
    DateTime orderTime = DateTime.now();
    //final int amount = widget.amount;

    Map<String, dynamic> newSubscription = {
      type: type == 'Laundry' ? 60 : 18,
      'Date of $type subscription': orderTime
    };
    User? user = await _firebaseAuth.currentUser;
    // Convert the list to a map

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update(newSubscription);
  }

  Future<String> _verifyOnServer(String reference) async {
    const String url = 'https://api.paystack.co/transaction/verify/';
    while (true) {
      try {
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${publicKeyTest}'
        };
        http.Response response =
            await http.get(Uri.parse(url + reference), headers: headers);

        final Map body = json.decode(response.body);
        // print('Check response: ${response.statusCode} of ${response.body}');
        final String status = body['data']['status'];
        if (response.statusCode == 200) {
          print('here is the result:$status');

          return status;
          break;
        }
      } catch (e) {
        // print('This is the problem: $e');
        // return '$e';
        print('Error polling for result: $e');
        return 'awaiting payment';
      }
      // Pause for a short duration before making the next request
      await Future.delayed(Duration(seconds: 5));
    }
  }

  showExitConfirmationDialog(reference, type) async {
    final String verify = await _verifyOnServer(reference);
    if (verify == 'success') {
      sendSubscription(type);
      updateConfirmation(2, type);
    } else {
      updateConfirmation(0, type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    List pages = [
      MainSpecialtyPage(
        showDialog: showLogin,
        showSubscriptionSignUp: _showSubscriptionSignUp,
      ),
      // const HubView(),
      const CartHistoryItems(),
      const InboxView(),
      const MainSettingsView(),
    ];
    if (user != null) {
      return ValueListenableBuilder(
          valueListenable: _showSubscriptionSignUp,
          builder: (context, value, _) {
            return ValueListenableBuilder(
                valueListenable: _showSubscriptionSignUp,
                builder: (context, value, _) {
                  return Stack(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _streamUserInfo,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            QuerySnapshot querySnapshot = snapshot.data;

                            if (_name != '' && _surname != '') {
                              return GetBuilder<CartController>(
                                  builder: (_cartController) {
                                return Scaffold(
                                  body: pages[_selectedIndex],
                                  bottomNavigationBar: BottomAppBar(
                                    shape: CircularNotchedRectangle(),
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: Dimensions.width20,
                                          right: Dimensions.width20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 0.5,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              Dimensions.radius15),
                                          topRight: Radius.circular(
                                              Dimensions.radius15),
                                        ),
                                      ),
                                      child: BottomNavigationBar(
                                          unselectedFontSize: 11,
                                          selectedFontSize: 11,
                                          backgroundColor: Colors.white,
                                          selectedItemColor: AppColors.six,
                                          unselectedItemColor:
                                              Colors.grey.shade500,
                                          elevation: 0,
                                          type: BottomNavigationBarType.fixed,
                                          showSelectedLabels: true,
                                          showUnselectedLabels: true,
                                          selectedLabelStyle: TextStyle(
                                            color: AppColors.six,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          unselectedLabelStyle: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                          // selectedFontSize: 0.0,

                                          currentIndex: _selectedIndex,
                                          onTap: onTapNav,
                                          items: [
                                            BottomNavigationBarItem(
                                              icon: Icon(
                                                Icons.home_outlined,
                                              ),
                                              label: 'Home',
                                            ),
                                            // BottomNavigationBarItem(
                                            //   icon: Icon(Icons.dry_cleaning),
                                            //   label: 'Services',
                                            // ),
                                            BottomNavigationBarItem(
                                              icon: Icon(Icons.dry_cleaning),
                                              label: 'Orders',
                                            ),
                                            BottomNavigationBarItem(
                                              icon: Icon(
                                                Icons.messenger_outline_rounded,
                                              ),
                                              label: 'Inbox',
                                            ),
                                            BottomNavigationBarItem(
                                              icon: Icon(
                                                Icons.person_outlined,
                                              ),
                                              label: user == null
                                                  ? 'Log In'
                                                  : 'Profile',
                                            )
                                          ]),
                                    ),
                                  ),
                                );
                              });
                            } else {
                              return ProfileSettings(
                                isPhoneAuth: false,
                              );
                            }
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
                      _showSubscriptionSignUp.value
                          ? ValueListenableBuilder(
                              valueListenable: index,
                              builder: (context, value, _) {
                                return ValueListenableBuilder(
                                    valueListenable: _isLoadingLog,
                                    builder: (context, value, _) {
                                      return ValueListenableBuilder(
                                          valueListenable:
                                              _showSubscriptionSignUp,
                                          builder: (context, value, _) {
                                            return showSubscriptionSignUp(
                                              isShowCartLoader: _isLoadingLog,
                                              showDialog:
                                                  _showSubscriptionSignUp,
                                              index: index.value,
                                              showSubscriptionSignUpSwitch:
                                                  _showSubscriptionSignUp,
                                            );
                                          });
                                    });
                              })
                          : Container(),
                    ],
                  );
                });
          });
    } else {
      return ValueListenableBuilder(
          valueListenable: showLogin,
          builder: (context, value, _) {
            return GetBuilder<CartController>(builder: (_cartController) {
              return Stack(
                children: [
                  Scaffold(
                    body: pages[_selectedIndex],
                    bottomNavigationBar: BottomAppBar(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: BottomNavigationBar(
                            unselectedFontSize: 11,
                            selectedFontSize: 11,
                            backgroundColor: Colors.transparent,
                            selectedItemColor: const Color(0xff9A9483),
                            unselectedItemColor: Color(0xff121212),
                            //D0C9C0
                            elevation: 0,
                            type: BottomNavigationBarType.fixed,
                            showSelectedLabels: false,
                            showUnselectedLabels: false,
                            selectedLabelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.six,
                            ),
                            unselectedLabelStyle: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                            // selectedFontSize: 0.0,

                            currentIndex: _selectedIndex,
                            onTap: onTapNav,
                            items: [
                              BottomNavigationBarItem(
                                icon: Icon(
                                  size: Dimensions.iconSize24 * 1.3,
                                  Icons.home,
                                ),
                                label: 'Home',
                              ),
                              // BottomNavigationBarItem(
                              //   icon: Icon(Icons.dry_cleaning),
                              //   label: 'Services',
                              // ),
                              BottomNavigationBarItem(
                                icon: Icon(
                                    size: Dimensions.iconSize24 * 1.3,
                                    Icons.dry_cleaning),
                                label: 'Orders',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(
                                  size: Dimensions.iconSize24 * 1.3,
                                  Icons.messenger_outline_rounded,
                                ),
                                label: 'Inbox',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(
                                  size: Dimensions.iconSize24 * 1.3,
                                  Icons.person_outlined,
                                ),
                                label: user == null ? 'Log In' : 'Profile',
                              )
                            ]),
                      ),
                    ),
                  ),
                  showLogin.value
                      ? MainDialog(
                          contents: LoginDialog(
                            showDialog: showLogin,
                          ),
                          height: Dimensions.screenHeight / 3,
                          width: Dimensions.screenWidth / 1.3,
                        )
                      : Container()
                ],
              );
            });
          });
    }
  }
}
