import 'package:flutter/material.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class ServiceTipSection extends StatelessWidget {
  const ServiceTipSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutViewController>(
        builder: (context, _controller, child) {
      final List items = _controller.tipOptions;
      return Container(
        width: double.maxFinite,
        height: 60.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = _controller.selectedTipIndex == index;

              return GestureDetector(
                onTap: () => _controller.selectTip(index),
                child: Container(
                  width: 70.0,
                  height: 25.0, // Set a fixed width for each item
                  margin: const EdgeInsets.only(right: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        item['image']!, // Image path from item list
                        width: 20.0,
                        height: 20.0,
                      ),
                      SizedBox(
                        width: Dimensions.width10 / 3,
                      ),
                      Text(
                        item['text']!, // Text from item list
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
