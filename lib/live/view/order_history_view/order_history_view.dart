import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../widgets/generic_center_dialog.dart';
import '../../widgets/no_user_page.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    if (user == null) {
      return NoUserPage(
        title: 'Orders',
        message: 'Log in to see your orders.',
        isSettingView: false,
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.97),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: Column(
          children: [
            // App Bar
            GenericAppBar(
              heading: 'Orders',
              removeLeading: true,
            ),
            Expanded(
              child: Padding(
                // App Bar
                padding: EdgeInsets.only(
                    top: Dimensions.height30, bottom: Dimensions.height20),
                child: GenericCenterDialog(
                  emoji: '\u{1F9FA}',
                  heading: 'No past orders',
                  description:
                      '..yet! View and explore services that are available in your area to get started.',
                  buttonText: 'Browse services',
                  callBack: () {},
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
