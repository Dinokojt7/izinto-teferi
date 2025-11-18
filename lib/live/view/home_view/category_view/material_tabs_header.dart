import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/live/utilities/live_dimensions.dart';
import 'package:izinto/live/widgets/buttons/header_text_button.dart';
import 'package:izinto/live/widgets/buttons/highlight_button.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/laundry_specialty_controller.dart';
import '../../../../controllers/popular_specialty_controller.dart';
import '../../../../controllers/sneakers_blankets_controller.dart';
import '../../../../controllers/tabs_header.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/icons/back_arrow.dart';
import '../../../widgets/icons/tabs_header_back_arrow.dart';
import 'controller/category_view_controller.dart';

class MaterialTabsHeader extends StatefulWidget {
  const MaterialTabsHeader({Key? key}) : super(key: key);

  @override
  State<MaterialTabsHeader> createState() => _MaterialTabsHeaderState();
}

class _MaterialTabsHeaderState extends State<MaterialTabsHeader>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List materialTabs = [];
  final List<List> mainCategoriesList = [
    //   Get.find<SneakersBlanketsController>().sneakersAndBlanketsList,
    Get.find<PopularSpecialtyController>().popularSpecialtyList,
  ];
  final List headerTabs = Get.find<TabsHeaderController>().tabsHeaderList;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: headerTabs.length, vsync: this);

    // Listen to changes in the TabController index and update the view controller
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final categoryViewController =
              Provider.of<CategoryViewController>(context, listen: false);
          // materialTabs = mainCategoriesList[categoryViewController.];
          categoryViewController.updateCategoryList(
              _tabController.index, _tabController.index);
          categoryViewController.updateTabsControllerIndex(
              mainCategoriesList[_tabController.index][0].name, 0);
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: Dimensions.width30 * 1.1),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: // Listen to changes in the CategoryViewController to update the TabController
                      Consumer<CategoryViewController>(
                          builder: (context, categoryViewController, child) {
                    if (_tabController.index !=
                        categoryViewController.mainCategoryListIndex) {
                      _tabController.animateTo(
                          categoryViewController.mainCategoryListIndex);
                    }
                    return Material(
                      color: Colors.transparent,
                      child: GetBuilder<TabsHeaderController>(
                          builder: (tabsHeader) {
                        final List<Widget> _headerTabs = [];
                        for (var i = 0;
                            i < tabsHeader.tabsHeaderList.length;
                            i++) {
                          _headerTabs.add(
                            Tab(
                              child: HeaderTextButton(
                                text: tabsHeader.tabsHeaderList[i].name,
                              ),
                            ),
                          );
                        }

                        return TabBar(
                          labelPadding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.0),
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.label,
                          physics: AlwaysScrollableScrollPhysics(),
                          indicatorWeight: 4,
                          indicatorColor:
                              //isSpecialtiesLoaded
                              //   ?
                              LiveColors.secondary,
                          // :
                          //Colors.transparent,
                          controller: _tabController,
                          tabs: _headerTabs,
                          // labelColor: AppColors.fontColor,
                          // unselectedLabelColor: Colors.grey,
                        );
                      }),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabsHeaderBackArrow(
                    isSpecialtyView: true,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
