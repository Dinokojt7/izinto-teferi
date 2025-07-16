import 'package:flutter/material.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class ListTileLabel extends StatelessWidget {
  final String imagePath;
  final String description;
  final int index;
  const ListTileLabel(
      {Key? key,
      required this.imagePath,
      required this.description,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainAddressViewController>(
        builder: (context, addressController, child) {
      return GestureDetector(
        onTap: () {
          addressController.setAddressLabel(description, false);
        },
        child: Padding(
          padding: EdgeInsets.only(
              left: 24.0,
              top: index == 0 ? Dimensions.height45 / 2 : Dimensions.height20,
              right: 24.0,
              bottom:
                  index == 2 ? Dimensions.height45 / 2 : Dimensions.height20),
          child: Container(
            //color: Colors.red,
            height: Dimensions.height30 * 1.2,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        imagePath!, // Image path from item list
                        width: 20.0,
                        height: 20.0,
                      ),
                      SizedBox(width: Dimensions.width10 * 1.2), // Your icon
                      // Space between icon and text
                      Expanded(
                        child: HeadingStyleText(
                          text: description,
                          size: Dimensions.font20 / 1.3,
                          family: 'Poppins',
                          weight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                description == addressController.label
                    ? Icon(
                        Icons.check,
                        size: Dimensions.iconSize26,
                        color: Colors.black,
                      )
                    : Container()
              ],
            ),
          ),
        ),
      );
    });
    ;
  }
}
