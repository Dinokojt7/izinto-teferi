import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/address_view/saved_addresses.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/view/profile_view/profile_view.dart';
import 'package:izinto/live/view/user_settings_view/screens/legal_documents/legal_document_screen.dart';
import 'package:izinto/live/widgets/buttons/destructive_button.dart';
import 'package:izinto/live/widgets/grouped_list/grouped_card.dart';
import 'package:izinto/live/widgets/grouped_list/grouped_row.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../utilities/colors.dart';
import '../../utilities/generic_system_navigation.dart';
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
      final profileController = Provider.of<ProfileViewController>(context);

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          children: [
            SizedBox(height: Dimensions.height20),
            _buildProfileCard(profileController),
            SizedBox(height: Dimensions.height30),
            _buildSectionLabel('Account'),
            SizedBox(height: Dimensions.height10),
            GroupedCard(children: [
              GroupedRow(
                icon: Icons.location_on_rounded,
                tint: LiveColors.secondary,
                label: 'Your addresses',
                onTap: () {
                  Get.to(
                    () => SavedAddresses(),
                    transition: Transition.native,
                    duration: Duration(milliseconds: 500),
                  );
                },
              ),
              GroupedRow(
                icon: Icons.person_rounded,
                tint: LiveColors.secondary,
                label: 'Edit profile',
                divider: false,
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    SystemNavigation().applyCustomSystemChromeSettings(
                        Colors.white.withOpacity(0.95),
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
            ]),
            SizedBox(height: Dimensions.height30),
            _buildSectionLabel('Legal'),
            SizedBox(height: Dimensions.height10),
            GroupedCard(children: [
              GroupedRow(
                icon: Icons.privacy_tip_rounded,
                tint: LiveColors.lavender,
                label: 'Privacy policy',
                onTap: () {
                  SystemNavigation().applyCustomSystemChromeSettings(
                      Colors.white, Brightness.dark, Colors.white, Brightness.dark);
                  Get.to(
                    () => LegalDocumentScreen(
                      documentType: 'privacy-policy',
                      screenTitle: 'Privacy Policy',
                      description: 'How we protect and use your personal information',
                      primaryColor: LiveColors.cartBlue,
                      lastUpdated: 'December 2024',
                    ),
                    transition: Transition.native,
                    duration: Duration(milliseconds: 500),
                  );
                },
              ),
              GroupedRow(
                icon: Icons.description_rounded,
                tint: LiveColors.lavender,
                label: 'Terms & conditions',
                onTap: () {
                  SystemNavigation().applyCustomSystemChromeSettings(
                      Colors.white, Brightness.dark, Colors.white, Brightness.dark);
                  Get.to(
                    () => LegalDocumentScreen(
                      description: 'Please read these terms carefully before using our services',
                      documentType: 'terms-of-use',
                      screenTitle: 'Terms & Conditions',
                      primaryColor: LiveColors.cartBlue,
                      lastUpdated: 'June 2025',
                    ),
                    transition: Transition.native,
                    duration: Duration(milliseconds: 500),
                  );
                },
              ),
              GroupedRow(
                icon: Icons.info_rounded,
                tint: LiveColors.lavender,
                label: 'Imprint',
                divider: false,
                onTap: () {
                  Get.to(
                    () => LegalDocumentScreen(
                      documentType: 'imprint',
                      screenTitle: 'Imprint',
                      description: 'Company information and legal details',
                      primaryColor: Colors.purple,
                      lastUpdated: 'June 2025',
                    ),
                    transition: Transition.native,
                    duration: Duration(milliseconds: 500),
                  );
                },
              ),
            ]),
            SizedBox(height: Dimensions.height30),
            DestructiveButton(
              text: 'Log out',
              icon: Icons.logout_rounded,
              onTap: () => _homeViewController.confirmRemove(context),
            ),
            SizedBox(height: Dimensions.height15),
            PrimaryStyleText(
              text: 'App version: 1.0.0',
              size: Dimensions.font16 * 0.75,
              color: Colors.black45,
            ),
            SizedBox(height: Dimensions.height20),
          ],
        ),
      );
    });
  }

  Widget _buildSectionLabel(String text) => Padding(
        padding: EdgeInsets.only(left: Dimensions.width10 * 0.4),
        child: HeadingStyleText(text: text, weight: FontWeight.w600, size: Dimensions.font20 * 0.85),
      );

  Widget _buildProfileCard(ProfileViewController controller) {
    final fullName = '${controller.firstName} ${controller.lastName}'.trim();
    return GroupedCard(children: [
      Padding(
        padding: EdgeInsets.all(Dimensions.width15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: LiveColors.primary,
              child: HeadingStyleText(
                text: fullName.isNotEmpty ? fullName.substring(0, 1).toUpperCase() : '?',
                color: Colors.white,
                weight: FontWeight.w600,
                size: Dimensions.font20,
              ),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadingStyleText(
                    text: fullName.isNotEmpty ? fullName : 'Welcome',
                    weight: FontWeight.w600,
                    size: Dimensions.font16,
                  ),
                  SizedBox(height: 2),
                  PrimaryStyleText(
                    text: controller.phoneNumber,
                    size: Dimensions.font16 * 0.8,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: LiveColors.standardBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(99),
              ),
              child: PrimaryStyleText(
                text: 'R${controller.walletBalance}',
                weight: FontWeight.w600,
                size: Dimensions.font16 * 0.8,
                color: LiveColors.standardBlue,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
