import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/carpet_care_specialty_controller.dart';
import 'package:izinto/controllers/gas_refill_specialty_controller.dart';
import 'package:izinto/controllers/pet_care_specialty_controller.dart';
import 'package:izinto/live/view/home_view/category_view/service_widget.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/specialty_item_view.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../controllers/laundry_specialty_controller.dart';
import '../../../../controllers/recommended_specialty_controller.dart';
import '../../../../models/popular_specialty_model.dart';
import '../../../../utils/dimensions.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/text_widgets/description_text.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../view_specialty_info/safe_pet_care_widget.dart';
import 'category_view_heading_section.dart';
import 'controller/category_view_controller.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({Key? key}) : super(key: key);

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  dynamic specialty = SpecialtyModel();

  @override
  void initState() {
    super.initState();
    Get.find<RecommendedSpecialtyController>()
        .initSpecialty(specialty, Get.find<CartController>());
  }

  @override
  void dispose() {
    specialty = null; // Clear the reference
    super.dispose();
  }

  List<dynamic> _getRelevantList(String serviceViewed) {
    switch (serviceViewed) {
      case 'Laundry':
        return Get.find<LaundrySpecialtyController>().laundrySpecialtyList;
      case 'Gas Refill':
        return Get.find<GasRefillSpecialtyController>().gasRefillSpecialtyList;
      case 'Carpet Care':
        return Get.find<CarpetCareSpecialtyController>()
            .carpetCareSpecialtyList;
      case 'Pet Care':
        return Get.find<PetCareSpecialtyController>().getSafePetCareList();
      default:
        return [];
    }
  }

  List<Widget> _buildServiceSlivers(String serviceViewed) {
    final relevantList = _getRelevantList(serviceViewed);

    // Show empty state if list is empty
    if (relevantList.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: Dimensions.height45 * 2),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: Dimensions.height15),
                  HeadingStyleText(
                    text: 'No Services Available',
                    size: 18,
                    weight: FontWeight.w500,
                  ),
                  SizedBox(height: Dimensions.height10),
                  DescriptionText(
                    text: 'Services for $serviceViewed will be available soon.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: Column(
          children: [
            _buildHeading(serviceViewed),
          ],
        ),
      ),
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
            homeItemList: relevantList,
          ),
          childCount: relevantList.length,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafePetCareWidget(
      builder: (petCareController) {
        return Consumer<HomeViewController>(
          builder: (context, _homeViewController, child) {
            return Consumer<CategoryViewController>(
              builder: (context, categoryViewController, child) {
                final pageId = categoryViewController.selectedListIndex;
                final serviceViewed = categoryViewController.specialtyName;

                final gridServices = [
                  'Laundry',
                  'Gas Refill',
                  'Carpet Care',
                  'Pet Care'
                ];
                final shouldShowGrid = gridServices.contains(serviceViewed);

                final List<Widget> serviceSlivers = shouldShowGrid
                    ? _buildServiceSlivers(serviceViewed)
                    : [
                        SliverToBoxAdapter(
                          child: SpecialityItemView(
                            serviceViewed: serviceViewed,
                          ),
                        ),
                      ];

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
                        padding: shouldShowGrid
                            ? EdgeInsets.only(
                                left: Dimensions.width15,
                                right: Dimensions.width15,
                                top: Dimensions.height45 * 2.9)
                            : EdgeInsets.only(top: Dimensions.height45 * 2.6),
                        child: CustomScrollView(
                          slivers: serviceSlivers,
                        ),
                      ),
                      CategoryViewHeaderSection(
                        specialties: _getRelevantList(serviceViewed),
                        pageId: pageId,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeading(String viewedService) => Padding(
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
