import 'package:flutter/material.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/specialty_item_view.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../utilities/colors.dart';
import '../../../../widgets/text_widgets/description_text.dart';
import '../../controller/home_view_controller.dart';

class ServiceDetailDisplay extends StatelessWidget {
  const ServiceDetailDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewController>(builder: (context, _controller, child) {
      final List items = _controller.carWashDetails;
      return Container(
        width: double.maxFinite,
        height: Dimensions.bottomHeightBar * 1.5,
        child: ListView.builder(
            scrollDirection: Axis.horizontal, // Horizontal scrolling
            itemCount: items.length, // Number of items in the list
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                margin: EdgeInsets.only(left: Dimensions.width20 / 1.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Dimensions.screenWidth / 1.6,
                      height: Dimensions.bottomHeightBar,
                      padding: EdgeInsets.only(left: Dimensions.width30),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15 * 1.5),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            item['image'],
                          ),
                        ),
                        color: LiveColors.accent.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Row(
                      children: [
                        SecondaryBoldText(text: item['heading']),
                      ],
                    ),
                    DescriptionText(
                      text: item['description'],
                    ),
                  ],
                ),
              );
            }),
      );
    });
  }
}
