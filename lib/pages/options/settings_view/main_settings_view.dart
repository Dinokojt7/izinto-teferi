import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:izinto/pages/options/settings_view/without_user.dart';
import 'package:izinto/pages/options/settings_view/with_user.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/dialogs/main_dialog.dart';
import '../../../widgets/dialogs/subscription_dialogs/subscription_dialog.dart';
import '../../../widgets/dialogs/token_display/token_status_dialog.dart';

class MainSettingsView extends StatefulWidget {
  const MainSettingsView({Key? key}) : super(key: key);

  @override
  State<MainSettingsView> createState() => _MainSettingsViewState();
}

class _MainSettingsViewState extends State<MainSettingsView> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _name = '';
  String _email = '';
  String _subStatus = '';
  String _surname = '';
  String _phone = '';
  double iTokens = 0.0;
  bool isLoading = false;
  bool isLoadingLog = false;
  bool signOut = false;
  bool isSubscriptionBanner = true;
  bool _isLoading = false;
  bool appInfo = false;
  String quarterlyAmount = '';
  String byAnnualAmount = '';
  int planStatus = 0;
  String startDate = '';
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('izinto');
  late Stream<QuerySnapshot> _streamUserInfo;

  final _showSubscriptionDialog = ValueNotifier<bool>(false);
  bool _showPointsDialog = false;
  final int index = 0;
  late int _carWashPlan;
  late int _laundryPlan;
  late String _carWashInterval;
  late String _laundryInterval;

  @override
  void initState() {
    super.initState();
    _getSubscriptionStatus();
    _getCarSubscription();
    _getLaundrySubscription();
    _streamUserInfo = _referenceUserInfo.snapshots();
    _getData();
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
          _surname = userData['surname'] ?? '';
          _email = userData['email'];
          iTokens = userData['loyalty'];
          //_subStatus = userData['subStatus'];
        });
    });
  }

  void _showAppInfo() {
    setState(() {
      appInfo = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  _getCarSubscription() async {
    await FirebaseFirestore.instance
        .collection('plans')
        .doc('car wash')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          _carWashPlan = userData['quarterly'];
          _carWashInterval = userData['interval'];
        });
    });
  }

  _getLaundrySubscription() async {
    await FirebaseFirestore.instance
        .collection('plans')
        .doc('laundry')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          _laundryPlan = userData['quarterly'];
          _laundryInterval = userData['interval'];
        });
    });
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    //return either settings or authenticate widget
    if (user == null) {
      return SettingViewWithoutUser();
    } else {
      return ValueListenableBuilder(
          valueListenable: _showSubscriptionDialog,
          builder: (context, value, _) {
            return Stack(
              children: [
                Scaffold(
                  backgroundColor: Colors.white.withOpacity(0.6),
                  body: StreamBuilder<QuerySnapshot>(
                    stream: _streamUserInfo,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasError) {
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
                        return SettingsViewWithUser(
                          name: _name,
                          surname: _surname,
                          isLoading: isLoading,
                          iTokens: iTokens,
                          planStatus: planStatus,
                          showDialog: _showSubscriptionDialog,
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
                _showSubscriptionDialog.value
                    ? showSubscriptionSignUp(
                        showDialog: _showSubscriptionDialog,
                        index: index,
                      )
                    : Container(),
                _showPointsDialog
                    // ? MainDialog(
                    //     contents: TokenStatus(tokens: '201', tokenStage: 1, showDialog: false,),
                    //     height: Dimensions.screenHeight / 2,
                    //     width: Dimensions.screenWidth / 1.2,
                    //   )
                    ? Container()
                    : Container(),
                isLoadingLog
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
}
