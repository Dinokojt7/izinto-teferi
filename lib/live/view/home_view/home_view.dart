import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:izinto/live/auxiliery_classes/live_progress_indicator.dart';
import 'package:izinto/live/view/home_view/sliver_home_page.dart';
import 'package:izinto/live/view/home_view/view_widgets/main_scaffold.dart';
import 'package:izinto/live/view/user_settings_view/user_settings_view.dart';
import 'package:izinto/live/widgets/lock_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
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
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     systemNavigationBarColor: Colors.black,
    //     systemNavigationBarIconBrightness: Brightness.light));

    // Provider.of<ProfileViewController>(context, listen: false).getData();
    //
    // Provider.of<ProfileViewController>(context, listen: false).getAddresses();
    _streamUserInfo = _referenceUserInfo.snapshots();
  }

  // @override
  // void didChangeDependencies() {
  //   var navBarColor =
  //       Provider.of<HomeViewController>(context).navigationBarColor;
  //   SystemNavigation()
  //       .applyCustomSystemChromeSettings(Colors.black, Brightness.dark);
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    final _isLockScreen = homeViewController.isLogOutLoading;

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
            return Stack(
              children: [
                MainScaffold(
                    // index: _selectedIndex,

                    ),
                if (_isLockScreen) LockScreen()
              ],
            );
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
      return MainScaffold(
          //  index: _selectedIndex,
          );
    }
  }
}
