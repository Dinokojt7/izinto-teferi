import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/top_nortch.dart';
import 'package:izinto/widgets/texts/small_text.dart';

class CarWashBottomSheet extends StatelessWidget {
  final String headerText;
  final String? description;
  final String action;
  final bool isMiniaturized;
  final VoidCallback onTap;
  final bool isLoading;
  final Widget? customContent;

  const CarWashBottomSheet({
    Key? key,
    required this.headerText,
    required this.action,
    required this.onTap,
    this.description,
    required this.isMiniaturized,
    this.isLoading = false,
    this.customContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMiniaturized
          ? MediaQuery.of(context).size.height / 2.2
          : MediaQuery.of(context).size.height / 3.4,
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width30, vertical: Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TopNotch(
            color: Colors.black.withOpacity(0.1),
          ),
          SizedBox(height: Dimensions.height20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeadingStyleText(
                text: headerText,
                weight: FontWeight.w600,
                size: Dimensions.font26 / 1.2,
              ),
            ],
          ),

          SizedBox(height: Dimensions.height10),
          Divider(
            indent: 8,
            endIndent: 8,
            color: Colors.black26,
            height: 20,
          ),
          SizedBox(height: Dimensions.height10),

          // Custom content or description
          if (customContent != null)
            Expanded(child: customContent!)
          else if (description != null)
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  description!,
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.1,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          SizedBox(height: Dimensions.height20),

          // Action Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: Container(
                  height: Dimensions.bottomHeightBar / 2.2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: Dimensions.width15),

              // Action Button
              Expanded(
                child: Container(
                  height: Dimensions.bottomHeightBar / 2.2,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: TextButton(
                    onPressed: isLoading ? null : onTap,
                    child: isLoading
                        ? SizedBox(
                            width: Dimensions.height20,
                            height: Dimensions.height20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            action,
                            style: TextStyle(
                              fontSize: Dimensions.font16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
