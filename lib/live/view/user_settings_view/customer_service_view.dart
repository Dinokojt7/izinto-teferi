import 'package:flutter/material.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/customer_service_tiles.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/promo_container.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_heading.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_section.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../widgets/buttons/blue_text_button.dart';
import '../../widgets/generic_center_dialog.dart';
import '../../widgets/generic_header_row.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../home_view/controller/home_view_controller.dart';
import '../home_view/sliver_home_page.dart';
import 'opening_hours.dart';

class CustomerServiceView extends StatelessWidget {
  final String promoCode;
  const CustomerServiceView({Key? key, required this.promoCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: Dimensions.height30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
            child: GenericHeaderRow(
              headingChild: HeadingStyleText(
                text: 'Your orders',
                weight: FontWeight.w600,
              ),
              actionButtonChild: BlueTextButton(
                text: 'See all',
                onTap: () {
                  _homeViewController.changeIndex(1, false);
                },
              ),
            ),
          ),
          SizedBox(
            height: Dimensions.height10 + Dimensions.height15,
          ),
          GenericCenterDialog(
            emoji: '\u{1F9FA}',
            heading: 'No past orders',
            description:
                '..yet! View and explore services that are available in your area to get started.',
            buttonText: 'Browse services',
            callBack: () {
              _homeViewController.changeIndex(0, false);
            },
          ),
          SizedBox(
            height: Dimensions.height30,
          ),
          SettingsHeading(
            heading: 'Promotions',
          ),
          SizedBox(
            height: Dimensions.height20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              children: [
                settingsSection(
                  subHeading: 'Promo codes',
                  onTap: () {
                    Provider.of<HomeViewController>(context, listen: false)
                        .copyPromoCodeToClip(context, promoCode);
                  },
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),
                PromoContainer(
                  promoCode: promoCode,
                ),
                SizedBox(
                  height: Dimensions.height30,
                ),
              ],
            ),
          ),
          CustomerServiceTiles()
        ],
      ),
    );
  }
}
