import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/small_text.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../widgets/generic_header_row.dart';
import '../../widgets/no_user_page.dart';
import '../../widgets/text_widgets/heading_style_text.dart';

class InboxView extends StatelessWidget {
  const InboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    if (user == null) {
      return NoUserPage(
        title: 'Inbox',
        message: 'Log in to see your messages.',
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
          body: SafeArea(
            child: Column(
              children: [
                // App Bar
                GenericAppBar(
                  heading: 'Inbox',
                  removeLeading: true,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        Dimensions.width20,
                        Dimensions.height30,
                        Dimensions.width20,
                        Dimensions.height20),
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            width: double.maxFinite,
                            height: Dimensions.bottomHeightBar,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors
                                      .grey.shade300, // Set the border color
                                  width: 1.0, // Set the border width
                                ),
                              ),
                            ),
                            child: Text(
                              'Select the relevant chat from your past orders',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: Dimensions.font16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16.0, top: 20.0, right: 16.0),
                            child: GenericHeaderRow(
                              headingChild: Row(
                                children: [
                                  HeadingStyleText(
                                    text: 'Your chats',
                                    weight: FontWeight.w600,
                                  ),
                                  SizedBox(
                                    width: Dimensions.width10,
                                  ),
                                  SmallText(
                                      height: 1.5,
                                      color: Colors.black,
                                      size: Dimensions.font16 / 1.5,
                                      text: '0 items')
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
    }
  }
}
