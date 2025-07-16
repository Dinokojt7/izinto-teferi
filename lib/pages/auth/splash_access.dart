import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:izinto/pages/auth/splash_background.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/integers_and_doubles.dart';
import '../home/home_page.dart';

import 'package:izinto/pages/auth/get_started.dart';

import '../on_boarding/first_onboard.dart';

class SplashAccess extends StatefulWidget {
  const SplashAccess({Key? key}) : super(key: key);

  @override
  State<SplashAccess> createState() => _SplashAccessState();
}

class _SplashAccessState extends State<SplashAccess> {
  bool? _useWhiteStatusBarForeground;

  bool? _useWhiteNavigationBarForeground;

  @override
  void initState() {
    super.initState();
    changeStatusColor(Color(0xFFCFC5A5).withOpacity(0.3), true);
  }

  @override
  void dispose() {
    super.dispose();

    changeStatusColor(Colors.transparent, false);
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

  changeStatusColor(Color color, bool useWhiteForeground) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
      if (useWhiteForeground) {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
        _useWhiteStatusBarForeground = false;
        _useWhiteNavigationBarForeground = true;
      } else {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);
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
    return 2 != 2
        ? FirstOnBoard()
        : Scaffold(
            body: Stack(
              children: [
                Material(
                  child: BackgroundWidget(),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Spacer(),
                    Center(
                      child: Image(
                        image: AssetImage('assets/image/white_logo.png'),
                        color: Colors.white,
                        width: Dimensions.width30 * 2.5,
                      ),
                    ),
                    Spacer(),
                    OnBoardSignIn(),
                    SizedBox(
                      height: Dimensions.height18,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      },
                      child: IntegerText(
                        text: 'Later',
                        size: Dimensions.font16 * 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height30,
                    ),
                  ],
                )
              ],
            ),
          );
  }
}
