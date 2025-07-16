import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/widgets/miscellaneous/App_column.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../controllers/cart_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/skeletons.dart';
import '../../../widgets/texts/integers_and_doubles.dart';
import '../../cart/re_cart.dart';
import '../specialty_page_body.dart';

class MaterialTabsSection extends StatelessWidget {
  const MaterialTabsSection({
    super.key,
    required bool isSpecialtiesLoaded,
    required TabController tabController,
    required List<Widget> tabs,
  })  : _tabController = tabController,
        _tabs = tabs,
        isSpecialtiesLoaded = isSpecialtiesLoaded;

  final TabController _tabController;
  final List<Widget> _tabs;
  final bool? isSpecialtiesLoaded;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (_cartController) {
      return Material(
        shadowColor: Colors.black45,
        elevation: 1.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.transparent,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: Dimensions.screenHeight / 60,
              ),
              //Currently active section name
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IntegerText(
                      size: Dimensions.height18 + Dimensions.height20 * 1.7,
                      text: _tabController.index == 0
                          ? 'Laundry'
                          : _tabController.index == 1
                              ? 'Car Wash'
                              : 'Subscriptions',
                      color: const Color(0Xff353839),
                      fontWeight: FontWeight.w600,
                    ),
                    _tabController.index == 0 ? AppColumn() : Container()
                  ],
                ),
              ),
              SizedBox(
                height: Dimensions.screenHeight / 60,
              ),
              //Main tabs section
              Padding(
                padding: EdgeInsets.only(left: Dimensions.width20 / 1.5),
                child: TabBar(
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  isScrollable: true,
                  indicatorWeight: Dimensions.width10 / 3,
                  indicatorSize: TabBarIndicatorSize.label,
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
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
