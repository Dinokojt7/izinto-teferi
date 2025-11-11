import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:izinto/live/auxiliery_classes/live_progress_indicator.dart';
import 'package:izinto/live/view/home_view/sliver_home_page.dart';
import 'package:izinto/live/view/home_view/view_widgets/main_scaffold.dart';
import 'package:izinto/live/view/user_settings_view/user_settings_view.dart';
import 'package:izinto/live/widgets/lock_screen.dart';
import 'package:provider/provider.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/user.dart';
import '../../utilities/generic_system_navigation.dart';
import '../cart_view/cart_view_page.dart';
import '../checkout_view/checkout_page.dart';
import '../profile_view/controller/profile_view_controller.dart';
import '../profile_view/profile_view.dart';
import 'controller/home_view_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('plans');
  late Stream<QuerySnapshot> _streamUserInfo;

  @override
  void initState() {
    super.initState();
    _streamUserInfo = _referenceUserInfo.snapshots();

    // Apply system chrome settings immediately when HomeView loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applySystemChromeSettings();
    });
  }

  void _applySystemChromeSettings() {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Apply system chrome settings whenever dependencies change
    _applySystemChromeSettings();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);

    // Ensure we're on the first tab when coming from checkout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeViewController.currentIndex != 0) {
        homeViewController.changeIndex(0, true);
      }
    });

    // Apply system chrome settings on every build to ensure consistency
    _applySystemChromeSettings();

    final _isLockScreen = homeViewController.isLogOutLoading;

    // Apply system chrome settings on every build to ensure consistency
    _applySystemChromeSettings();

    if (user != null) {
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
            return MainScaffold();
          }

          return Scaffold(
            body: Container(
              height: double.maxFinite,
              color: Colors.white,
              child: Center(
                child: LiveProgressIndicator(
                  hasOwnDialog: true,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      );
    } else {
      return MainScaffold();
    }
  }
}
