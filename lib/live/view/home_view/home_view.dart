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
import '../address_view/controller/address_dropdown_controller.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Gracefully activate HomeView without collisions
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    // Single application point in build
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    if (user != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: _streamUserInfo,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.connectionState == ConnectionState.active) {
            return MainScaffold();
          }
          return _buildLoadingScreen();
        },
      );
    } else {
      return MainScaffold();
    }
  }

  Widget _buildLoadingScreen() {
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
  }
}
