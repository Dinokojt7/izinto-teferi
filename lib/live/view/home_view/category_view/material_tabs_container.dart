import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/utilities/live_dimensions.dart';
import 'package:izinto/live/widgets/buttons/highlight_button.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/laundry_specialty_controller.dart';
import '../../../../controllers/popular_specialty_controller.dart';
import 'controller/category_view_controller.dart';

class MaterialTabsContainer extends StatefulWidget {
  final int categoryPageId;
  const MaterialTabsContainer({Key? key, required this.categoryPageId})
      : super(key: key);

  @override
  State<MaterialTabsContainer> createState() => _MaterialTabsContainerState();
}

class _MaterialTabsContainerState extends State<MaterialTabsContainer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List materialTabs = [];
  final List<List> mainCategoriesList = [
    Get.find<LaundrySpecialtyController>().laundrySpecialtyList,
    Get.find<PopularSpecialtyController>().popularSpecialtyList,
    Get.find<LaundrySpecialtyController>().laundrySpecialtyList,
  ];

  @override
  void initState() {
    super.initState();
    materialTabs = mainCategoriesList[widget.categoryPageId];
    _tabController = TabController(length: materialTabs.length, vsync: this);

    // Listen to changes in the TabController index and update the view controller
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final categoryViewController =
              Provider.of<CategoryViewController>(context, listen: false);
          categoryViewController.updateTabsControllerIndex(
              materialTabs[_tabController.index].name, _tabController.index);
        });
      }
    });
  }

  @override
  void didUpdateWidget(MaterialTabsContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryPageId != widget.categoryPageId) {
      _tabController.dispose(); // Dispose old controller
      materialTabs = mainCategoriesList[widget.categoryPageId];
      _tabController = TabController(length: materialTabs.length, vsync: this);
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final categoryViewController =
                Provider.of<CategoryViewController>(context, listen: false);
            categoryViewController.updateTabsControllerIndex(
                materialTabs[_tabController.index].name, _tabController.index);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _categoriesHeaderTabs = [];
    for (var i = 0; i < materialTabs.length; i++) {
      _categoriesHeaderTabs.add(
        Consumer<CategoryViewController>(
            builder: (context, categoryViewController, child) {
          final specialtyViewed = categoryViewController.specialtyName;
          return Tab(
            child: HighlightButton(
              text: materialTabs[i].name,
              weight: FontWeight.w600,
              isViewing: materialTabs[i].name == specialtyViewed ? true : false,
            ),
          );
        }),
      );
    }

    // Listen to changes in the CategoryViewController to update the TabController
    return Consumer<CategoryViewController>(
        builder: (context, categoryViewController, child) {
      if (_tabController.index != categoryViewController.tabsIndex) {
        _tabController.animateTo(categoryViewController.tabsIndex);
      }
      return Material(
        elevation: 1.5,
        shadowColor: Colors.black54,
        color: Colors.white,
        child: TabBar(
          labelPadding:
              EdgeInsets.symmetric(horizontal: 8.0), // Symmetric padding
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          physics: AlwaysScrollableScrollPhysics(),
          indicatorColor: Colors.transparent,
          controller: _tabController,
          tabs: _categoriesHeaderTabs,
        ),
      );
    });
  }
}
