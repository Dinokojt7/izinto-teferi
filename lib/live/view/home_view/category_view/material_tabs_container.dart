import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/widgets/buttons/highlight_button.dart';
import 'package:provider/provider.dart';

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
    // Get.find<SneakersBlanketsController>().sneakersAndBlanketsList,
    Get.find<PopularSpecialtyController>().popularSpecialtyList,
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  void _initializeTabController() {
    materialTabs = mainCategoriesList[widget.categoryPageId];
    final tabLength = materialTabs.isEmpty ? 1 : materialTabs.length;
    _tabController = TabController(length: tabLength, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final categoryViewController =
              Provider.of<CategoryViewController>(context, listen: false);

          if (_tabController.index < materialTabs.length) {
            categoryViewController.updateTabsControllerIndex(
                materialTabs[_tabController.index].name, _tabController.index);

            // Scroll to the active tab
            _scrollToIndex(_tabController.index);
          }
        });
      }
    });
  }

  void _scrollToIndex(int index) {
    if (!mounted) return;

    // Adjust index: we're keeping item 0, removing item 1
    // So displayed indices: [0, 2, 3, 4...]
    // If index is 0, it stays at position 0
    // If index is 2+, it moves to position (index - 1)
    final adjustedIndex = index == 0 ? 0 : index - 1;

    // Calculate the position to scroll to
    final double itemWidth = 100; // Approximate width of each tab
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scrollPosition =
        (itemWidth * adjustedIndex) - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(MaterialTabsContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryPageId != widget.categoryPageId) {
      _tabController.dispose();
      _initializeTabController();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _categoriesHeaderTabs = [];

    // Handle empty materialTabs case
    if (materialTabs.isEmpty) {
      _categoriesHeaderTabs.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: HighlightButton(
            text: "No Items",
            weight: FontWeight.w600,
            isViewing: true,
          ),
        ),
      );
    } else {
      for (var i = 0; i < materialTabs.length; i++) {
        // Skip item 1 (index 1)
        if (i == 1) continue;

        _categoriesHeaderTabs.add(
          Consumer<CategoryViewController>(
            builder: (context, categoryViewController, child) {
              final specialtyViewed = categoryViewController.specialtyName;
              final isSelected = materialTabs[i].name == specialtyViewed;

              // Auto-scroll when the selected tab changes from outside
              if (isSelected && categoryViewController.tabsIndex == i) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToIndex(i);
                });
              }

              return GestureDetector(
                onTap: () {
                  _tabController.animateTo(i);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: HighlightButton(
                    text: materialTabs[i].name,
                    weight: FontWeight.w600,
                    isViewing: isSelected,
                  ),
                ),
              );
            },
          ),
        );
      }
    }

    return Consumer<CategoryViewController>(
      builder: (context, categoryViewController, child) {
        // Add safety checks before animating
        final isValidIndex = categoryViewController.tabsIndex >= 0 &&
            categoryViewController.tabsIndex < _tabController.length;

        final shouldAnimate =
            _tabController.index != categoryViewController.tabsIndex &&
                isValidIndex;

        if (shouldAnimate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _tabController.animateTo(categoryViewController.tabsIndex);
              _scrollToIndex(categoryViewController.tabsIndex);
            }
          });
        }

        return Material(
          elevation: 1.5,
          shadowColor: Colors.black54,
          color: Colors.white,
          child: Container(
            height: 54,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              // No need to subtract 1 from length since we're skipping item 1 in the loop
              itemCount: _categoriesHeaderTabs.length,
              itemBuilder: (context, index) => _categoriesHeaderTabs[index],
            ),
          ),
        );
      },
    );
  }
}
