import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/specification_column.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/dimensions.dart';
import '../../../../utilities/colors.dart';
import '../controller/car_wash_controller.dart';

class WashSpecSection extends StatefulWidget {
  const WashSpecSection({Key? key}) : super(key: key);

  @override
  State<WashSpecSection> createState() => _WashSpecSectionState();
}

class _WashSpecSectionState extends State<WashSpecSection> {
  int carouselIndex = 0;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarWashController>(
      builder: (_controller) {
        final _selectedWash = _controller.washTypeIndex;
        final List items = _controller.washTypes[_selectedWash]['included'];

        // Chunk the list into groups of 3
        final chunkedItems = List.generate(
          (items.length / 3).ceil(),
          (index) => items.skip(index * 3).take(3).toList(),
        );

        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: chunkedItems.length,
              itemBuilder: (context, sliderIndex, realIndex) {
                final slideItems = chunkedItems[sliderIndex];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: slideItems.map((item) {
                    return Container(
                      width: Dimensions.height20 * 5,
                      margin: const EdgeInsets.only(right: 10.0),
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15 * 1.5),
                      ),
                      child: Hero(
                        tag: item['text'],
                        transitionOnUserGestures: true,
                        child: SpecificationColumn(
                          text: item['text'],
                          image: item['image'],
                          backgroundColor: item['color'],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              options: CarouselOptions(
                height: Dimensions.height20 * 6,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    carouselIndex = index;
                  });
                },
              ),
            ),
            // Dots indicator

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                chunkedItems.length,
                (index) => Container(
                  width: 8.0,
                  height: Dimensions.height10,
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: carouselIndex == index
                        ? Colors.brown.shade200
                        : LiveColors.accent.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
