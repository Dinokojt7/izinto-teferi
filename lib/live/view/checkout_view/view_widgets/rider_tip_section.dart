import 'package:flutter/material.dart';
import 'package:izinto/live/view/checkout_view/controller/riderTip_controller.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class RiderTipSection extends StatelessWidget {
  const RiderTipSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RiderTipController>(builder: (context, _controller, child) {
      final List items = _controller.tipOptions;
      return Container(
        width: double.maxFinite,
        height: 50.0, // Set a fixed height for the scrollable list
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Horizontal scrolling
            itemCount: items.length, // Number of items in the list
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 70.0,
                height: 30.0, // Set a fixed width for each item
                margin: const EdgeInsets.only(right: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radius15 * 1.5),
                  // boxShadow: 1 == 1
                  //     ? [
                  //         BoxShadow(
                  //           color: Colors.grey.withOpacity(0.3),
                  //           spreadRadius: 2,
                  //           blurRadius: 5,
                  //           offset: Offset(0, 3), // changes position of shadow
                  //         ),
                  //       ]
                  //     : null,
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
              );
            },
          ),
        ),
      );
    });
  }
}
