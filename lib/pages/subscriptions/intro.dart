import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import 'package:izinto/pages/subscriptions/subscriptions.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';
import 'package:provider/provider.dart';

import '../../controllers/tabs_header.dart';
import '../../models/popular_specialty_model.dart';
import '../../models/user.dart';
import '../../services/firebase_storage_service.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/location/address_details_view.dart';
import '../../widgets/main_buttons/continue_button.dart';
import '../../widgets/texts/big_text.dart';
import '../../widgets/texts/small_text.dart';
import '../auth/access.dart';
import '../auth/login.dart';

class SubscriptionIntro extends StatefulWidget {
  final int planStatus;
  final ValueNotifier<bool> showDialog;
  final ValueNotifier<bool> showSubscriptionSignUp;
  const SubscriptionIntro({
    Key? key,
    required this.planStatus,
    required this.showDialog,
    required this.showSubscriptionSignUp,
  }) : super(key: key);

  @override
  State<SubscriptionIntro> createState() => _SubscriptionIntroState();
}

class _SubscriptionIntroState extends State<SubscriptionIntro> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  PageController pageController = PageController(viewportFraction: 0.9);
  var _currPageValue = 0.0;
  final double _scaleFactor = 0.8;
  final double _height = Dimensions.pageViewContainer;
  bool isLoading = false;
  String quarterlyAmount = '';
  String byAnnualAmount = '';
  int planStatus = 0;
  String startDate = '';
  DateTime nextDate = DateTime.now();
  ValueNotifier<double> _progress = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _getSubscriptions();
    _getSubscriptionStatus();
    _startProgress();
    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
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
          planStatus = userData['remainingKilograms'];
          startDate = userData['createdAt'];
        });
    });
  }

  void _startProgress() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(Duration(milliseconds: 50));
      _progress.value = i / 11;
    }
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

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d MMMM H:mm').format(nextDate);
    final user = Provider.of<UserModel?>(context);
    void _showSubscriptionPanel() {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20))),
          isScrollControlled: true,
          useSafeArea: true,
          context: context,
          builder: (context) {
            return SubscriptionPage(
              quarterlyAmount: quarterlyAmount,
              byAnnualAmount: byAnnualAmount,
            );
          });
    }

    if (widget.planStatus == 0 || planStatus == 0) {
      return StreamProvider<List<SpecialtyModel>>.value(
        value: DatabaseService().specialties,
        initialData: [],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //Main content slider
            Stack(
              children: [
                GetBuilder<TabsHeaderController>(builder: (subscriptionSlides) {
                  return SizedBox(
                    height: Dimensions.screenHeight / 2.1,
                    child: PageView.builder(
                        controller: pageController,
                        itemCount: subscriptionSlides.tabsHeaderList.length,
                        itemBuilder: (context, position) {
                          return _buildPages(position,
                              subscriptionSlides.tabsHeaderList[position]);
                        }),
                  );
                }),

                //Dots indicator
                Positioned(
                  bottom: 20,
                  right: 0,
                  left: 0,
                  child: GetBuilder<TabsHeaderController>(
                    builder: (subscriptionSlides) {
                      return Center(
                        child: GetBuilder<TabsHeaderController>(
                          builder: (subscriptionSlides) {
                            return DotsIndicator(
                              dotsCount: subscriptionSlides
                                      .tabsHeaderList.isEmpty
                                  ? 1
                                  : subscriptionSlides.tabsHeaderList.length,
                              position: _currPageValue,
                              decorator: DotsDecorator(
                                activeColor: AppColors.secondary,
                                color: const Color(0xffCFC5A5).withOpacity(0.5),
                                size: const Size.square(6.5),
                                activeSize: const Size(14, 8),
                                activeShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Dimensions.height10,
            ),
            GestureDetector(
              onTap: () {
                if (user != null) {
                  widget.showSubscriptionSignUp.value =
                      !widget.showSubscriptionSignUp.value;
                } else {
                  widget.showDialog.value = !widget.showDialog.value;
                }
              },
              child: ContinueButton(
                isLoading: isLoading,
                cto: 'Get Started',
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Container(
            height: Dimensions.screenHeight / 3.6,
            width: double.maxFinite,
            margin: EdgeInsets.only(
                bottom: 15,
                right: Dimensions.screenWidth / 30,
                left: Dimensions.screenWidth / 30),
            padding: EdgeInsets.only(left: 10, bottom: 5, right: 10, top: 20),
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.2,
                color: Color(0xff9A9483),
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
            ),
            //show the faq
            child: Column(
              children: [
                Center(
                  child: Image(
                    image: AssetImage('assets/image/laundry-detergent.png'),
                    width: Dimensions.screenWidth / 7,
                  ),
                ),
                SizedBox(
                  height: Dimensions.screenWidth / 30,
                ),
                Divider(
                  color: Colors.black26,
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IntegerText(
                      color: const Color(0xff9A9483),
                      fontWeight: FontWeight.w600,
                      size: Dimensions.font16,
                      height: 1.4,
                      text: 'Plan status',
                    ),
                    IntegerText(
                      text: 'Remaining capacity',
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      size: Dimensions.font16,
                      height: 1.4,
                    )
                  ],
                ),
                SizedBox(
                  height: Dimensions.screenWidth / 80,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IntegerText(
                      text: formattedDate,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      size: Dimensions.font16,
                      height: 1.4,
                    ),
                    IntegerText(
                      text: '${planStatus}(kg)',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      size: Dimensions.font16,
                      height: 1.4,
                    ),
                  ],
                ),
                SizedBox(
                  height: Dimensions.screenWidth / 80,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 1,
                            offset: Offset(1, 1),
                            color: AppColors.mainBlackColor.withOpacity(0.2),
                          ),
                          BoxShadow(
                            blurRadius: 1,
                            offset: Offset(-1, -1),
                            color: AppColors.iconColor1.withOpacity(0.1),
                          ),
                        ],
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius20 / 2),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xffCFC5A5),
                            Color(0xff9A9483),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_laundry_service_outlined,
                            color: Colors.white,
                            size: Dimensions.iconSize16,
                          ),
                          SizedBox(
                            width: Dimensions.width10,
                          ),
                          Text(
                            'Active',
                            style: TextStyle(
                                fontFamily: 'Hind',
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IntegerText(
                      text: '13 Washes',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      size: Dimensions.font16,
                      height: 1.4,
                    ),
                  ],
                ),
                // Center(
                //   child: Container(
                //     width: double.maxFinite,
                //     child: ValueListenableBuilder<double>(
                //       valueListenable: _progress,
                //       builder: (context, value, child) {
                //         return LinearProgressIndicator(
                //           value: value,
                //           backgroundColor: Colors.grey[300],
                //           valueColor:
                //               AlwaysStoppedAnimation<Color>(Color(0xff9A9483)),
                //         );
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
          )
        ],
      );
    }
  }

  Widget _buildPages(int index, SpecialtyModel subscription) {
    Matrix4 matrix = Matrix4.identity();
    if (index == _currPageValue.floor()) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currScale, 0);
    } else if (index == _currPageValue.floor() + 1) {
      var currScale =
          _scaleFactor + (_currPageValue - index + 1) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1);
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currScale, 0);
    } else if (index == _currPageValue.floor() - 1) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1);
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currScale, 0);
    } else {
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    }

    return Transform(
      transform: matrix,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.height20,
        ),
        margin: EdgeInsets.symmetric(
            vertical: Dimensions.height15,
            horizontal: Dimensions.screenWidth / 25),
        height: Dimensions.screenHeight / 2,
        decoration: BoxDecoration(
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Image(
                  image: AssetImage(subscription.img!),
                  width: Dimensions.screenWidth / 4,
                ),
                SizedBox(
                  height: Dimensions.height15,
                ),
                IntegerText(
                  size: Dimensions.height18 * 1.5,
                  text: subscription.introduction!,
                  color: const Color(0Xff353839),
                  fontWeight: FontWeight.w600,
                  maxLines: 4,
                  height: 1.1,
                  align: TextAlign.center,
                ),
                SizedBox(
                  height: Dimensions.height15,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
                  child: IntegerText(
                    align: TextAlign.center,
                    maxLines: 4,
                    size: Dimensions.font20 / 1.2,
                    text: subscription.material!,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
