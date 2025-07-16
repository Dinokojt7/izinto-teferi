import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/home_view/category_view/service_widget.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/cta_button.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/page_view_items.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/specialty_item_view.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/widgets/buttons/cart_action_button.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:izinto/live/widgets/text_widgets/small_black_bold.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../controllers/laundry_specialty_controller.dart';
import '../../../../controllers/recommended_specialty_controller.dart';
import '../../../../models/popular_specialty_model.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/text_widgets/description_text.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../../../widgets/text_widgets/introduction_text.dart';
import '../../../widgets/top_nortch.dart';
import 'category_view_heading_section.dart';
import 'controller/category_view_controller.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({Key? key}) : super(key: key);

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  dynamic specialty = SpecialtyModel();
  final List homeList =
      Get.find<LaundrySpecialtyController>().laundrySpecialtyList;

  @override
  void initState() {
    super.initState();

    Get.find<RecommendedSpecialtyController>()
        .initSpecialty(specialty, Get.find<CartController>());
  }

  @override
  void dispose() {
    specialty;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewController>(
        builder: (context, _homeViewController, child) {
      return Consumer<CategoryViewController>(
          builder: (context, categoryViewController, child) {
        final pageId = categoryViewController.selectedListIndex;
        final serviceViewed = categoryViewController.specialtyName;
        final List<Widget> laundrySlivers = [
          SliverToBoxAdapter(
            child: Column(
              children: [
                buildHeading(serviceViewed),
              ],
            ),
          ),

          // Conditionally show SliverGrid or an alternative

          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20.0,
              crossAxisSpacing: Dimensions.width15,
              childAspectRatio: 0.5,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ServiceWidget(
                index: index,
                homeItemList: homeList,
              ),
              childCount: homeList.length,
            ),
          ),
        ];
        final List<Widget> popularServicesSlivers = [
          SliverToBoxAdapter(
              child: SpecialityItemView(
            serviceViewed: serviceViewed,
          )
              // PageViewItems(
              //   serviceViewed: serviceViewed,
              // ),
              ),
        ];
        var viewedCategory = serviceViewed == 'Laundry'
            ? laundrySlivers
            : popularServicesSlivers;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
          ),
          body: Stack(
            children: [
              Padding(
                padding: serviceViewed == 'Laundry'
                    ? EdgeInsets.only(
                        left: Dimensions.width15,
                        right: Dimensions.width15,
                        top: Dimensions.height45 * 2.9)
                    : EdgeInsets.only(top: Dimensions.height45 * 2.6),
                child: CustomScrollView(
                  slivers: viewedCategory,
                ),
              ),
              CategoryViewHeaderSection(
                specialties: homeList,
                pageId: pageId,
              ),
            ],
          ),
          //  bottomNavigationBar: GenericBottomAppBar(),
        );
      });
    });
  }

  Widget notch() => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          width: Dimensions.width30 * 1.4,
          height: Dimensions.height10 / 3.5,
          color: Colors.black87,
        ),
      );

  Widget buildHeading(String viewedService) => Padding(
        padding: EdgeInsets.only(
            top: 10.0, left: Dimensions.width10, bottom: Dimensions.height20),
        child: Row(
          children: [
            GenericHeaderRow(
              headingChild: HeadingStyleText(
                text: viewedService,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
