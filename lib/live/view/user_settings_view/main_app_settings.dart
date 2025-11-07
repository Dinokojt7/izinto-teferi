import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/address_view/saved_addresses.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/view/profile_view/profile_view.dart';
import 'package:izinto/live/view/user_settings_view/screens/legal_documents/legal_document_screen.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_heading.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_section.dart';
import 'package:izinto/services/firebase_auth_methods.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../../widgets/texts/small_text.dart';
import '../../utilities/colors.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/buttons/delete_widget.dart';
import '../../widgets/generic_header_row.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../home_view/controller/home_view_controller.dart';

class MainAppSettings extends StatefulWidget {
  const MainAppSettings({Key? key}) : super(key: key);

  @override
  State<MainAppSettings> createState() => _MainAppSettingsState();
}

class _MainAppSettingsState extends State<MainAppSettings> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewController>(
        builder: (context, _homeViewController, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: Dimensions.height30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
            child: GenericHeaderRow(
              headingChild: HeadingStyleText(
                text: 'Your profile',
                weight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: Dimensions.height20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              children: [
                settingsSection(
                  subHeading: 'Your addresses',
                  onTap: () {
                    setState(() {
                      SystemNavigation().applyCustomSystemChromeSettings(
                          Colors.white,
                          Brightness.dark,
                          Colors.white,
                          Brightness.dark);
                    });
                    Get.to(
                      () => SavedAddresses(),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 500),
                    );
                  },
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                settingsSection(
                  subHeading: 'Edit profile',
                  onTap: () {
                    setState(() {
                      SystemNavigation().applyCustomSystemChromeSettings(
                          Colors.white,
                          Brightness.dark,
                          Colors.white,
                          Brightness.dark);
                    });
                    Get.to(
                      () => ProfileView(),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 500),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: Dimensions.height30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
            child: GenericHeaderRow(
              headingChild: HeadingStyleText(
                text: 'Payments',
                weight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: Dimensions.height20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              children: [
                settingsSection(
                  subHeading: 'Your payment methods',
                  onTap: () {
                    Get.to(
                      () => SavedAddresses(),
                      transition: Transition.rightToLeftWithFade,
                      duration: Duration(milliseconds: 500),
                    );
                  },
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                settingsSection(
                  subHeading: 'Billing info',
                  onTap: () {
                    Get.to(
                      () => ProfileView(),
                      transition: Transition.rightToLeftWithFade,
                      duration: Duration(milliseconds: 500),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: Dimensions.height30 / 1.1,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
            child: GenericHeaderRow(
              headingChild: HeadingStyleText(
                text: 'Legal',
                weight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: Dimensions.height20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              children: [
                settingsSection(
                  subHeading: 'Privacy policy',
                  onTap: () {
                    setState(() {
                      SystemNavigation().applyCustomSystemChromeSettings(
                          Colors.white,
                          Brightness.dark,
                          Colors.white,
                          Brightness.dark);
                    });
                    Get.to(
                      () => LegalDocumentScreen(
                        documentType: 'privacy-policy',
                        screenTitle: 'Privacy Policy',
                        description:
                            'How we protect and use your personal information',
                        primaryColor: LiveColors.cartBlue,
                        lastUpdated: 'December 2024',
                      ),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 500),
                    );
                  },
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                settingsSection(
                  subHeading: 'Terms & conditions',
                  onTap: () {
                    setState(() {
                      SystemNavigation().applyCustomSystemChromeSettings(
                          Colors.white,
                          Brightness.dark,
                          Colors.white,
                          Brightness.dark);
                    });
                    Get.to(
                      () => LegalDocumentScreen(
                        description:
                            'Please read these terms carefully before using our services',
                        documentType: 'terms-of-use',
                        screenTitle: 'Terms & Conditions',
                        primaryColor: LiveColors.cartBlue,
                        lastUpdated: 'December 2024',
                      ),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 500),
                    );
                  },
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                settingsSection(
                  subHeading: 'Imprint',
                  onTap: () {
                    setState(() {
                      SystemNavigation().applyCustomSystemChromeSettings(
                          Colors.white,
                          Brightness.dark,
                          Colors.white,
                          Brightness.dark);
                    });

                    Get.to(
                      () => LegalDocumentScreen(
                        documentType: 'imprint',
                        screenTitle: 'Imprint',
                        description: 'Company information and legal details',
                        primaryColor: Colors.purple,
                        lastUpdated: 'December 2024',
                      ),
                      transition: Transition.native,
                      duration: Duration(milliseconds: 500),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: Dimensions.height30,
          ),
          GestureDetector(
            onTap: () {
              _homeViewController.confirmRemove(context);
            },
            child: Padding(
              padding: EdgeInsets.only(
                  left: 20.0, top: 10.0, right: Dimensions.screenWidth / 1.5),
              child: DeleteWidget(
                description: 'Log out',
                imagePath: 'assets/image/log-out.png',
              ),
            ),
          ),
          SizedBox(
            height: Dimensions.height15,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
            child: Row(
              children: [
                SmallText(text: 'App version: 1 . 0 . 0'),
              ],
            ),
          ),
          SizedBox(
            height: Dimensions.height20,
          )
        ],
      );
    });
  }
}
