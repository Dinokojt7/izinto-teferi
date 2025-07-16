import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/controllers/cart_controller.dart';
import 'package:izinto/pages/home/home_route.dart';
import 'package:izinto/pages/home/specialty_page_body.dart';
import 'package:izinto/pages/on_boarding/first_onboard.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';

import '../../controllers/laundry_specialty_controller.dart';
import '../../controllers/popular_specialty_controller.dart';
import '../../controllers/recommended_specialty_controller.dart';
import '../../routes/route_helper.dart';
import '../../utils/colors.dart';
import '../auth/sign_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? _useWhiteStatusBarForeground;

  bool? _useWhiteNavigationBarForeground;

  @override
  void initState() {
    super.initState();
    changeStatusColor(Color(0xFFCFC5A5).withOpacity(0.3));
  }

  @override
  void dispose() {
    super.dispose();

    changeStatusColor(Colors.transparent);
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_useWhiteStatusBarForeground != null)
        FlutterStatusbarcolor.setStatusBarWhiteForeground(
            _useWhiteStatusBarForeground!);
      if (_useWhiteNavigationBarForeground != null)
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(
            _useWhiteNavigationBarForeground!);
    }
  }

  changeStatusColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
      if (useWhiteForeground(color)) {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
        _useWhiteStatusBarForeground = false;
        _useWhiteNavigationBarForeground = true;
      } else {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
        _useWhiteStatusBarForeground = false;
        _useWhiteNavigationBarForeground = false;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  changeNavigationColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setNavigationBarColor(color, animate: true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Dimensions.screenWidth / 6),
              child: Container(
                height: Dimensions.screenHeight / 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFCFC5A5).withOpacity(0.3),
                      Color(0xFFCFC5A5),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(Dimensions.radius30 * 20),
                    bottomLeft: Radius.circular(Dimensions.radius30 * 20),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: Dimensions.height45,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            IntegerText(
                              fontWeight: FontWeight.w700,
                              size: Dimensions.font26 / 1.1,
                              color: Colors.black87,
                              align: TextAlign.center,
                              text:
                                  'Get Your Essentials Delivered At Your Convenience',
                            ),
                            SizedBox(
                              height: Dimensions.height45,
                            ),
                            IntegerText(
                                size: Dimensions.font16 / 1.2,
                                color: Colors.black87,
                                align: TextAlign.center,
                                text:
                                    'Wash your laundry, household items, and car at your convenience.'),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: 0,
              left: 0,
              child: Center(
                child: Image(
                  image: AssetImage(
                    'assets/image/driver.png',
                  ),
                  width: Dimensions.width30 * 5.5,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: Dimensions.bottomHeightBar,
        child: Padding(
          padding: EdgeInsets.only(bottom: Dimensions.height30, left: 15),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Image(
                image: AssetImage(
                  'assets/image/artwork.png',
                ),
                width: Dimensions.width30 * 4.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
