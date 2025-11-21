import 'package:flutter/material.dart';
import 'package:izinto/live/view/auth_view/phone_auth_view.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';

import '../auxiliery_classes/generic_app_bar.dart';
import '../utilities/generic_system_navigation.dart';
import '../view/user_settings_view/view_widgets/customer_service_tiles.dart';
import 'generic_center_dialog.dart';

class NoUserPage extends StatefulWidget {
  final String title;
  final String message;
  final bool isSettingView;
  const NoUserPage(
      {Key? key,
      required this.title,
      required this.message,
      required this.isSettingView})
      : super(key: key);

  @override
  State<NoUserPage> createState() => _NoUserPageState();
}

class _NoUserPageState extends State<NoUserPage> {
  @override
  Widget build(BuildContext context) {
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.97),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            GenericAppBar(
              heading: widget.title,
              removeLeading: true,
            ),
            Expanded(
              child: GenericCenterDialog(
                callBack: () {
                  homeViewController.onPopNavigation(context, PhoneAuthView());
                  Future.delayed(const Duration(milliseconds: 510), () async {
                    setState(() {
                      SystemNavigation().applyCustomSystemChromeSettings(
                          Colors.white,
                          Brightness.dark,
                          Colors.white,
                          Brightness.dark);
                    });
                  });
                },
                emoji: '\u{1F494}',
                heading: 'Not yet signed in',
                description: widget.message,
                buttonText: 'Sign in',
              ),
            ),
            if (widget.isSettingView) CustomerServiceTiles()
          ],
        ),
      ),
    );
  }
}
