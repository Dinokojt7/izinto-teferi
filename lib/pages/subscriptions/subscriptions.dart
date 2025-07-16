import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user.dart';
import '../../utils/dimensions.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/texts/big_text.dart';

class SubscriptionPage extends StatefulWidget {
  final String quarterlyAmount;
  final String byAnnualAmount;

  const SubscriptionPage(
      {Key? key, required this.quarterlyAmount, required this.byAnnualAmount})
      : super(key: key);
  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isQuarterly = false;
  bool isBiAnnually = false;
  String chosenPlan = '';
  int remainingKilograms = 0;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('izinto');
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

  _updateSubscriberList() async {
    User? user = await _firebaseAuth.currentUser;
    remainingKilograms = isBiAnnually
        ? 60
        : isQuarterly
            ? 120
            : 0;
    FirebaseFirestore.instance
        .collection('premium members')
        .doc('laundry subscriptions')
        .collection(chosenPlan)
        .doc(user?.uid)
        .set({
      'remainingKilograms': remainingKilograms,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        height: Dimensions.screenHeight,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8, left: 20, top: 0, bottom: 0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: Dimensions.screenHeight / 2.3,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/image/laundry-sub.jpg'),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Image(
                                  image: AssetImage(
                                      'assets/image/laundry-detergent.png'),
                                  width: Dimensions.screenWidth / 4,
                                ),
                                SizedBox(
                                  height: Dimensions.height45,
                                ),
                                BigText(
                                  size: Dimensions.height45 / 1.8,
                                  text: 'Choose a laundry subscription',
                                  color: const Color(0Xff353839),
                                  weight: FontWeight.w600,
                                  maxLines: 3,
                                  height: 1,
                                  align: TextAlign.center,
                                ),
                                SizedBox(
                                  height: Dimensions.height10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.screenWidth / 3),
                                  child: Divider(
                                    color: const Color(0Xff353839)
                                        .withOpacity(0.9),
                                    height: 20,
                                    thickness: 4,
                                  ),
                                ),
                                SizedBox(
                                  height: Dimensions.height10,
                                ),
                                SmallText(
                                  size: Dimensions.font16,
                                  color: Colors.black54,
                                  text:
                                      'Plans includes - Once a week pick-up, washing, drying, ironing and delivery of up to 5kg of items in the laundry category.',
                                ),
                                Divider(
                                  color: Colors.black26,
                                  height: 20,
                                ),
                                SizedBox(
                                  height: Dimensions.height10,
                                ),
                                Row(
                                  children: [
                                    AppIcon(
                                      size: 25,
                                      boxBorder: Border.all(
                                        width: 2,
                                        color: Color(0xff353839),
                                      ),
                                      backgroundColor: Colors.white,
                                      weight: 20,
                                      icon: MdiIcons.check,
                                      iconColor: Color(0Xff353839),
                                      iconSize: 20,
                                    ),
                                    SizedBox(
                                      width: Dimensions.width10,
                                    ),
                                    Text(
                                      'Arrange pickups',
                                      style: TextStyle(
                                          fontSize: Dimensions.font16,
                                          color: const Color(0Xff353839),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Dimensions.height15,
                                ),
                                Row(
                                  children: [
                                    AppIcon(
                                      size: 25,
                                      boxBorder: Border.all(
                                        width: 2,
                                        color: Color(0xff353839),
                                      ),
                                      backgroundColor: Colors.white,
                                      weight: 20,
                                      icon: MdiIcons.check,
                                      iconColor: Color(0Xff353839),
                                      iconSize: 20,
                                    ),
                                    SizedBox(
                                      width: Dimensions.width10,
                                    ),
                                    Text(
                                      'Set wash instructions',
                                      style: TextStyle(
                                          fontSize: Dimensions.font16,
                                          color: const Color(0Xff353839),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Dimensions.height15,
                                ),
                                Row(
                                  children: [
                                    AppIcon(
                                      size: 25,
                                      boxBorder: Border.all(
                                        width: 2,
                                        color: Color(0xff353839),
                                      ),
                                      backgroundColor: Colors.white,
                                      weight: 20,
                                      icon: MdiIcons.check,
                                      iconColor: Color(0Xff353839),
                                      iconSize: 20,
                                    ),
                                    SizedBox(
                                      width: Dimensions.width10,
                                    ),
                                    Text(
                                      'Request rewash',
                                      style: TextStyle(
                                          fontSize: Dimensions.font16,
                                          color: const Color(0Xff353839),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isBiAnnually = false;
                                      isQuarterly = true;
                                      chosenPlan = 'quarterly';
                                    });
                                  },
                                  child: Container(
                                    width: double.maxFinite,
                                    margin: EdgeInsets.only(
                                        bottom: 10, top: 10, right: 10),
                                    padding: EdgeInsets.only(
                                        left: 10, bottom: 8, right: 10, top: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffB09B71)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius15),
                                      border: isQuarterly
                                          ? Border.all(
                                              width: 2,
                                              color: const Color(0xFF5c524f))
                                          : Border.all(
                                              width: 0.1,
                                              color: Color(0xff966C3B)),
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
                                              text:
                                                  'R${widget.quarterlyAmount} / 12 weeks (60kg)',
                                              color: Color(0xFF5c524f),
                                              size: Dimensions.font16 / 1.05,
                                              weight: FontWeight.w600,
                                            ),
                                            SmallText(
                                                color: Colors.black54,
                                                text: '(5kg/week)'),
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
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isBiAnnually = true;
                                      isQuarterly = false;
                                      chosenPlan = 'bi-annually';
                                    });
                                  },
                                  child: Container(
                                      width: double.maxFinite,
                                      margin: EdgeInsets.only(
                                          bottom: 15, top: 5, right: 10),
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          bottom: 8,
                                          right: 10,
                                          top: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffB09B71)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radius15),
                                        border: isBiAnnually
                                            ? Border.all(
                                                width: 2,
                                                color: const Color(0xFF5c524f))
                                            : Border.all(
                                                width: 0.1,
                                                color: Color(0xff966C3B)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          BigText(
                                            text: 'By-Annual',
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
                                                text:
                                                    'R${widget.byAnnualAmount} / 24 weeks (120kg)',
                                                color: Color(0xFF5c524f),
                                                size: Dimensions.font16 / 1.05,
                                                weight: FontWeight.w600,
                                              ),
                                              SmallText(
                                                  color: Colors.black54,
                                                  text: '(5kg/week)'),
                                            ],
                                          ),
                                          AppIcon(
                                            size: 25,
                                            boxBorder: Border.all(
                                              width: 2,
                                              color: !isBiAnnually
                                                  ? Colors.white
                                                  : Color(0Xff353839)
                                                      .withOpacity(0.9),
                                            ),
                                            backgroundColor: !isBiAnnually
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
                                  onTap: () async {
                                    if (chosenPlan != '') {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      DateTime date = DateTime.now();
                                      User? user =
                                          await _firebaseAuth.currentUser;
                                      remainingKilograms = isBiAnnually
                                          ? 60
                                          : isQuarterly
                                              ? 120
                                              : 0;
                                      await FirebaseFirestore.instance
                                          .collection('premium members')
                                          .doc('laundry subscriptions')
                                          .collection(user!.uid)
                                          .doc(chosenPlan)
                                          .set({
                                        'remainingKilograms':
                                            remainingKilograms,
                                        'createdAt': DateTime.now(),
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user?.uid)
                                          .collection('Subscriptions')
                                          .doc('plan')
                                          .set({
                                        'date': date,
                                        'remainingKilograms':
                                            remainingKilograms,
                                        'remaining washes':
                                            remainingKilograms / 5,
                                        'createdAt': DateTime.now(),
                                      });
                                      Navigator.of(context).pop();
                                      setState(() {
                                        isLoading = false;
                                      });
                                      //_updateSubscriberList();
                                      //_launchURL;
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                              ],
                            ),
                          )
                        ],
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
