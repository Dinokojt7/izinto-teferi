import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/car_specialty_controller.dart';

import '../../models/user.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/texts/big_text.dart';
import 'package:get/get.dart';

class CarWashSubscription extends StatefulWidget {
  final int quarterlyAmount;
  final int carMonthlyAmount;
  const CarWashSubscription(
      {Key? key, required this.quarterlyAmount, required this.carMonthlyAmount})
      : super(key: key);

  @override
  State<CarWashSubscription> createState() => _CarWashSubscriptionState();
}

class _CarWashSubscriptionState extends State<CarWashSubscription> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isQuarterly = false;
  bool isMonthly = false;
  String planAmount = '';
  int selectedAmount = 0;
  String selectedTerm = '';
  int totalWashes = 0;
  int totalCarSelection = 1;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('addresses');
  late Stream<QuerySnapshot> _streamUserInfo;

  @override
  void initState() {
    super.initState();

    _streamUserInfo = _referenceUserInfo.snapshots();
  }

  _launchURL({forceWebView = true}) async {
    forceWebView = true;
    const url = 'https://flutter.dev';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _updateSubscriberList() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('premium members')
        .doc('car subscriptions')
        .collection(selectedTerm)
        .doc(user?.uid)
        .set({
      'remainingWashes': totalWashes,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      height: Dimensions.screenHeight,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  right: Dimensions.width10,
                  left: Dimensions.width15,
                  top: 0,
                  bottom: 0),
              child: Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Positioned(
                            top: Dimensions.height45,
                            left: Dimensions.width20,
                            right: Dimensions.width20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image(
                                  color: Colors.black,
                                  image: AssetImage('assets/image/carwash.png'),
                                  width: 30,
                                ),
                                AppIcon(
                                  backgroundColor:
                                      Colors.grey.withOpacity(0.11),
                                  weight: 20,
                                  icon: Icons.close,
                                  iconColor: Color(0Xff353839),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                BigText(
                                  size: Dimensions.height45 / 1.8,
                                  text: 'Set up your car wash subscription',
                                  color: const Color(0Xff353839),
                                  weight: FontWeight.w600,
                                  maxLines: 3,
                                  height: 1.3,
                                  align: TextAlign.left,
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  right: Dimensions.screenWidth / 3.4),
                              child: Divider(
                                color: const Color(0Xff353839).withOpacity(0.9),
                                height: 20,
                                thickness: 4,
                              ),
                            ),
                            SmallText(
                              text:
                                  'Plans include - Once a week arranged wash, and '
                                  'two emergency call-outs per month. Bookings are arranged through the app. '
                                  'All bookings include full wash with interior and exterior polish.',
                              color: Colors.black54,
                            ),
                            Divider(
                              color: Colors.black26,
                              height: 20,
                            ),
                            Row(
                              children: [
                                BigText(
                                  height: 1.3,
                                  text: 'Add vehicles',
                                  color: Color(0xFF5c524f),
                                  size: Dimensions.font16 / 1.05,
                                  weight: FontWeight.w600,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Dimensions.height10,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: Dimensions.screenWidth / 7,
                                  padding: EdgeInsets.only(
                                      left: Dimensions.width10 / 2,
                                      right: Dimensions.width10 / 2),
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
                                          color: const Color(0Xff353839)
                                              .withOpacity(0.9)),
                                      color: Colors.white),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      focusColor: Colors.transparent,
                                      borderRadius: BorderRadius.circular(2),
                                      dropdownColor: Colors.white,
                                      value: totalCarSelection ?? 1,
                                      onChanged: (int? newValue) {
                                        setState(() {
                                          totalCarSelection = newValue!;
                                        });
                                      },
                                      items: <int>[
                                        1,
                                        2,
                                        3,
                                        4,
                                        5,
                                        6,
                                      ].map<DropdownMenuItem<int>>((int value) {
                                        return DropdownMenuItem<int>(
                                          onTap: () {
                                            setState(() {
                                              totalCarSelection = value;
                                            });
                                          },
                                          value: value,
                                          child: Text(
                                            value.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize:
                                                  Dimensions.font16 / 1.05,
                                              color: Color(0xFF5c524f),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Dimensions.height10,
                            ),
                            SizedBox(
                              height: Dimensions.height10,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isMonthly = true;
                                  isQuarterly = false;
                                  selectedAmount = widget.carMonthlyAmount;
                                  selectedTerm = 'Monthly';
                                  totalWashes = 6;
                                });
                              },
                              child: Container(
                                  width: double.maxFinite,
                                  margin:
                                      EdgeInsets.only(bottom: 15, right: 10),
                                  padding: EdgeInsets.only(
                                      left: 10, bottom: 8, right: 10, top: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffB09B71)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radius15),
                                    border: isMonthly
                                        ? Border.all(
                                            width: 1, color: Colors.black54)
                                        : Border.all(
                                            width: 1,
                                            color: Colors.transparent),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      BigText(
                                        text: 'Monthly',
                                        size: Dimensions.height45 / 1.8,
                                        color: const Color(0Xff353839),
                                        weight: FontWeight.w600,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          BigText(
                                            height: 1.3,
                                            text: '4 standard visits',
                                            color: Color(0xFF5c524f),
                                            size: Dimensions.font16 / 1.05,
                                            weight: FontWeight.w600,
                                          ),
                                          SmallText(
                                              color: Colors.black54,
                                              text: '(2 call-outs)'),
                                        ],
                                      ),
                                      AppIcon(
                                        size: 25,
                                        boxBorder: Border.all(
                                          width: 2,
                                          color: !isMonthly
                                              ? Colors.white
                                              : Color(0Xff353839)
                                                  .withOpacity(0.9),
                                        ),
                                        backgroundColor: !isMonthly
                                            ? Colors.white
                                            : Color(0Xff353839)
                                                .withOpacity(0.9),
                                        weight: 20,
                                        icon: MdiIcons.check,
                                        iconColor: Colors.white,
                                        iconSize: 20,
                                      ),
                                    ],
                                  )),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isMonthly = false;
                                  isQuarterly = true;
                                  selectedAmount = widget.quarterlyAmount;
                                  selectedTerm = 'Quarterly';
                                  totalWashes = 18;
                                });
                              },
                              child: Container(
                                  width: double.maxFinite,
                                  margin:
                                      EdgeInsets.only(bottom: 15, right: 10),
                                  padding: EdgeInsets.only(
                                      left: 10, bottom: 8, right: 10, top: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffB09B71)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radius15),
                                    border: isQuarterly
                                        ? Border.all(
                                            width: 1, color: Colors.black54)
                                        : Border.all(
                                            width: 1,
                                            color: Colors.transparent),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      BigText(
                                        text: 'Quarterly',
                                        size: Dimensions.height45 / 1.8,
                                        color: const Color(0Xff353839),
                                        weight: FontWeight.w600,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          BigText(
                                            height: 1.3,
                                            text: '12 standard visits',
                                            color: Color(0xFF5c524f),
                                            size: Dimensions.font16 / 1.05,
                                            weight: FontWeight.w600,
                                          ),
                                          SmallText(
                                              color: Colors.black54,
                                              text: '(6 call-outs)'),
                                        ],
                                      ),
                                      AppIcon(
                                        size: 25,
                                        boxBorder: Border.all(
                                          width: 2,
                                          color: !isQuarterly
                                              ? Colors.white
                                              : Color(0Xff353839)
                                                  .withOpacity(0.9),
                                        ),
                                        backgroundColor: !isQuarterly
                                            ? Colors.white
                                            : Color(0Xff353839)
                                                .withOpacity(0.9),
                                        weight: 20,
                                        icon: MdiIcons.check,
                                        iconColor: Colors.white,
                                        iconSize: 20,
                                      ),
                                    ],
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10,
                                  bottom: 2,
                                  right: 10,
                                  top: Dimensions.height15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  BigText(
                                    height: 1.3,
                                    text: 'Total:',
                                    color: Color(0xFF5c524f),
                                    size: Dimensions.font16 / 1.05,
                                    weight: FontWeight.w600,
                                  ),
                                  BigText(
                                    height: 1.3,
                                    text:
                                        'R ${(totalCarSelection * selectedAmount).toString()}.00',
                                    color: Color(0xFF5c524f),
                                    size: Dimensions.font16 / 1.05,
                                    weight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: Dimensions.screenWidth / 60,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (selectedTerm != '') {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  DateTime date = DateTime.now();
                                  User? user = await _firebaseAuth.currentUser;
                                  totalWashes = totalWashes * totalCarSelection;
                                  await FirebaseFirestore.instance
                                      .collection('premium members')
                                      .doc('car subscriptions')
                                      .collection(user!.uid)
                                      .doc(selectedTerm)
                                      .set({
                                    'number of cars': totalCarSelection,
                                    'amount': selectedAmount,
                                    'selected term': selectedTerm,
                                    'remaining washes': totalWashes,
                                    'createdAt': Timestamp.now(),
                                  });

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user?.uid)
                                      .collection('Subscriptions')
                                      .doc('car subscription')
                                      .update({
                                    'date': date,
                                    'number of cars': totalCarSelection,
                                    'amount': selectedAmount,
                                    'selected term': selectedTerm,
                                    'remaining washes': totalWashes,
                                    'createdAt': Timestamp.now().toString(),
                                  });

                                  Navigator.of(context).pop();
                                  setState(() {
                                    isLoading = false;
                                  });

                                  //_updateSubscriberList();
                                  //_launchURL;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      margin: EdgeInsets.only(top: 0),
                                      duration: Duration(seconds: 4),
                                      elevation: 80,
                                      backgroundColor: Color(0xff9A9484),
                                      behavior: SnackBarBehavior.floating,
                                      content: Container(
                                        margin: EdgeInsets.zero,
                                        child: const Text(
                                            'Please select subscription option'),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: Dimensions.screenHeight / 13,
                                width: double.maxFinite,
                                margin: EdgeInsets.only(
                                    bottom: 15, top: 5, right: 10),
                                padding: EdgeInsets.only(
                                    left: 10, bottom: 8, right: 10, top: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Color(0xffCFC5A5),
                                      Color(0xff9A9483),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radius20),
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
                            SizedBox(
                              height: Dimensions.screenWidth / 40,
                            ),
                            Center(
                              child: BigText(
                                text: 'Restore Purchases',
                                size: Dimensions.font20,
                                weight: FontWeight.w600,
                                color: Color(0xFF5c524f),
                              ),
                            ),
                            SizedBox(
                              height: Dimensions.screenWidth / 50,
                            ),
                            Center(
                              child: Text(
                                'This subscriptions is manually renewed through telephonic agreement. '
                                'Izinto personnel will arrange a call at least 24h before current term ends. '
                                'your preferences of renewing purchase will be updated on the system for subsequent renewals.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Hind',
                                    letterSpacing: 0.10,
                                    height: 1.1,
                                    color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
