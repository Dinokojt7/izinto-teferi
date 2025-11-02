import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/live/view/home_view/specialty_widget.dart';

import '../../../controllers/home_items_controller.dart';
import '../../../controllers/laundry_specialty_controller.dart';

class HomeScreenCategories extends StatelessWidget {
  const HomeScreenCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeItemsController>(builder: (homeItems) {
      return SliverGrid(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        delegate: SliverChildBuilderDelegate(
            (context, index) => SpecialtyWidget(
                  index: index,
                  homeItemList: [],
                  context: context,
                ),
            childCount: 6),
      );
    });
  }
}
