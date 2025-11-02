import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../models/new_specialty_model.dart';
import '../../../../models/popular_specialty_model.dart';
import '../../../../models/recommended_specialty_model.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/texts/expandable_text.dart';
import '../../../../widgets/texts/small_text.dart';
import '../../../widgets/buttons/cart_action_button.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/icons/back_arrow.dart';
import '../../../widgets/text_widgets/introduction_text.dart';

class ViewSpecialtyInfo extends StatelessWidget {
  final int index;
  final List homeItemList;
  const ViewSpecialtyInfo(
      {Key? key, required this.index, required this.homeItemList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var item = homeItemList[index];

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.98),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 50,
            title: Padding(
              padding: EdgeInsets.only(right: Dimensions.width10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackArrow(
                    iconColor: Colors.black,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Icon(
                    MdiIcons.heartOutline,
                    color: Colors.black12.withOpacity(0.8),
                    size: 26,
                  )
                ],
              ),
            ),
            pinned: true,
            backgroundColor: Colors.white.withOpacity(0.1),
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                homeItemList[index].img,
                width: double.maxFinite,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: Dimensions.width20,
                right: Dimensions.width20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntroductionText(
                            text: homeItemList[index].name,
                          ),
                          SmallText(
                              height: 1.5,
                              color: Colors.black,
                              size: Dimensions.font16 / 1.1,
                              text: homeItemList[index].type)
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.height30,
                  ),
                  GenericHeaderRow(
                    headingChild:
                        IntroductionText(text: 'R${_getPrice(item)},00*'),
                    actionButtonChild: CartActionButton(
                      isActive: true,
                      description: 'Add to basket',
                      onTap: () {},
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.height10 + Dimensions.height15,
                  ),
                  Row(
                    children: [
                      IntroductionText(
                        text: 'Introduction',
                        textSize: Dimensions.font20,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.height10 / 1.4,
                  ),
                  Container(
                    child:
                        ExpandableText(text: homeItemList[index].introduction),
                  ),
                  SizedBox(
                    height: Dimensions.height20,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      //bottomNavigationBar: GenericBottomAppBar(),
    );
  }

  int _getPrice(dynamic item) {
    if (item is NewSpecialtyModel) return item.firstPrice;
    if (item is SpecialtyModel) return item.price ?? 0;
    if (item is Specialties) return item.price ?? 0;
    return 0;
  }
}
