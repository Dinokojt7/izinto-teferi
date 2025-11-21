import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/widgets/buttons/blue_text_button.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../edit_address.dart';

class SavedAddressWidget extends StatelessWidget {
  final String streetNumber;
  final String zipCode;
  final String suburb;
  final int index;
  final bool isLastAddress;
  const SavedAddressWidget({
    Key? key,
    required this.streetNumber,
    required this.zipCode,
    required this.suburb,
    required this.index,
    required this.isLastAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Image.asset(
            'assets/image/pin.png',
            width: 22.0,
            height: 22.0,
          ),
        ),
        SizedBox(width: Dimensions.width20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadingStyleText(
                  text: streetNumber,
                  size: Dimensions.font20 / 1.3,
                  family: 'Poppins',
                  weight: FontWeight.w600,
                  maxLines: 2,
                  overFlow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                // Replace the Row with Column for better text wrapping
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: Dimensions.width10,
                  children: [
                    HeadingStyleText(
                      text: zipCode,
                      size: Dimensions.font20 / 1.3,
                      family: 'Poppins',
                      weight: FontWeight.w300,
                      color: Colors.black,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
                    HeadingStyleText(
                      text: suburb,
                      size: Dimensions.font20 / 1.3,
                      family: 'Poppins',
                      weight: FontWeight.w300,
                      color: Colors.black,
                      maxLines: 2,
                      overFlow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: Dimensions.width20),
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: BlueTextButton(
            text: 'Edit',
            horizontalPadding: Dimensions.width20 * 1.2,
            onTap: () {
              Get.to(
                () => EditAddress(
                  index: index,
                  isLastAddress: isLastAddress,
                ),
                transition: Transition.native,
                duration: const Duration(milliseconds: 500),
              );
            },
          ),
        ),
      ],
    );
  }
}
