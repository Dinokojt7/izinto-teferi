import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../controllers/recommended_specialty_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/skeletons.dart';
import '../../../widgets/texts/integers_and_doubles.dart';
import '../../../widgets/texts/small_text.dart';

class HeaderDetails extends StatelessWidget {
  const HeaderDetails({
    super.key,
    required String name,
    required String street,
    required String address,
    required String area,
  })  : _name = name,
        _street = street,
        _address = address,
        _area = area;

  final String _name;
  final String _street;
  final String _address;
  final String _area;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendedSpecialtyController>(
        builder: (recommendedSpecialties) {
      return Column(
        children: [
          Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: IntegerText(
                      text: _name,
                      color: const Color(0Xff353839),
                      fontWeight: FontWeight.w600,
                      size: Dimensions.font16,
                      height: 1.4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Wrap(
                      children: [
                        recommendedSpecialties.isLoaded
                            ? IntegerText(
                                text: _street,
                                overFlow: TextOverflow.fade,
                                color: AppColors.titleColor.withOpacity(0.7),
                                height: 1.5,
                                size: Dimensions.font16 / 1.3,
                              )
                            : StreetTextSkeleton(),
                        SizedBox(
                          width: Dimensions.width10 / 2,
                        ),
                        IntegerText(
                          text: '.',
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          height: 0.7,
                        ),
                        SizedBox(
                          width: Dimensions.width10 / 2,
                        ),
                        recommendedSpecialties.isLoaded
                            ? IntegerText(
                                text: _address,
                                maxLines: 1,
                                color: AppColors.titleColor.withOpacity(0.7),
                                height: 1.5,
                                size: Dimensions.font16 / 1.2,
                                overFlow: TextOverflow.ellipsis,
                              )
                            : AddressTextSkeleton()
                      ],
                    ),
                  )
                ],
              ),
            ],
          )
        ],
      );
    });
  }
}
