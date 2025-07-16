import 'package:flutter/material.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_heading.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_section.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../home_view/controller/home_view_controller.dart';
import '../opening_hours.dart';

class CustomerServiceTiles extends StatelessWidget {
  const CustomerServiceTiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Dimensions.height30 / 1.1,
        ),
        SettingsHeading(
          heading: 'Help & feedback',
        ),
        SizedBox(
          height: Dimensions.height20,
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            children: [
              settingsSection(
                subHeading: 'Opening hours',
                onTap: () {
                  Provider.of<HomeViewController>(context, listen: false)
                      .navigateToNestedWidget(context, OpeningHours());
                },
              ),
              SizedBox(
                height: Dimensions.height10,
              ),
              settingsSection(
                subHeading: 'FAQ',
                onTap: () {
                  Provider.of<HomeViewController>(context, listen: false)
                      .navigateToNestedWidget(context, OpeningHours());
                },
              ),
              SizedBox(
                height: Dimensions.height10,
              ),
              settingsSection(
                subHeading: 'Customer service',
                onTap: () {
                  Provider.of<HomeViewController>(context, listen: false)
                      .navigateToNestedWidget(context, OpeningHours());
                },
              ),
              SizedBox(
                height: Dimensions.height30,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
