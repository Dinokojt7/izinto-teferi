import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/home_view/home_screen_app_bar_delegate.dart';

import '../../../utils/dimensions.dart';
import 'home_screen_categories.dart';

class SliverHomePage extends StatefulWidget {
  const SliverHomePage({Key? key}) : super(key: key);

  @override
  State<SliverHomePage> createState() => _SliverHomePageState();
}

class _SliverHomePageState extends State<SliverHomePage> {
  var _currPageValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: HomeScreenAppBarDelegate(
              expandedHeight: 200.0,
            ),
          ),
          // Add a SliverToBoxAdapter to add some space between the header and the categories
          SliverToBoxAdapter(
            child: SizedBox(
                height: Dimensions.screenHeight /
                    2.8), // Adjust this value as needed
          ),
          HomeScreenCategories(),
        ],
      ),
    );
  }
}
