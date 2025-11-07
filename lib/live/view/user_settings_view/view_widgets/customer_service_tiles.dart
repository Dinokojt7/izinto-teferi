import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/frequently_asked_questions/frequently_asked_questions.dart';
import 'package:izinto/live/view/user_settings_view/screens/customer_service_screen.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_heading.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_section.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../home_view/controller/home_view_controller.dart';
import '../opening_hours.dart';

class CustomerServiceTiles extends StatefulWidget {
  const CustomerServiceTiles({Key? key}) : super(key: key);

  @override
  State<CustomerServiceTiles> createState() => _CustomerServiceTilesState();
}

class _CustomerServiceTilesState extends State<CustomerServiceTiles> {
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
                  Get.to(
                    () => FrequentlyAskedQuestions(),
                    transition: Transition.native,
                    duration: Duration(milliseconds: 500),
                  );
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
              ),
              SizedBox(
                height: Dimensions.height10,
              ),
              settingsSection(
                subHeading: 'Customer service',
                onTap: () {
                  Provider.of<HomeViewController>(context, listen: false)
                      .navigateToNestedWidget(context, CustomerServiceScreen());
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
