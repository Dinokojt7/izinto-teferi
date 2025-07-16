import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:izinto/pages/subscriptions/subscriptions.dart';
import '../../../pages/subscriptions/car_wash_subscription.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import 'apply_sub_column.dart';

class ApplySub extends StatefulWidget {
  final void Function() onSubmitted;
  final void Function() closeSubView;
  final int discountedAmount;
  final int planStatus;
  final String subType;

  ApplySub({
    Key? key,
    required this.onSubmitted,
    required this.closeSubView,
    required this.discountedAmount,
    required this.planStatus,
    required this.subType,
  }) : super(key: key);

  @override
  State<ApplySub> createState() => _ApplySubState();
}

class _ApplySubState extends State<ApplySub> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isLoading = false;
  String quarterlyAmount = '';
  String byAnnualAmount = '';
  int carMonthlyAmount = 0;
  int carQuarterlyAmount = 0;

  @override
  void initState() {
    super.initState();
    _getSubscriptions();
    _getCarSubscriptions();
  }

  _getCarSubscriptions() async {
    await FirebaseFirestore.instance
        .collection('plans')
        .doc('car wash')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          carQuarterlyAmount = userData['quarterly'];
          carMonthlyAmount = userData['monthly'];
        });
    });
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
    void _showSubscriptionPanel(String subType) {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          isScrollControlled: true,
          useSafeArea: true,
          context: context,
          builder: (context) {
            return subType == 'laundry'
                ? SubscriptionPage(
                    quarterlyAmount: quarterlyAmount,
                    byAnnualAmount: byAnnualAmount,
                  )
                : CarWashSubscription(
                    quarterlyAmount: carQuarterlyAmount,
                    carMonthlyAmount: carMonthlyAmount);
          });
    }

    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                  height: Dimensions.screenHeight / 5.2,
                  color: Colors.transparent),
            ),
            Expanded(
              child: Container(
                height: Dimensions.screenHeight / 5.2,
                color: Colors.transparent,
                child: Column(
                  children: [
                    ApplySubColumn(closeSubView: widget.closeSubView),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        widget.planStatus > 0
                            ? 'Apply R${widget.discountedAmount}.00 discount'
                            : 'You\'re not subscribed',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: Dimensions.font16 / 1.1,
                          fontFamily: 'Hind',
                          letterSpacing: 0.10,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLoading = true;
                        });
                        Future.delayed(const Duration(seconds: 2), () {
                          widget.planStatus > 0
                              ? widget.onSubmitted
                              : _showSubscriptionPanel(widget.subType);
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      },
                      child: Container(
                        height: Dimensions.screenHeight / 20,
                        width: Dimensions.screenWidth / 3.5,
                        padding: EdgeInsets.only(
                            left: Dimensions.width20 * 1.2,
                            right: Dimensions.width15 * 1.2),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xffCFC5A5), Color(0xff9A9483)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                offset: Offset(2, 2),
                                color:
                                    AppColors.mainBlackColor.withOpacity(0.2),
                              ),
                              BoxShadow(
                                blurRadius: 3,
                                offset: Offset(-5, -5),
                                color: AppColors.iconColor1.withOpacity(0.1),
                              ),
                            ],
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius15),
                            border: Border.all(width: 1, color: Colors.white),
                            color: Colors.white),
                        child: _isLoading
                            ? Transform.scale(
                                scale: 0.4,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  widget.planStatus > 0 ? 'Continue' : 'View',
                                  style: TextStyle(
                                      fontFamily: 'Hind',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Dimensions.height10 / 2),
            height: Dimensions.screenHeight / 5.2,
            width: Dimensions.width30,
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: Dimensions.screenHeight / 15,
                  width: Dimensions.width10 / 11.5,
                  decoration: BoxDecoration(
                    color: Color(0xFFCFC5A5),
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                  ),
                ),
                widget.subType == 'laundry'
                    ? Icon(
                        Icons.local_laundry_service_outlined,
                        color: Color(0xFFCFC5A5),
                        size: Dimensions.iconSize26 * 1.2,
                      )
                    : Image(
                        color: Color(0xFFCFC5A5),
                        image: AssetImage('assets/image/carwash.png'),
                        width: 30,
                      ),
                Container(
                  height: Dimensions.screenHeight / 15,
                  width: Dimensions.width10 / 11.5,
                  decoration: BoxDecoration(
                    color: Color(0xFFCFC5A5),
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
