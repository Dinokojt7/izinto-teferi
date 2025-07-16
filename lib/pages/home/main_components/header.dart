import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/recommended_specialty_controller.dart';
import '../../../models/user.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/display_tokens.dart';
import '../../../widgets/miscellaneous/app_icon.dart';
import '../../../widgets/skeletons.dart';
import '../../../widgets/texts/big_text.dart';
import '../../cart/re_cart.dart';
import '../../options/profile_settings.dart';
import '../../../live/wrapper.dart';
import 'header_details.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
    required this.user,
    required String name,
    required String street,
    required String address,
    required String area,
    required this.showDialog,
  })  : _name = name,
        _street = street,
        _address = address,
        _area = area;

  final UserModel? user;
  final String _name;
  final String _street;
  final String _address;
  final String _area;
  final ValueNotifier<bool> showDialog;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendedSpecialtyController>(
        builder: (recommendedSpecialties) {
      return GetBuilder<CartController>(builder: (_cartController) {
        return Padding(
          padding: const EdgeInsets.only(
              right: 10.0, left: 10.0, top: 6.9, bottom: 3.0),
          child: Row(
            children: [
              Container(
                width: Dimensions.screenWidth / 1.4,
                margin: EdgeInsets.symmetric(
                  horizontal: Dimensions.screenWidth / 70,
                ),
                padding: EdgeInsets.only(
                    top: Dimensions.height10 / 5,
                    bottom: Dimensions.height10 / 5,
                    left: Dimensions.height10 / 9,
                    right: Dimensions.height10 / 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  //  border: Border.all(width: 3.5, color: Colors.white),
                  borderRadius: BorderRadius.circular(Dimensions.radius30 * 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 1,
                      offset: Offset(1, 2),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 1,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10, vertical: 6.0),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Wrap(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (widget.user != null) {
                                Get.to(
                                    () => ProfileSettings(
                                          isPhoneAuth: false,
                                        ),
                                    transition: Transition.fade,
                                    duration: Duration(seconds: 1));
                              }
                              widget.showDialog.value =
                                  !widget.showDialog.value;
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.height10 * 5),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.black12,
                                    ),
                                  ),
                                  child: recommendedSpecialties.isLoaded
                                      ? AppIcon(
                                          icon: (MdiIcons.tuneVariant),
                                          backgroundColor: Colors.transparent,
                                          iconSize: Dimensions.height20,
                                          size: Dimensions.height10 / 2 +
                                              Dimensions.height30,
                                          iconColor: Colors.black87)
                                      : Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: TuneIconSkeleton(),
                                        )),
                            ),
                          ),
                          SizedBox(
                            width: Dimensions.width10,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (widget.user != null) {
                                Get.to(
                                    () => ProfileSettings(
                                          isPhoneAuth: false,
                                        ),
                                    transition: Transition.fade,
                                    duration: Duration(seconds: 1));
                              }
                              widget.showDialog.value =
                                  !widget.showDialog.value;
                            },
                            child: HeaderDetails(
                                name: widget._name,
                                street: widget._street,
                                address: widget._address,
                                area: widget._area),
                          ),
                          SizedBox(
                            width: Dimensions.width20,
                          ),
                        ],
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     Get.to(() => ReCart(),
                      //         duration: Duration(milliseconds: 500));
                      //   },
                      //   child: Stack(
                      //     children: [
                      //       Icon(
                      //         MdiIcons.pail,
                      //         color: AppColors.secondary,
                      //         size: Dimensions.iconSize24 * 1.9,
                      //       ),
                      //       Positioned(
                      //         right: 0,
                      //         top: 0,
                      //         child: _cartController.getItems.length > 0
                      //             ? Container(
                      //                 width: 20,
                      //                 height: 20,
                      //                 decoration: BoxDecoration(
                      //                   border: Border.all(
                      //                     width: 1.5,
                      //                     color: Colors.white,
                      //                   ),
                      //                   borderRadius: BorderRadius.circular(40 / 2),
                      //                   color: Color(0xff9A9483).withOpacity(0.8),
                      //                 ),
                      //                 child: Center(
                      //                     child: Text(
                      //                   '${_cartController.totalItems.toString()}',
                      //                   style: TextStyle(
                      //                       fontSize: Dimensions.font16 / 1.3,
                      //                       fontFamily: 'Poppins',
                      //                       color: Colors.white,
                      //                       fontWeight: FontWeight.w600),
                      //                 )),
                      //               )
                      //             : Container(),
                      //       )
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
    });
  }
}
