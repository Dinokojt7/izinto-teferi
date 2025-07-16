import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:izinto/base/show_snackbar.dart';
import 'package:izinto/controllers/checkout_controller.dart';
import 'package:izinto/controllers/popular_specialty_controller.dart';
import 'package:izinto/pages/auth/get_started.dart';
import 'package:izinto/pages/cart/cart_processes_and_widgets/payment_route.dart';
import 'package:izinto/pages/cart/cart_processes_and_widgets/price_display.dart';
import 'package:izinto/pages/checkout/order_received.dart';
import 'package:izinto/pages/checkout/payment_page.dart';
import 'package:izinto/pages/subscriptions/car_wash_subscription.dart';
import 'package:izinto/routes/route_helper.dart';
import 'package:izinto/utils/colors.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/texts/big_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/recommended_specialty_controller.dart';
import '../../models/user.dart';
import '../../widgets/dialogs/mainLoadingSkeleton.dart';
import '../../widgets/dialogs/main_dialog.dart';
import '../../widgets/dialogs/subscription_dialogs/subscription_dialog.dart';
import '../../widgets/dialogs/token_display/token_status_dialog.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/subscription/subscription_in_cart/apply_sub.dart';
import '../../widgets/bottom_delete_sheet.dart';
import '../../widgets/subscription/subscription_in_cart/cart_sub_card.dart';
import '../../widgets/main_buttons/cart_checkout_button.dart';
import '../../widgets/texts/integers_and_doubles.dart';
import '../../widgets/texts/small_text.dart';
import '../../widgets/subscription/subscription_in_cart/sub_column_display.dart';
import '../../live/wrapper.dart';
import '../options/settings_view/get_help_popup.dart';
import '../subscriptions/subscriptions.dart';
import '../auth/access.dart';
import '../auth/login.dart';
import 'cart_processes_and_widgets/bottom_bar_lever.dart';
import 'cart_processes_and_widgets/cart_view_controller.dart';
import 'cart_processes_and_widgets/loading_dialog.dart';
import 'cart_processes_and_widgets/page_loader.dart';
import 'cart_processes_and_widgets/subscription_dialog.dart';
import 'cart_processes_and_widgets/main_bottom_container.dart';
import 'cart_processes_and_widgets/no_items.dart';

class ReCart extends StatefulWidget {
  final String? email;
  const ReCart({
    Key? key,
    this.email,
  }) : super(key: key);

  @override
  State<ReCart> createState() => _ReCartState();
}

class _ReCartState extends State<ReCart> with SingleTickerProviderStateMixin {
  late final AnimationController _slideAnimationController =
      AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1250));
  late final Animation<Offset> _slideAnimation =
      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(_slideAnimationController);

  //Main parameters
  final switchValues =
      ValueNotifier<List<bool>>(List.generate(2, (index) => false));
  final laundrySwitchValue = ValueNotifier<bool>(false);
  final carWashSwitchValue = ValueNotifier<bool>(false);
  final status = ValueNotifier<int>(0);
  final index = ValueNotifier<int>(1);
  final washType = ValueNotifier<String>('');
  final lastDate = ValueNotifier<String>('');
  final nextDate = ValueNotifier<String>('');
  final discountedItems = ValueNotifier<int>(0);
  final discount = ValueNotifier<int>(0);
  int? totalOrderAmount;
  List cart = Get.find<CartController>().getItems;
  List chatRoom = [];
  final _isLoadingLog = ValueNotifier<bool>(false);
  // bool showSubscriptionDialog = false;
  final showSubscriptionDialog = ValueNotifier<bool>(false);
  ValueNotifier<bool> _switch = ValueNotifier<bool>(false);
  final _showSubscriptionSignUp = ValueNotifier<bool>(false);
  final _isToggleSwitch = ValueNotifier<bool>(false);
  final _didUseSubscription = ValueNotifier<bool>(false);

//Bottom animation
  double _sheetHeight = Dimensions.bottomHeightBar * 2.7;
  double _containerPosition = 240.0; // Initial position of the container
  final double containerWidth =
      Dimensions.screenWidth / 20; // Width of the container

  //From database
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('users');
  late Stream<QuerySnapshot> _streamUserInfo;
  String _userId = '';
  int _laundrySubscription = 0;
  int _carWashSubscription = 0;
  int _laundryItemCount = 0;
  int _laundryDiscount = 0;
  int _carWashItemCount = 0;
  int _carWashDiscount = 0;
  int _laundryCapacity = 0;
  int _carWashCapacity = 0;
  dynamic _laundryLastDate;
  dynamic _carWashLastDate;
  dynamic _laundryNextDate;
  dynamic _carWashNextDate;
  String _formattedLaundryDate = '';
  String _formattedCarWashDate = '';
  String _formattedLaundryLastDate = '';
  String _formattedCarWashLastDate = '';
  bool _isExpanded = false;
  @override
  void initState() {
    super.initState();
    _slideAnimationController.forward();
    _streamUserInfo = _referenceUserInfo.snapshots();
    _getLaundrySubscription();
    _getCarWashSubscription();
  }

  @override
  void dispose() {
    super.dispose();
    _slideAnimationController.dispose();
    _getLaundrySubscription();
    _getCarWashSubscription();
    _streamUserInfo = _referenceUserInfo.snapshots();
  }

  // void _toggleExpansion() {
  //   setState(() {
  //     _isExpanded = !_isExpanded;
  //     DraggableScrollableActuator.reset(context);
  //   });
  // }

  void _getLaundrySubscription() async {
    User? user = await _firebaseAuth.currentUser;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          _laundrySubscription = userData['Laundry initialized'];
          _laundryCapacity = userData['Laundry'] ?? 0;
          _laundryNextDate = userData['last laundry date'].toDate();

          _formattedLaundryDate =
              DateFormat('E d MMMM').format(_laundryNextDate);
          _laundryLastDate = userData['current laundry wash date'].toDate();
          _formattedLaundryLastDate =
              DateFormat('E d MMMM').format(_laundryLastDate);
          print('Here is the status here: $_laundrySubscription');
          print('Here is the last wash date here: $_formattedLaundryDate');
        });
    });
  }

  // Future<void> getSubscriptions() async {
  //   _laundrySubscription = await _getLaundrySubscription();
  // }

  void _getCarWashSubscription() async {
    User? user = await _firebaseAuth.currentUser;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          _carWashSubscription = userData['Car Wash initialized'];
          _carWashCapacity = userData['Car Wash'];
          _carWashNextDate = userData['last car wash date'].toDate();
          _formattedCarWashDate =
              DateFormat('E d MMMM').format(_carWashNextDate);
          _carWashLastDate = userData['current car wash wash date'].toDate();
          _formattedCarWashLastDate =
              DateFormat('E d MMMM').format(_carWashLastDate);
          print('Here is the status here: $_carWashSubscription');
          print('Here is the last wash date here: $_formattedCarWashDate');
        });
    });
  }

  //Get converted previous wash date
  // void getLastSubscriptionInfo() async {
  //   User? user = await _firebaseAuth.currentUser;
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user?.uid)
  //       .collection('Subscriptions')
  //       .doc('plan')
  //       .snapshots()
  //       .listen((userData) {
  //     if (mounted)
  //       setState(() {
  //         Timestamp _timestamp = userData['date'];
  //         availableKilos = userData['remainingKilograms'];
  //         storedTime = _timestamp.toDate(); // Convert Timestamp to DateTime
  //       });
  //   });
  // }

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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    if (user != null) {
      return StreamBuilder<Object>(
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
              return _cartBuild();
            }
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xffB09B71),
                ),
              ),
            );
          });
    } else {
      return _cartBuild();
    }
  }

  Consumer<CheckoutController> _cartBuild() {
    final List<List<String>> subscriptionDates = [
      [_formattedLaundryDate, _formattedLaundryLastDate],
      [_formattedCarWashDate, _formattedCarWashLastDate]
    ];
    return Consumer<CheckoutController>(
        builder: (context, checkoutController, child) {
      var animationProcess = checkoutController.toggleExpansion(context);
      return Consumer<CartViewController>(
          builder: (context, cartViewController, child) {
        final bool isViewing = cartViewController.isViewSubscriptionSignUp;
        return ValueListenableBuilder(
            valueListenable: _showSubscriptionSignUp,
            builder: (context, value, _) {
              return ValueListenableBuilder(
                  valueListenable: _isToggleSwitch,
                  builder: (context, value, _) {
                    return ValueListenableBuilder(
                        valueListenable: showSubscriptionDialog,
                        builder: (context, value, _) {
                          return WillPopScope(
                            onWillPop: () async {
                              bool shouldPop = true;
                              if (showSubscriptionDialog.value == true) {
                                showSubscriptionDialog.value =
                                    !showSubscriptionDialog.value;
                                setState(() {
                                  shouldPop = false;
                                });
                              }

                              return shouldPop;
                            },
                            child: Stack(
                              children: [
                                Scaffold(
                                  appBar: buildAppBar(context),
                                  body: Stack(
                                    children: [
                                      //Cart items list
                                      buildItemList(context),

                                      buildTopRow(),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: buildBottomNavigation(),
                                      )
                                    ],
                                  ),
                                  //bottomNavigationBar: buildBottomNavigation()
                                ),
                                _isLoadingLog.value
                                    ? LoadingIndicator()
                                    : Container(),
                                showSubscriptionDialog.value
                                    ? ValueListenableBuilder(
                                        valueListenable: _didUseSubscription,
                                        builder: (context, value, _) {
                                          return MainDialog(
                                            contents: ValueListenableBuilder(
                                                valueListenable: status,
                                                builder: (context, value, _) {
                                                  return ValueListenableBuilder(
                                                    valueListenable: washType,
                                                    builder:
                                                        (context, value, _) {
                                                      return ValueListenableBuilder(
                                                          valueListenable:
                                                              lastDate,
                                                          builder: (context,
                                                              value, _) {
                                                            return ValueListenableBuilder(
                                                                valueListenable:
                                                                    nextDate,
                                                                builder:
                                                                    (context,
                                                                        value,
                                                                        _) {
                                                                  return ValueListenableBuilder(
                                                                      valueListenable:
                                                                          discountedItems,
                                                                      builder: (context,
                                                                          value,
                                                                          _) {
                                                                        return ValueListenableBuilder(
                                                                            valueListenable:
                                                                                discount,
                                                                            builder: (context,
                                                                                value,
                                                                                _) {
                                                                              var dateContext = washType.value == 'laundry' ? 0 : 1;
                                                                              return SubscriptionDialog(
                                                                                isToggleSwitch: _isToggleSwitch,
                                                                                subscriptionStatus: status.value,
                                                                                laundryOffer: null,
                                                                                nextDate: status.value == 1 ? subscriptionDates[dateContext][0] : null,
                                                                                lastDate: status.value == 1 ? subscriptionDates[dateContext][1] : null,
                                                                                carWashOffer: null,
                                                                                washType: washType.value,
                                                                                showDialog: showSubscriptionDialog,
                                                                                itemCount: discountedItems.value,
                                                                                discount: discount.value,
                                                                                showSubscriptionSignUp: _showSubscriptionSignUp,
                                                                                switchValues: switchValues,
                                                                                index: index,
                                                                                laundrySwitchValue: laundrySwitchValue,
                                                                                carWashSwitchValue: carWashSwitchValue,
                                                                              );
                                                                            });
                                                                      });
                                                                });
                                                          });
                                                    },
                                                  );
                                                }),
                                            height: Dimensions.screenHeight / 3,
                                            width: Dimensions.screenWidth / 1.3,
                                          );
                                        })
                                    : Container(),
                                // _showSubscriptionSignUp.value
                                //     ?
                                isViewing
                                    ? ValueListenableBuilder(
                                        valueListenable: index,
                                        builder: (context, value, _) {
                                          return ValueListenableBuilder(
                                              valueListenable: _isLoadingLog,
                                              builder: (context, value, _) {
                                                return ValueListenableBuilder(
                                                    valueListenable:
                                                        _showSubscriptionSignUp,
                                                    builder:
                                                        (context, value, _) {
                                                      return showSubscriptionSignUp(
                                                        switchValues:
                                                            switchValues,
                                                        isShowCartLoader:
                                                            _isLoadingLog,
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
                                _isToggleSwitch.value
                                    ? LoadingDialog()
                                    : Container(),
                                checkoutController.isLoading
                                    ? MainLoadingSkeleton()
                                    : Container(),
                              ],
                            ),
                          );
                        });
                  });
            });
      });
    });
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radius30),
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.six.withOpacity(0.5),
            Colors.white,
            Colors.white,
            Colors.white
          ]),
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
        image: AssetImage('assets/image/subscription_display.jpeg'),
      ),
    );
  }

  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  //////////////////SECTION DIVIDER////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////

  //Build items

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
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
    );
  }

  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  ///Cart Top Row///
  GetBuilder<CartController> buildTopRow() {
    return GetBuilder<CartController>(builder: (_cartController) {
      final String quantityText =
          _cartController.totalItems == 1 ? 'item' : 'items';
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
    });
  }

  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  ///Cart items list display///
  Padding buildItemList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.height20),
      child: GetBuilder<CartController>(builder: (_cartController) {
        return _cartController.getItems.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(
                    left: Dimensions.width20,
                    right: Dimensions.width20,
                    bottom: Dimensions.width20 * 6),
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
                                      bottom: Dimensions.height15 / 4),
                                  width: double.maxFinite,
                                  height: Dimensions.height20 * 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
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
                                                  _cartList[index].specialty!);

                                          Get.toNamed(
                                              RouteHelper.getPopularSpecialties(
                                                  popularIndex, 'cartpage'));

                                          var recommendedIndex = Get.find<
                                                  RecommendedSpecialtyController>()
                                              .recommendedSpecialtyList
                                              .indexOf(
                                                  _cartList[index].specialty!);

                                          Get.toNamed(RouteHelper
                                              .getRecommendedSpecialities(
                                                  recommendedIndex,
                                                  'cartpage'));
                                        },
                                        //Image Container
                                        child: Container(
                                          width: Dimensions.height20 * 3.5,
                                          height: Dimensions.height20 * 3.5,
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
                                                image: AssetImage(cartController
                                                    .getItems[index].img!)),
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radius15),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: Dimensions.width10,
                                      ),
                                      Expanded(
                                          child: SizedBox(
                                        height: Dimensions.height20 * 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                IntegerText(
                                                  text: cartController
                                                      .getItems[index].name!,
                                                  size: Dimensions.font16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.mainColor2,
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
                                                    child: IntegerText(
                                                      text:
                                                          'R ${cartController.getItems[index].price!.toString()}.00',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black54,
                                                      size: Dimensions.font16,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                      top: Dimensions.height10,
                                                      bottom:
                                                          Dimensions.height10 /
                                                              2,
                                                      // left: Dimensions.width10,
                                                      // right:
                                                      //     Dimensions.width10
                                                    ),
                                                    decoration: BoxDecoration(
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
                                                              onTap: () async {
                                                                if (_cartList[
                                                                            index]
                                                                        .quantity ==
                                                                    1) {
                                                                  _confirmRemove(
                                                                      _cartList[
                                                                              index]
                                                                          .name!,
                                                                      index);
                                                                } else {
                                                                  cartController.addItem(
                                                                      _cartList[
                                                                              index]
                                                                          .specialty!,
                                                                      -1);
                                                                }
                                                              },
                                                              child: Container(
                                                                // padding: EdgeInsets.symmetric(
                                                                //   horizontal: Dimensions.width10,
                                                                //   vertical: Dimensions.height10 / 2),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      width:
                                                                          1.5,
                                                                      color: Color(
                                                                          0xffA0937D)),
                                                                ),
                                                                child: AppIcon(
                                                                  weight: 10,
                                                                  size: 22,
                                                                  iconSize:
                                                                      Dimensions
                                                                          .iconSize24,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  iconColor: Color(
                                                                      0xffA0937D),
                                                                  icon: Icons
                                                                      .remove,
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
                                                              onTap: () {
                                                                cartController.addItem(
                                                                    _cartList[
                                                                            index]
                                                                        .specialty!,
                                                                    1);
                                                              },
                                                              child: Container(
                                                                // padding: EdgeInsets.symmetric(
                                                                //   horizontal: Dimensions.width10,
                                                                //   vertical: Dimensions.height10 / 2),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  border: Border.all(
                                                                      width:
                                                                          1.5,
                                                                      color: const Color(
                                                                          0xff966C3B)),
                                                                ),
                                                                child: AppIcon(
                                                                  weight: 10,
                                                                  size: 22,
                                                                  iconSize:
                                                                      Dimensions
                                                                          .iconSize24,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  iconColor: Color(
                                                                      0xff966C3B),
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
                                                          child: IntegerText(
                                                            color: Colors
                                                                .black54
                                                                .withOpacity(
                                                                    0.7),
                                                            text:
                                                                _cartList[index]
                                                                    .quantity
                                                                    .toString(),
                                                            fontWeight: FontWeight
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
            : NoItems();
      }),
    );
  }

  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  GetBuilder<CartController> buildBottomNavigation() {
    return GetBuilder<CartController>(
      builder: (cartController) {
        var user = Provider.of<UserModel?>(context);
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

        // Compare the current date with the target date
        DateTime currentDate = DateTime.now();
        final bool isLaundryWashDateActive = _laundryNextDate != null
            ? currentDate.isAfter(_laundryNextDate)
                ? true
                : false
            : true;
        final bool isCarWashDateActive = _carWashNextDate != null
            ? currentDate.isAfter(_carWashNextDate)
                ? true
                : false
            : true;

        //Subscription status
        _laundrySubscription = user == null
            ? 4
            : totalDiscountedItems == 0
                ? 3
                : !isLaundryWashDateActive
                    ? 1
                    : _laundrySubscription;
        _carWashSubscription = user == null
            ? 4
            : totalDiscountedCarWashItems == 0
                ? 3
                : !isCarWashDateActive
                    ? 1
                    : _carWashSubscription;

        //Number of discounted items
        _laundryItemCount = totalDiscountedItems;
        _carWashItemCount = totalDiscountedCarWashItems;

        //Discount amounts
        _laundryDiscount = totalDiscount;
        _carWashDiscount = totalCarWashDiscount;

        //Updated total order amount
        if (laundrySwitchValue.value == true) {
          totalOrderAmount = (totalOrderAmount! - totalDiscount);
        }
        if (carWashSwitchValue.value == true) {
          totalOrderAmount = (totalOrderAmount! - totalCarWashDiscount);
        }

        return cartController.getItems.isNotEmpty
            ? Consumer<CheckoutController>(
                builder: (context, checkoutController, child) {
                return Stack(
                  children: [
                    DraggableScrollableActuator(
                      child: GestureDetector(
                        onTap: () {
                          Provider.of<CheckoutController>(context,
                                  listen: false)
                              .toggleExpansion(context);
                        },
                        child: Container(
                            //    color: Colors.blueGrey.withOpacity(0.8),
                            height: _sheetHeight,
                            child: AnimatedBuilder(
                                animation: checkoutController.isExpanded
                                    ? kAlwaysCompleteAnimation
                                    : kAlwaysDismissedAnimation,
                                builder: (context, child) {
                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: DraggableScrollableSheet(
                                        maxChildSize: 0.99,
                                        minChildSize: 0.4,
                                        initialChildSize: 0.4,
                                        builder: (context, controller) {
                                          return Container(
                                            //height: Dimensions.bottomHeightBar * 2.7,

                                            decoration: bottomBoxDecoration(),
                                            child: ListView(
                                                controller: controller,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: Dimensions.height10,
                                                    ),
                                                    child:
                                                        ValueListenableBuilder(
                                                            valueListenable:
                                                                _switch,
                                                            builder: (context,
                                                                value, _) {
                                                              return MainBottomContainer(
                                                                totalOrderAmount:
                                                                    totalOrderAmount,
                                                                totalDiscountedCarWashItems:
                                                                    totalDiscountedCarWashItems,
                                                                totalDiscountedItems:
                                                                    totalDiscountedItems,
                                                                isShowDialog:
                                                                    showSubscriptionDialog,
                                                                laundrySubscription:
                                                                    _laundrySubscription,
                                                                carWashSubscription:
                                                                    _carWashSubscription,
                                                                status: status,
                                                                washType:
                                                                    washType,
                                                                laundryLastDate:
                                                                    _laundryNextDate
                                                                        .toString(),
                                                                laundryNextDate:
                                                                    _formattedLaundryDate,
                                                                carWashLastDate:
                                                                    _carWashNextDate
                                                                        .toString(),
                                                                carWashNextDate:
                                                                    _formattedCarWashDate,
                                                                lastDate:
                                                                    lastDate,
                                                                nextDate:
                                                                    nextDate,
                                                                itemCount:
                                                                    discountedItems,
                                                                discount:
                                                                    discount,
                                                                laundryItemCount:
                                                                    _laundryItemCount,
                                                                laundryDiscount:
                                                                    _laundryDiscount,
                                                                carWashItemCount:
                                                                    _carWashItemCount,
                                                                carWashDiscount:
                                                                    _carWashDiscount,
                                                                switchValues:
                                                                    switchValues,
                                                                index: index,
                                                                laundrySwitchValue:
                                                                    laundrySwitchValue,
                                                                carWashSwitchValue:
                                                                    carWashSwitchValue,
                                                              );
                                                            }),
                                                  ),
                                                ]),
                                          );
                                        }),
                                  );
                                })),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            // Adjust the position of the container along the x-axis
                            _containerPosition += details.primaryDelta!;
                            // Optionally, you can limit the container's movement within certain boundaries
                            // For example, limiting it to the width of the screen:
                            if (_containerPosition < 0) {
                              _containerPosition = 0;
                            } else if (_containerPosition >
                                MediaQuery.of(context).size.width - 80) {
                              _containerPosition =
                                  MediaQuery.of(context).size.width - 80;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: Dimensions.height20 * 4.5,
                          // Set the margin to position the container horizontally
                          margin: EdgeInsets.only(left: _containerPosition),
                          child: GestureDetector(
                              onTap: () {
                                Provider.of<CheckoutController>(context,
                                        listen: false)
                                    .sendOrderToDatabase(
                                        (laundrySwitchValue.value &&
                                                carWashSwitchValue.value
                                            ? totalOrderAmount! -
                                                (totalCarWashDiscount +
                                                    totalDiscount)
                                            : carWashSwitchValue.value
                                                ? totalOrderAmount! -
                                                    totalCarWashDiscount
                                                : laundrySwitchValue.value
                                                    ? totalOrderAmount! -
                                                        totalDiscount
                                                    : totalOrderAmount),
                                        itemCount,
                                        cart,
                                        orderMessages);
                              },
                              child: PaymentRoute()),
                        ),
                      ),
                    )
                  ],
                );
              })
            : Container(
                height: Dimensions.screenHeight / 3,
              );
      },
    );
  }

  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  BoxDecoration bottomBoxDecoration() {
    return BoxDecoration(
      color: AppColors.secondary,
      border: Border.all(
        width: 0,
        color: Color(0xff9A9484).withOpacity(0.4),
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimensions.radius30 * 1.5),
        topRight: Radius.circular(Dimensions.radius30 * 1.2),
      ),
    );
  }

  /////////////////////////////////////////////////////

  //Page features

  _confirmRemove(String item, int index) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
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

  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  _clearCart() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
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
}
