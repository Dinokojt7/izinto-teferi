import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/car_wash_support_questions_controller.dart';
import '../../../controllers/laundry_support_questions_controller.dart';
import '../../../controllers/recommended_specialty_controller.dart';
import '../../../controllers/laundry_specialty_controller.dart';
import '../../../controllers/popular_specialty_controller.dart';
import 'package:izinto/models/popular_specialty_model.dart';
import 'package:izinto/pages/auth/access.dart';
import 'package:izinto/pages/cart/re_cart.dart';
import 'package:izinto/pages/checkout/order_received.dart';
import 'package:izinto/pages/home/main_components/view_cart_button.dart';
import 'package:izinto/pages/home/main_components/view_cart_item_count.dart';
import 'package:izinto/pages/home/specialty_page_body.dart';
import 'package:izinto/live/wrapper.dart';
import 'package:izinto/pages/options/profile_settings.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/dialogs/main_dialog.dart';
import 'package:izinto/widgets/keep_page_alive.dart';
import 'package:izinto/pages/subscriptions/subscriptions.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/car_specialty_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/popular_specialty_controller.dart';

import '../../../controllers/subscription_controller.dart';
import '../../../controllers/subscription_plans_controller.dart';
import '../../../controllers/user_data_controller.dart';
import '../../../models/user.dart';
import '../../../services/phone_auth_methods.dart';
import '../../../services/purchase_api.dart';
import '../../../utils/colors.dart';
import '../../../widgets/dialogs/login_dialog.dart';
import '../../../widgets/dialogs/subscription_dialogs/subscription_dialog.dart';
import '../../../widgets/main_buttons/car_wash_checkout.dart';
import '../../../widgets/miscellaneous/app_icon.dart';
import '../../../widgets/skeletons.dart';
import '../../../widgets/texts/big_text.dart';
import '../../specialty/car_wash_screen.dart';
import '../../subscriptions/car_wash_subscription.dart';
import '../../subscriptions/intro.dart';
import 'header.dart';
import 'home_button.dart';
import 'material_tabs_section.dart';

class MainSpecialtyPage extends StatefulWidget {
  final String? area;
  final ValueNotifier<bool>? showDialog;
  final ValueNotifier<bool>? showSubscriptionSignUp;
  const MainSpecialtyPage(
      {Key? key, this.area, this.showDialog, this.showSubscriptionSignUp})
      : super(key: key);

  @override
  _MainSpecialtyPageState createState() => _MainSpecialtyPageState();
}

class _MainSpecialtyPageState extends State<MainSpecialtyPage>
    with TickerProviderStateMixin {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;
  String _name = 'Guest';
  String _address = 'Edenburg';
  String _email = '';
  String? area = '';
  String _subStatus = '';
  String _surname = '';
  String _phone = '';
  String _street = '17 Autumn Rd';
  String _area = 'Rivonia';
  bool _isTouching = false;
  bool homeTabSelected = true;
  late TabController _tabController;
  Color stateColor = Color(0xff9A9483);
  Map<String, dynamic> info = {};
  bool typeSelected = false;
  String washPrice = '';
  int quarterlyAmount = 0;
  int monthlyAmount = 0;
  String dropdownValue = 'Comprehensive';
  String timeValue = '08:00 - 10:00';
  bool _isCartActive = false;
  dynamic specialty = SpecialtyModel();
  int _basePrice = 120;
  DateTime? storedTime;
  int? availableKilos;
  DateTime? carTime;
  List vehicleType = [];
  bool hasOrder = false;
  List orderState = [];
  bool isLoadingButton = true;
  bool isLoadCount = false;
  bool isAnimationLoaded = false;
  //Active order
  String orderId = '';
  String _eta = '';
  String orderDetail = 'laundry';
  List<List<String>> orderStatus = [
    ['Canceled', 'There\'s been an error'],
    ['Pickup', 'Driver is on their way'],
    ['Washing', 'Your laundry is being washed'],
    ['Delivery', 'Clean laundry on its way to you'],
    ['Complete', 'This order has been completed']
  ];
  bool _showRefresh = false;
  bool _isLoadingResources = false;
  bool recommendedSpecialty =
      Get.find<RecommendedSpecialtyController>().isLoaded;
  final List<dynamic> vehicleTypes = [
    {"title": "SUV", "img": "assets/image/suv.png", "vehicleType": "suv"},
    {
      "title": "Hatch back",
      "img": "assets/image/hatch.png",
      "vehicleType": "hatch"
    },
    {"title": "Sedan", "img": "assets/image/sedan.png", "vehicleType": "sedan"},
    {
      "title": "Minibus",
      "img": "assets/image/minibus.png",
      "vehicleType": "minibus"
    }
  ];

  int planStatus = 0;
  String startDate = '';
  int totalWashes = 0;
  String selectedTerm = '';
  bool isShowDialog = false;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('izinto');
  late Stream<QuerySnapshot> _streamUserInfo;

  @override
  void initState() {
    super.initState();
    getOrderId();
    area = widget.area;

    Future.delayed(const Duration(seconds: 6), () {
      _showRefresh = recommendedSpecialty ? false : true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoadingButton = false;
        isLoadCount = true;
      });
    });
    Future.delayed(const Duration(seconds: 6), () {
      setState(() {
        isAnimationLoaded = true;
      });
    });
    _streamUserInfo = _referenceUserInfo.snapshots();
    _tabController = TabController(length: 3, vsync: this);

    // Add a listener to the TabController
    _tabController.addListener(() {
      // Check the current tab index
      if (_tabController.index == 0) {
        setState(() {
          isLoadingButton = true; //
        });

        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              isLoadingButton = false;
            });
          }
        });
        setState(() {
          homeTabSelected = true;
        });
      } else {
        setState(() {
          homeTabSelected = false;
        });
      }
    });
    _prefferedAddress();
    // _getData();
    _checkActiveOrder();
    _getCarSubscriptions();

    Get.find<RecommendedSpecialtyController>()
        .initSpecialty(specialty, Get.find<CartController>());
  }

  @override
  void dispose() {
    _tabController;
    _prefferedAddress();
    _getData();
    specialty;
    super.dispose();
  }

  _fetchOrderStateList() async {
    await FirebaseFirestore.instance
        .collection('orderStatuses')
        .doc('getStatuses')
        .get();

    setState(() {
      //   orderState = docSnapShot.;
    });
  }

  Future<void> _checkActiveOrder() async {
    User? user = await _firebaseAuth.currentUser;
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('Active')
          .doc('current order')
          .get();

      setState(() {
        hasOrder = docSnapshot.exists;
      });
    } catch (e) {
      setState(() {
        hasOrder = false;
      });
    }
  }

  getOrderId() async {
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Active')
        .doc('current order')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          orderId = userData['order number'];
          _eta = userData['eta'];
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
          quarterlyAmount = userData['quarterly'];
          monthlyAmount = userData['monthly'];
        });
    });
  }

  void _showRow(int index) {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isCartActive = false;
      });
    });
  }

  void _getData() async {
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
      if (mounted)
        setState(() {
          _address = userData['address'];
          _area = userData['area'];
          _street = userData['street'];
        });
    });
  }

  _checkPrice() {
    if (vehicleType == vehicleTypes[0] || vehicleType == vehicleTypes[1]) {
      setState(() {
        _basePrice = _basePrice + 30;
      });
    } else {
      setState(() {
        _basePrice = _basePrice + 20;
      });
    }
  }

  DateTime dateTime = DateTime.now();

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2023, dateTime.month, dateTime.day),
      lastDate: DateTime(2024),
    ).then((value) {
      setState(() {
        dateTime = value!;
      });
    });
  }

  _editCarWashOrder({required String itemImage, required String itemName}) {}
  Future<void> _loadResources() async {
    setState(() {
      _isLoadingResources = true;
    });
    await Get.find<RecommendedSpecialtyController>()
        .getRecommendedSpecialtyList();
    await Get.find<CartController>().getCartHistoryList();
    await Get.find<PopularSpecialtyController>().getPopularSpecialtyList();
    await Get.find<LaundrySpecialtyController>().getLaundrySpecialtyList();
    await Get.find<CarSpecialtyController>().getCarSpecialtyList();

    await Get.find<CarWashSupportQuestionsController>()
        .getCarWashSupportQuestionsList();
    await Get.find<SubscriptionPlansController>().getSubscriptionPlansList();
    await Get.find<PhoneAuthMethods>();
  }

  @override
  Widget build(BuildContext context) {
    Future fetchOffers() async {
      final offerings = await PurchaseApi.fetchOffers();

      if (offerings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 4),
            elevation: 8,
            backgroundColor: Color(0xff9A9483),
            behavior: SnackBarBehavior.floating,
            content: const Text('No Plans Found'),
          ),
        );
      } else {
        final packages = offerings
            .map((offer) => offer.availablePackages)
            .expand((pair) => pair)
            .toString();

        final offer = offerings.first;

      }
    }

    void _showSubscriptionPanel() {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20))),
          isScrollControlled: true,
          useSafeArea: true,
          context: context,
          builder: (context) {
            return CarWashSubscription(
              quarterlyAmount: quarterlyAmount,
              carMonthlyAmount: monthlyAmount,
            );
          });
    }

    final user = Provider.of<UserModel?>(context);
    // final userData = Provider.of<UserDataController>(context);
    return user != null
        ? Consumer<UserDataController>(
            builder: (context, userDataController, child) {
            final userData = userDataController;
            return GetBuilder<PopularSpecialtyController>(
                builder: (popularSpecialties) {
              return GetBuilder<CartController>(builder: (_cartController) {
                List<Widget> _tabs = [
                  Tab(
                    child: HomeButton(
                      title: 'Laundry',
                      activeScreen: _tabController.index,
                    ),
                  ),
                  Tab(
                    child: HomeButton(
                      title: 'Car Wash',
                      activeScreen: _tabController.index,
                    ),
                  ),
                  Tab(
                    child: HomeButton(
                      title: 'Subscriptions',
                      activeScreen: _tabController.index,
                    ),
                  ),
                ];

                return Stack(
                  children: [
                    Scaffold(
                      body: StreamBuilder<QuerySnapshot>(
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

                            return Column(
                              children: [
                                //showing the header

                                SafeArea(
                                  child: Header(
                                    user: user,
                                    name: userData.name,
                                    street: _street,
                                    address: _address,
                                    area: _area,
                                    showDialog: widget.showDialog!,
                                  ),
                                ),

                                //showing the body tabs
                                MaterialTabsSection(
                                  tabController: _tabController,
                                  tabs: _tabs,
                                  isSpecialtiesLoaded:
                                      popularSpecialties.isLoaded,
                                ),
                                SizedBox(
                                  height: Dimensions.height20,
                                ),
                                Flexible(
                                  child: Stack(
                                    children: [
                                      TabBarView(
                                        controller: _tabController,
                                        children: [
                                          // Content for tab 1
                                          KeepPageAlive(
                                            child: SingleChildScrollView(
                                              physics: !popularSpecialties
                                                      .isLoaded
                                                  ? NeverScrollableScrollPhysics()
                                                  : AlwaysScrollableScrollPhysics(),
                                              child: SpecialtyPageBody(),
                                            ),
                                          ),
                                          // Content for tab 2
                                          KeepPageAlive(
                                            child: SingleChildScrollView(
                                                physics:
                                                    AlwaysScrollableScrollPhysics(),
                                                child: CarWashView()
                                                // CarSpecialty(context, user,
                                                //     _showSubscriptionPanel),
                                                ),
                                          ),
                                          // Content for tab 3
                                          KeepPageAlive(
                                            child: SingleChildScrollView(
                                              child: SubscriptionIntro(
                                                planStatus: planStatus,
                                                showDialog: widget.showDialog!,
                                                showSubscriptionSignUp: widget
                                                    .showSubscriptionSignUp!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      !popularSpecialties.isLoaded
                                          ? Container(
                                              height:
                                                  Dimensions.screenHeight / 1.4,
                                              width: Dimensions.screenWidth,
                                              color: Colors.transparent,
                                              child: Column(),
                                            )
                                          : Container(
                                              color: Colors.transparent,
                                              height: 0.0000000001,
                                            )
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xffB09B71),
                            ),
                          );
                        },
                      ),
                    ),
                    _tabController.index == 0
                        ? Positioned(
                            top: Dimensions.height30 * 1.3,
                            right: 16.0,
                            child: ViewCartFloating(),
                          )
                        : Container(),
                    _cartController.getItems.length != 0 &&
                            _tabController.index == 0 &&
                            popularSpecialties.isLoaded
                        ? Positioned(
                            top: Dimensions.height30 * 1.6,
                            right: 26.0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.white),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radius30 * 1.5),
                                color: AppColors.mainColor,
                              ),
                              child: Center(
                                child: IntegerText(
                                  overFlow: TextOverflow.ellipsis,
                                  size: Dimensions.font16 / 1.6,
                                  text:
                                      '${Get.find<CartController>().totalItems.toString()}',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ],
                );
              });
            });
          })
        : GetBuilder<PopularSpecialtyController>(builder: (popularSpecialties) {
            return GetBuilder<CartController>(builder: (_cartController) {
              List<Widget> _tabs = [
                Tab(
                  child: HomeButton(
                    title: 'Laundry',
                    activeScreen: _tabController.index,
                  ),
                ),
                Tab(
                  child: HomeButton(
                    title: 'Car Wash',
                    activeScreen: _tabController.index,
                  ),
                ),
                Tab(
                  child: HomeButton(
                    title: 'Subscriptions',
                    activeScreen: _tabController.index,
                  ),
                ),
              ];
              return Stack(
                children: [
                  Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Column(
                        children: [
                          //showing the header

                          SafeArea(
                            child: GestureDetector(
                              onTap: () {
                                if (user == null) {
                                  widget.showDialog!.value =
                                      !widget.showDialog!.value;
                                } else {
                                  Get.to(
                                      () => ProfileSettings(
                                            isPhoneAuth: false,
                                          ),
                                      transition: Transition.fade,
                                      duration: Duration(seconds: 1));
                                }
                              },
                              child: Header(
                                user: user,
                                name: _name,
                                street: _street,
                                address: _address,
                                area: _area,
                                showDialog: widget.showDialog!,
                              ),
                            ),
                          ),

                          //showing the body tabs
                          Stack(
                            children: [
                              MaterialTabsSection(
                                tabController: _tabController,
                                tabs: _tabs,
                                isSpecialtiesLoaded:
                                    popularSpecialties.isLoaded,
                              ),
                              _isLoadingResources &&
                                      !popularSpecialties.isLoaded
                                  ? AnimatedContainer(
                                      color: Colors.transparent,
                                      duration: const Duration(seconds: 3),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.height10 * 5),
                                            ),
                                            child: Center(
                                              child: Transform.scale(
                                                scale: 0.6,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 3.5,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                          SizedBox(
                            height: Dimensions.height20,
                          ),
                          Flexible(
                            child: Stack(
                              children: [
                                TabBarView(
                                  controller: _tabController,
                                  children: [
                                    // Content for tab 1
                                    KeepPageAlive(
                                      child: SingleChildScrollView(
                                        physics: !popularSpecialties.isLoaded
                                            ? NeverScrollableScrollPhysics()
                                            : AlwaysScrollableScrollPhysics(),
                                        child: SpecialtyPageBody(),
                                      ),
                                    ),
                                    // Content for tab 2
                                    KeepPageAlive(
                                      child: SingleChildScrollView(
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          child: CarWashView()
                                          // CarSpecialty(context, user,
                                          //     _showSubscriptionPanel),
                                          ),
                                    ),
                                    // Content for tab 3
                                    KeepPageAlive(
                                      child: SingleChildScrollView(
                                        child: SubscriptionIntro(
                                          planStatus: planStatus,
                                          showDialog: widget.showDialog!,
                                          showSubscriptionSignUp:
                                              widget.showSubscriptionSignUp!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                !popularSpecialties.isLoaded
                                    ? Container(
                                        height: Dimensions.screenHeight / 1.4,
                                        width: Dimensions.screenWidth,
                                        color: Colors.transparent,
                                        child: Column(),
                                      )
                                    : Container(
                                        color: Colors.transparent,
                                        height: 0.0000000001,
                                      ),
                                _showRefresh && !popularSpecialties.isLoaded
                                    ? Container(
                                        width: double.maxFinite,
                                        color: Colors.white,
                                        height: _isTouching
                                            ? Dimensions.screenHeight / 3
                                            : null,
                                        child: Stack(
                                          children: [
                                            Container(
                                              color: Colors.white,
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(
                                                  height:
                                                      Dimensions.height45 * 1.3,
                                                ),
                                                Listener(
                                                  onPointerDown: (event) =>
                                                      setState(() {
                                                    _isTouching = true;
                                                  }),
                                                  onPointerUp: (event) =>
                                                      setState(() {
                                                    _isTouching = false;
                                                  }),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _loadResources();
                                                    },
                                                    child: Container(
                                                      width: double.maxFinite,
                                                      height: Dimensions
                                                              .screenHeight /
                                                          8.7,
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                                  .width20 *
                                                              1.4,
                                                          vertical: 17),
                                                      color: _isTouching
                                                          ? Colors.black12
                                                              .withOpacity(0.08)
                                                          : Colors.transparent,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          IntegerText(
                                                            align:
                                                                TextAlign.start,
                                                            maxLines: 4,
                                                            size: Dimensions
                                                                    .font20 /
                                                                1.2,
                                                            text:
                                                                'Something went wrong with your request.',
                                                          ),
                                                          IntegerText(
                                                            align:
                                                                TextAlign.start,
                                                            maxLines: 4,
                                                            color: AppColors
                                                                .secondary,
                                                            size: Dimensions
                                                                    .font20 /
                                                                1.2,
                                                            text:
                                                                'Refresh page',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      )),
                  _tabController.index == 0
                      ? Positioned(
                          top: Dimensions.height30 * 1.3,
                          right: 16.0,
                          child: ViewCartFloating(
                            email: _email,
                          ),
                        )
                      : Container(),
                  _cartController.getItems.length != 0 &&
                          _tabController.index == 0 &&
                          popularSpecialties.isLoaded
                      ? Positioned(
                          top: Dimensions.height30 * 1.6,
                          right: 26.0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.white),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radius30 * 1.5),
                              color: AppColors.mainColor,
                            ),
                            child: Center(
                              child: IntegerText(
                                overFlow: TextOverflow.ellipsis,
                                size: Dimensions.font16 / 1.6,
                                text:
                                    '${Get.find<CartController>().totalItems.toString()}',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container()
                ],
              );
            });
          });
  }

  GetBuilder<CarSpecialtyController> CarSpecialty(
      BuildContext context, UserModel? user, void _showSubscriptionPanel()) {
    return GetBuilder<CarSpecialtyController>(
      builder: (carSpecialties) {
        return carSpecialties.isLoaded
            ? Column(
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width30 / 2),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 3.2,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                topRight: Radius.circular(80),
                              ),
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xffCFC5A5),
                                    Color(0xff9A9483),
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.centerRight),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(5, 10),
                                    blurRadius: 10,
                                    color:
                                        AppColors.iconColor1.withOpacity(0.2))
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 8,
                                      right: Dimensions.width30 * 1.5,
                                      top: 6),
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(5, 10),
                                            blurRadius: 10,
                                            color: AppColors.iconColor1
                                                .withOpacity(0.2))
                                      ]),
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            color: AppColors.fontColor,
                                            size: 22,
                                          ),
                                          MaterialButton(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            onPressed: () {
                                              _showDatePicker();
                                            },
                                            child: Text(
                                              ('${dateTime.day} - ${dateTime.month} - ${dateTime.year}'),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize:
                                                    Dimensions.font16 / 1.1,
                                                color: AppColors.fontColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '|',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: Dimensions.font16,
                                          color: AppColors.fontColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      SizedBox(
                                        width: Dimensions.width10,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.watch_later_outlined,
                                            color: AppColors.fontColor,
                                            size: 22,
                                          ),
                                          SizedBox(
                                            width: Dimensions.width10,
                                          ),
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              focusColor: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              dropdownColor: Colors.white,
                                              value:
                                                  timeValue ?? '08:00 - 10:00',
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  timeValue = newValue!;
                                                });
                                              },
                                              items: <String>[
                                                '08:00 - 10:00',
                                                '10:00 - 12:00',
                                                '12:00 - 14:00',
                                                '14:00 - 16:00',
                                                '16:00 - 18:00',
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  onTap: () {
                                                    setState(() {
                                                      timeValue = value;
                                                    });
                                                  },
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize:
                                                          Dimensions.font16 /
                                                              1.1,
                                                      color:
                                                          AppColors.fontColor,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                GetBuilder<CartController>(
                                  builder: (_cartController) {
                                    final List<dynamic> carCart = [];
                                    for (var i = 0;
                                        i < _cartController.getItems.length;
                                        i++) {
                                      switch (_cartController.getItems[i].id) {
                                        case 401:
                                        case 402:
                                        case 403:
                                        case 404:
                                          carCart.add({
                                            'img':
                                                _cartController.getItems[i].img,
                                            'name': _cartController
                                                .getItems[i].name,
                                          });
                                          break;
                                      }
                                    }
                                    return Wrap(
                                      direction: Axis.horizontal,
                                      children: List.generate(carCart.length,
                                          (index) {
                                        final item = carCart[index];
                                        final String? itemImage = item['img'];
                                        final String? itemName = item['name'];
                                        var washType = 1;

                                        return GestureDetector(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                top: Dimensions.height10,
                                                left:
                                                    Dimensions.screenWidth / 40,
                                                right: Dimensions.screenWidth /
                                                    50),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                                colors: [
                                                  Color(0xffCFC5A5),
                                                  Color(0xff9A9483),
                                                ],
                                              ),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 0.4),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 2.5,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.height10),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  washType += 1;
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: Dimensions
                                                                .height10 /
                                                            2,
                                                        left: Dimensions
                                                                .screenWidth /
                                                            50,
                                                        right: Dimensions
                                                                .screenWidth /
                                                            50),
                                                    child: Image(
                                                      color: Colors.white,
                                                      image: AssetImage(
                                                          itemImage!),
                                                      height:
                                                          Dimensions.height45,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: Dimensions
                                                                .height10 /
                                                            2),
                                                    child: Text(
                                                      itemName!,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize:
                                                            Dimensions.font16 /
                                                                1.6,
                                                        height: 0.4,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                                Spacer(),
                                GetBuilder<CartController>(
                                  builder: (_cartController) {
                                    return _cartController.getItems.isEmpty
                                        ? Container()
                                        : Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                width: Dimensions.height10,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: CarWashCheckout(
                                                  email: _email,
                                                ),
                                              )
                                              // ElevatedButton(
                                              //   style: ButtonStyle(
                                              //     foregroundColor:
                                              //         MaterialStateProperty.all(
                                              //             AppColors.fontColor),
                                              //     backgroundColor:
                                              //         MaterialStateProperty.all(
                                              //             Colors.white),
                                              //   ),
                                              //   child: Text(
                                              //       'R $_basePrice .00 | Add to cart'),
                                              //   onPressed: () {
                                              //     setState(
                                              //       () {
                                              //         if (vehicleType == '') {
                                              //           ScaffoldMessenger.of(context)
                                              //               .showSnackBar(
                                              //             SnackBar(
                                              //               duration:
                                              //                   Duration(seconds: 4),
                                              //               elevation: 8,
                                              //               backgroundColor:
                                              //                   Color(0xff9A9484)
                                              //                       .withOpacity(0.9),
                                              //               behavior:
                                              //                   SnackBarBehavior.floating,
                                              //               content: const Text(
                                              //                   'Please select vehicle type'),
                                              //             ),
                                              //           );
                                              //         } else if (_basePrice == 120) {
                                              //           ScaffoldMessenger.of(context)
                                              //               .showSnackBar(
                                              //             SnackBar(
                                              //               duration:
                                              //                   Duration(seconds: 4),
                                              //               elevation: 8,
                                              //               backgroundColor:
                                              //                   Color(0xff9A9484)
                                              //                       .withOpacity(0.9),
                                              //               behavior:
                                              //                   SnackBarBehavior.floating,
                                              //               content: const Text(
                                              //                   'Please select wash, you haven\'t selected any wash.'),
                                              //             ),
                                              //           );
                                              //         } else {
                                              //           _checkPrice();
                                              //           info['time'] = timeValue;
                                              //           info['Total amount'] = _basePrice;
                                              //           print(info);
                                              //         }
                                              //       },
                                              //     );
                                              //   },
                                              // ),
                                            ],
                                          );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width30 / 2),
                    child: Container(
                      height: 140,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: Dimensions.height20),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 12,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.1,
                              height: 105,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                    image: AssetImage('assets/image/card1.png'),
                                    fit: BoxFit.fill),
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
                                    color:
                                        AppColors.iconColor1.withOpacity(0.1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: Container(
                              height: 70,
                              width: MediaQuery.of(context).size.width / 2.6,
                              margin:
                                  const EdgeInsets.only(right: 100, bottom: 40),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/image/card2.png'),
                                    fit: BoxFit.fill),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 15,
                            top: 20,
                            child: GestureDetector(
                              onTap: () {
                                if (user != null) {
                                  setState(() {
                                    isShowDialog = true;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: Duration(seconds: 4),
                                      elevation: 20,
                                      backgroundColor:
                                          Color(0xff9A9484).withOpacity(0.9),
                                      behavior: SnackBarBehavior.floating,
                                      content: Container(
                                        margin: EdgeInsets.zero,
                                        child: const Text(
                                            'Please login to proceed'),
                                      ),
                                      action: SnackBarAction(
                                        label: 'LOGIN',
                                        disabledTextColor: Colors.white,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          Get.to(() => const Access(),
                                              transition: Transition.fade,
                                              duration: Duration(seconds: 1));
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: Dimensions.screenHeight / 16,
                                width: Dimensions.screenWidth / 2.8,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 1,
                                      offset: Offset(1, 1),
                                      color: AppColors.mainBlackColor
                                          .withOpacity(0.2),
                                    ),
                                    BoxShadow(
                                      blurRadius: 2,
                                      offset: Offset(-3, -3),
                                      color:
                                          AppColors.iconColor1.withOpacity(0.1),
                                    ),
                                  ],
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Color(0xffCFC5A5),
                                      Color(0xff9A9483),
                                    ],
                                  ),

                                  borderRadius: BorderRadius.all(
                                    Radius.circular(Dimensions.radius20 * 3),
                                  ),
                                  // color: const Color(0xff8d7053),
                                ),
                                child: isLoading
                                    ? Transform.scale(
                                        scale: 0.5,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 6,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: BigText(
                                          text: 'Subscribe',
                                          size: Dimensions.font20,
                                          weight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            child: Container(
                              width: double.maxFinite,
                              height: 100,
                              margin: EdgeInsets.only(left: 40, top: 62),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 13,
                                  ),
                                  Text(
                                    '                                                    Get 15% off with ',
                                    style: TextStyle(
                                      color: const Color(0xff9A9483),
                                      fontWeight: FontWeight.w500,
                                      fontSize: Dimensions.font16 / 1.1,
                                      height: 0.5,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 13,
                                  ),
                                  Text(
                                    '                    1 weekly wash and 2 monthly callouts*',
                                    style: TextStyle(
                                      color: const Color(0xff9A9483),
                                      fontWeight: FontWeight.w400,
                                      fontSize: Dimensions.font16 / 1.2,
                                      height: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        Text(
                          'Select vehicle',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Dimensions.font20,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.height10,
                  ),
                  //Test children below

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Container(
                      height: Dimensions.screenWidth,
                      width: Dimensions.screenWidth / 1.10,
                      child: OverflowBox(
                        maxWidth: MediaQuery.of(context).size.width,
                        child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: GetBuilder<CartController>(
                            builder: (_cartController) {
                              return GetBuilder<CarSpecialtyController>(
                                builder: (carSpecialties) {
                                  return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: carSpecialties
                                            .carSpecialtyList.length
                                            .toDouble() ~/
                                        2, //turn this reading and rendering into pairs
                                    itemBuilder: (_, i) {
                                      int a = 2 * i; //first index is 0, 2
                                      int b = 2 * i + 1; //now b is 0 + 1, 3

                                      return GetBuilder<
                                          RecommendedSpecialtyController>(
                                        builder: (controller) {
                                          return Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .setQuantity(true);
                                                      controller.addItem(
                                                          carSpecialties
                                                              .carSpecialtyList[a]);
                                                      setState(() {
                                                        vehicleType.add(
                                                            vehicleTypes[a]);
                                                      });
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          height: 140,
                                                          width: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  90) /
                                                              2,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 30,
                                                                  bottom: 15,
                                                                  top: 15),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 5),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14),
                                                            border: _cartController.getQuantity(
                                                                        carSpecialties.carSpecialtyList[
                                                                            a]) !=
                                                                    0
                                                                ? Border.all(
                                                                    width: 1.5,
                                                                    color: const Color(
                                                                        0xff9A9483))
                                                                : Border.all(
                                                                    width: 0.1),
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
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                Image(
                                                                  color: _cartController.getQuantity(carSpecialties.carSpecialtyList[
                                                                              a]) !=
                                                                          0
                                                                      ? Color(0xff9A9483)
                                                                          .withOpacity(
                                                                              0.91)
                                                                      : Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.31),
                                                                  image: AssetImage(
                                                                      carSpecialties
                                                                          .carSpecialtyList[
                                                                              a]
                                                                          .img),
                                                                  height: Dimensions
                                                                          .height45 *
                                                                      2,
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  child: Text(
                                                                    vehicleTypes[
                                                                            a][
                                                                        'title'],
                                                                    style: TextStyle(
                                                                        letterSpacing:
                                                                            0.7,
                                                                        fontSize:
                                                                            Dimensions
                                                                                .font16,
                                                                        color: _cartController.getQuantity(carSpecialties.carSpecialtyList[a]) !=
                                                                                0
                                                                            ? const Color(
                                                                                0xff9A9483)
                                                                            : Colors
                                                                                .black38,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        _cartController.getQuantity(
                                                                    carSpecialties
                                                                            .carSpecialtyList[
                                                                        a]) !=
                                                                0
                                                            ? Positioned(
                                                                right: Dimensions
                                                                    .width10,
                                                                bottom: Dimensions
                                                                    .height30,
                                                                child: Stack(
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        GestureDetector(
                                                                          behavior:
                                                                              HitTestBehavior.translucent,
                                                                          onTap:
                                                                              () {
                                                                            _cartController.getQuantity(carSpecialties.carSpecialtyList[a]) == 1
                                                                                ? vehicleType.remove(vehicleTypes[a])
                                                                                : null;
                                                                            controller.setQuantity(false);
                                                                            controller.addItem(carSpecialties.carSpecialtyList[a]);
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              border: Border.all(width: 1.5, color: Color(0xffA0937D)),
                                                                            ),
                                                                            child:
                                                                                AppIcon(
                                                                              weight: 10,
                                                                              size: 22,
                                                                              iconSize: Dimensions.iconSize24,
                                                                              backgroundColor: Colors.white,
                                                                              iconColor: const Color(0xffA0937D),
                                                                              icon: Icons.remove,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              Dimensions.width30 * 2 + Dimensions.width20,
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            controller.setQuantity(true);
                                                                            controller.addItem(carSpecialties.carSpecialtyList[a]);
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              border: Border.all(width: 1.5, color: const Color(0xff966C3B)),
                                                                            ),
                                                                            child:
                                                                                AppIcon(
                                                                              weight: 10,
                                                                              size: 22,
                                                                              iconSize: Dimensions.iconSize24,
                                                                              backgroundColor: Colors.white,
                                                                              iconColor: Color(0xff966C3B),
                                                                              icon: Icons.add,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Positioned(
                                                                      top: Dimensions
                                                                              .height10 /
                                                                          2,
                                                                      left: Dimensions
                                                                              .height30 *
                                                                          2.05,
                                                                      child:
                                                                          Text(
                                                                        '${_cartController.getQuantity(carSpecialties.carSpecialtyList[a])}',
                                                                        style: TextStyle(
                                                                            color:
                                                                                const Color(0xff966C3B),
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                  ),
                                                  _cartController.getQuantity(
                                                              carSpecialties
                                                                      .carSpecialtyList[
                                                                  a]) !=
                                                          0
                                                      ? Positioned(
                                                          bottom: 0,
                                                          left: 0,
                                                          child:
                                                              GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .translucent,
                                                            onTap: () {
                                                              _cartController.getQuantity(
                                                                          carSpecialties.carSpecialtyList[
                                                                              a]) ==
                                                                      1
                                                                  ? vehicleType
                                                                      .remove(
                                                                          vehicleTypes[
                                                                              a])
                                                                  : null;
                                                              controller
                                                                  .setQuantity(
                                                                      false);
                                                              controller.addItem(
                                                                  carSpecialties
                                                                      .carSpecialtyList[a]);
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 30,
                                                                      bottom:
                                                                          15,
                                                                      top: 15),
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          5),
                                                              width: 40,
                                                              height: 40,
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                              Stack(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .setQuantity(true);
                                                      controller.addItem(
                                                          carSpecialties
                                                              .carSpecialtyList[b]);
                                                      setState(() {
                                                        vehicleType.add(
                                                            vehicleTypes[b]);
                                                      });
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          height: 140,
                                                          width: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  90) /
                                                              2,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 30,
                                                                  bottom: 15,
                                                                  top: 15),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 5),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14),
                                                            border: _cartController.getQuantity(
                                                                        carSpecialties.carSpecialtyList[
                                                                            b]) !=
                                                                    0
                                                                ? Border.all(
                                                                    width: 1.5,
                                                                    color: const Color(
                                                                        0xff9A9483))
                                                                : Border.all(
                                                                    width: 0.1),
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
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                Image(
                                                                  color: _cartController.getQuantity(carSpecialties.carSpecialtyList[
                                                                              b]) !=
                                                                          0
                                                                      ? Color(0xff9A9483)
                                                                          .withOpacity(
                                                                              0.91)
                                                                      : Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.31),
                                                                  image: AssetImage(
                                                                      carSpecialties
                                                                          .carSpecialtyList[
                                                                              b]
                                                                          .img),
                                                                  height: Dimensions
                                                                          .height45 *
                                                                      2,
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  child: Text(
                                                                    vehicleTypes[
                                                                            b][
                                                                        'title'],
                                                                    style: TextStyle(
                                                                        letterSpacing:
                                                                            0.7,
                                                                        fontSize:
                                                                            Dimensions
                                                                                .font16,
                                                                        color: _cartController.getQuantity(carSpecialties.carSpecialtyList[b]) !=
                                                                                0
                                                                            ? const Color(
                                                                                0xff9A9483)
                                                                            : Colors
                                                                                .black38,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        _cartController.getQuantity(
                                                                    carSpecialties
                                                                            .carSpecialtyList[
                                                                        b]) !=
                                                                0
                                                            ? Positioned(
                                                                right: Dimensions
                                                                    .width10,
                                                                bottom: Dimensions
                                                                    .height30,
                                                                child: Stack(
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        GestureDetector(
                                                                          behavior:
                                                                              HitTestBehavior.translucent,
                                                                          onTap:
                                                                              () {
                                                                            _cartController.getQuantity(carSpecialties.carSpecialtyList[b]) == 1
                                                                                ? vehicleType.remove(vehicleTypes[b])
                                                                                : null;
                                                                            controller.setQuantity(false);
                                                                            controller.addItem(carSpecialties.carSpecialtyList[b]);
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              border: Border.all(width: 1.5, color: Color(0xffA0937D)),
                                                                            ),
                                                                            child:
                                                                                AppIcon(
                                                                              weight: 10,
                                                                              size: 22,
                                                                              iconSize: Dimensions.iconSize24,
                                                                              backgroundColor: Colors.white,
                                                                              iconColor: const Color(0xffA0937D),
                                                                              icon: Icons.remove,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              Dimensions.width30 * 2 + Dimensions.width20,
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            controller.setQuantity(true);
                                                                            controller.addItem(carSpecialties.carSpecialtyList[b]);
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              border: Border.all(width: 1.5, color: const Color(0xff966C3B)),
                                                                            ),
                                                                            child:
                                                                                AppIcon(
                                                                              weight: 10,
                                                                              size: 22,
                                                                              iconSize: Dimensions.iconSize24,
                                                                              backgroundColor: Colors.white,
                                                                              iconColor: Color(0xff966C3B),
                                                                              icon: Icons.add,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Positioned(
                                                                      top: Dimensions
                                                                              .height10 /
                                                                          2,
                                                                      left: Dimensions
                                                                              .height30 *
                                                                          2.05,
                                                                      child:
                                                                          Text(
                                                                        '${_cartController.getQuantity(carSpecialties.carSpecialtyList[b])}',
                                                                        style: TextStyle(
                                                                            color:
                                                                                const Color(0xff966C3B),
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                  ),
                                                  _cartController.getQuantity(
                                                              carSpecialties
                                                                      .carSpecialtyList[
                                                                  b]) !=
                                                          0
                                                      ? Positioned(
                                                          bottom: 0,
                                                          left: 0,
                                                          child:
                                                              GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .translucent,
                                                            onTap: () {
                                                              _cartController.getQuantity(
                                                                          carSpecialties.carSpecialtyList[
                                                                              b]) ==
                                                                      1
                                                                  ? vehicleType
                                                                      .remove(
                                                                          vehicleTypes[
                                                                              b])
                                                                  : null;
                                                              controller
                                                                  .setQuantity(
                                                                      false);
                                                              controller.addItem(
                                                                  carSpecialties
                                                                      .carSpecialtyList[b]);
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 30,
                                                                      bottom:
                                                                          15,
                                                                      top: 15),
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          5),
                                                              width: 40,
                                                              height: 40,
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : CarSkeleton();
      },
    );
  }
}
