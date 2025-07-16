import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/home_view/category_view/material_tabs_container.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/cta_button.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/page_view_items.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/laundry_specialty_controller.dart';
import '../../../../controllers/popular_specialty_controller.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../utilities/live_dimensions.dart';
import '../../../widgets/buttons/highlight_button.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/text_widgets/description_text.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../../../widgets/text_widgets/introduction_text.dart';
import '../../../widgets/text_widgets/small_black_bold.dart';
import 'controller/category_view_controller.dart';
import 'material_tabs_header.dart';

class MockupCategoryView extends StatefulWidget {
  final int pageId;
  const MockupCategoryView({Key? key, required this.pageId}) : super(key: key);

  @override
  State<MockupCategoryView> createState() => _MockupCategoryViewState();
}

class _MockupCategoryViewState extends State<MockupCategoryView>
    with SingleTickerProviderStateMixin {
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
    materialTabs = mainCategoriesList[widget.pageId];
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
  void didUpdateWidget(MockupCategoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageId != widget.pageId) {
      setState(() {
        materialTabs = mainCategoriesList[widget.pageId];
      });
      //_tabController.dispose();
      //_tabController = TabController(length: materialTabs.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabs = [];
    final List<Widget> _tabItems = [];
    for (var i = 0; i < materialTabs.length; i++) {
      _tabs.add(
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
      _tabItems.add(PageViewItems(
        serviceViewed: '',
      ));
    }
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverPersistentHeader(
            delegate: SpecialtiesHeaderTabsAppBarDelegate(
              expandedHeight: 100,
              tabController: _tabController,
              tabs: _tabs,
              pageId: widget.pageId,
            ),
            pinned: true,
          ),
        ];
      },
      body: Container(
        color: Colors.white.withOpacity(0.975),
        child: TabBarView(
          controller: _tabController,
          children: _tabItems,
        ),
      ),
    );
  }
}

class SpecialtiesHeaderTabsAppBarDelegate
    extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final TabController tabController;
  final List<Widget> tabs;
  final int pageId;

  SpecialtiesHeaderTabsAppBarDelegate({
    required this.expandedHeight,
    required this.tabController,
    required this.tabs,
    required this.pageId,
  });

  @override
  Widget build(BuildContext context, shrinkOffset, bool overlapsContent) {
    final size = 60;
    final top = expandedHeight - shrinkOffset - size / 4;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        buildBackground(shrinkOffset),
        Positioned.fill(
          child: buildAppBar(shrinkOffset), // AppBar on top of the background
        ),
        Positioned(
          top: top,
          left: 0.0,
          right: 0.0,
          child: buildFloatingTabBar(shrinkOffset),
        )
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 30;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;
  double walletOpacity(double shrinkOffset) =>
      1 - shrinkOffset / (expandedHeight - 150);

  Widget buildAppBar(double shrinkOffset) {
    double opacity = appear(shrinkOffset).clamp(0.0, 1.0);

    return MaterialTabsHeader();
  }

  Widget buildBackground(double shrinkOffset) => Container(
        height: expandedHeight * 1.5,
        color: Colors.brown,
      );

  Widget buildFloatingTabBar(double shrinkOffset) => Opacity(
        opacity: disappear(shrinkOffset),
        child: Consumer<CategoryViewController>(
            builder: (context, categoryViewController, child) {
          return MaterialTabsContainer(
            categoryPageId: categoryViewController.selectedListIndex,
          );
        }),
      );
}

class TabsSection extends StatelessWidget {
  const TabsSection({
    super.key,
    required TabController tabController,
    required List<Widget> tabs,
  })  : _tabController = tabController,
        _tabs = tabs;

  final TabController _tabController;
  final List<Widget> _tabs;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelPadding: EdgeInsets.symmetric(horizontal: 2.0),
      indicator: BoxDecoration(),
      physics: AlwaysScrollableScrollPhysics(),
      indicatorColor:
          //isSpecialtiesLoaded
          //   ?
          //AppColors.secondary
          // :
          Colors.transparent,
      controller: _tabController,
      tabs: _tabs,
      labelColor: AppColors.fontColor,
      unselectedLabelColor: Colors.grey,
    );
  }
}
