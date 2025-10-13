import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/controllers/car_specialty_controller.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/add_car_button.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/add_vehicle.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/car_wash_heading.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/included_vehicles.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/section_dividers.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/spec_icon.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/specialty_bottom_checkout_nav.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/specification_column.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/toggle_wash_button.dart';
import 'package:izinto/widgets/miscellaneous/app_icon.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../controllers/recommended_specialty_controller.dart';
import '../../../../models/popular_specialty_model.dart';
import '../../../../pages/car_specialty/car_specialty_detail.dart';
import '../../../../scratch.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/texts/expandable_text.dart';
import '../../../../widgets/texts/small_text.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/buttons/cart_action_button.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/icons/back_arrow.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../../../widgets/text_widgets/introduction_text.dart';
import '../../address_view/controller/address_dropdown_controller.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs; // Add this prefix

import '../../checkout_view/view_widgets/generic_white_container.dart';
import '../../profile_view/controller/profile_view_controller.dart';

class CarWashView extends StatefulWidget {
  const CarWashView({Key? key}) : super(key: key);

  @override
  State<CarWashView> createState() => _CarWashViewState();
}

class _CarWashViewState extends State<CarWashView> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  dynamic specialty = SpecialtyModel();

  @override
  void initState() {
    super.initState();

    Get.find<RecommendedSpecialtyController>()
        .initSpecialty(specialty, Get.find<CartController>());
  }

  @override
  void dispose() {
    specialty;
    super.dispose();
  }

  // CORRECT: Use CarouselSliderController (not CarouselController)
  cs.CarouselSliderController carouselController =
      cs.CarouselSliderController();
  cs.CarouselSliderController washTypeController =
      cs.CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final addressViewController =
        Provider.of<MainAddressViewController>(context, listen: false);

    ///Here's a list of addresses from the controller
    final _profileController =
        Provider.of<ProfileViewController>(context, listen: false);
    final List<dynamic> _addresses = _profileController.savedAddresses;

    ///Here's the selection of currently active address///
    var selectedAddresses =
        _addresses.where((address) => address['selected'] == true).toList();

    var street = '';
    var suburb = '';
    // Iterate over the filtered addresses and use their values
    for (var address in selectedAddresses) {
      street = address['street'];
      suburb = address['suburb'];
    }
    return Consumer<CarWashController>(
        builder: (context, _carWashController, child) {
      final washTypes = _carWashController.washTypes;
      final selectedVehicleIndex = _carWashController.selectVehicleIndex;
      final selectedWashTypeIndex = _carWashController.washTypeIndex;
      final _selectedPrice = selectedVehicleIndex == 0
          ? _carWashController.calculateCharges().toString()
          : _carWashController.totalCharges.toString();
      final carTypeList = _carWashController.carWashSpecialties;
      final includedVehicles = _carWashController.includedVehicles;
      final quantity = includedVehicles.length > 0
          ? includedVehicles[0]['selectionQuantity']
          : 0;
      return GetBuilder<CartController>(builder: (_cartController) {
        return Scaffold(
          backgroundColor: Colors.white.withOpacity(0.99),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: Dimensions.height10 * 1.5,
                  left: Dimensions.width20,
                  right: Dimensions.width20,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackArrow(
                          iconColor: Colors.black,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Row(
                          children: [
                            Icon(
                              size: Dimensions.iconSize24 / 1.1,
                              Icons.location_on_rounded,
                              color: LiveColors.accent.withOpacity(0.7),
                            ),
                            SizedBox(
                              width: Dimensions.width20 / 4,
                            ),
                            HeadingStyleText(
                              text: street,
                              size: Dimensions.font20 / 1.5,
                              family: 'Poppins',
                              weight: FontWeight.w600,
                            ),
                            SizedBox(
                              width: Dimensions.width10,
                            ),
                            HeadingStyleText(
                                text: suburb,
                                size: Dimensions.font20 / 1.5,
                                family: 'Poppins',
                                weight: FontWeight.w300,
                                color: Colors.black),
                          ],
                        ),
                        Icon(
                          MdiIcons.clockEditOutline,
                          color: Colors.black12.withOpacity(0.8),
                          size: 26,
                        ),
                      ],
                    ),
                    SectionDivider(),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    CarWashHeading(text: 'Select Vehicle'),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Container(
                      width: Dimensions.screenWidth,
                      child: Stack(
                        children: [
                          Container(
                            width: Dimensions.screenWidth,
                            height: Dimensions.screenHeight / 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radius15 * 1.3),
                              color: LiveColors.accent.withOpacity(0.2),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    'assets/image/car-wash-background.png'),
                              ),
                            ),
                            child: cs.CarouselSlider(
                                carouselController: carouselController,
                                items: carTypeList
                                    .map(
                                      (e) => displayVehicle(
                                          e.img, e.name, e.introduction),
                                    )
                                    .toList(),
                                options: cs.CarouselOptions(
                                  viewportFraction: 0.8,
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) {
                                    _carWashController.selectVehicleType(index);
                                  },
                                )),
                          ),
                          Positioned(
                            top: 0,
                            bottom: 0,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: Dimensions.width30 * 1.1,
                              ),
                              child: Center(
                                child: Container(
                                  height: Dimensions.height30,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      selectVehicleController(() {
                                        carouselController.previousPage(
                                            duration: Duration(seconds: 1),
                                            curve: Curves.elasticIn);
                                      }, true),
                                      SizedBox(width: Dimensions.width10 / 2),
                                      Transform.rotate(
                                        angle: 3.14159,
                                        child: selectVehicleController(() {
                                          carouselController.nextPage(
                                              duration: Duration(seconds: 1),
                                              curve: Curves.elasticIn);
                                        }, false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    SectionDivider(),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    CarWashHeading(text: 'Select Wash Type'),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ToggleWashButton(
                          icon: Icons.arrow_left,
                          onTap: () {
                            washTypeController.previousPage(
                                duration: Duration(seconds: 1),
                                curve: Curves.easeInToLinear);
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              height: Dimensions.height30,
                              child: cs.CarouselSlider(
                                carouselController: washTypeController,
                                items: washTypes
                                    .map(
                                      (e) => washTypeHeading(
                                        washTypes[selectedWashTypeIndex]
                                            ['washType'],
                                        _selectedPrice,
                                        () async {
                                          await _carWashController
                                              .selectWashType(
                                                  selectedWashTypeIndex);
                                          _carWashController
                                              .showDetails(context);
                                        },
                                      ),
                                    )
                                    .toList(),
                                options: cs.CarouselOptions(
                                  scrollPhysics: FixedExtentScrollPhysics(),
                                  onPageChanged: (index, reason) {
                                    _carWashController.selectWashType(index);
                                  },
                                  enlargeCenterPage: false,
                                  viewportFraction: 1.0,
                                  aspectRatio: 16 / 9,
                                  initialPage: selectedWashTypeIndex,
                                  enableInfiniteScroll: true,
                                  disableCenter: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ToggleWashButton(
                          icon: Icons.arrow_right,
                          onTap: () {
                            washTypeController.nextPage();
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height30 / 2,
                    ),
                    washType(
                      () async {
                        await _carWashController
                            .selectWashType(selectedWashTypeIndex);
                        _carWashController.showDetails(context);
                      },
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    SectionDivider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CarWashHeading(text: 'Add Selection'),
                          AddVehicle(
                            vehicleType: carTypeList[selectedVehicleIndex].name,
                            imageString: carTypeList[selectedVehicleIndex].img,
                            specialtyList:
                                _carWashController.carWashSpecialties,
                            index: _carWashController.selectVehicleIndex,
                            viewContext: context,
                            icon: Icons.add,
                            isValid: false,
                          )
                        ],
                      ),
                    ),
                    ContainedDivider(),
                    MainPageControllers(() {
                      _cartController.addItem(
                        _carWashController.carWashSpecialties[
                            _carWashController.selectVehicleIndex],
                        quantity,
                      );
                    }),
                    SizedBox(
                      height: Dimensions.height30,
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SpecialtyBottomCheckoutNav(),
        );
      });
    });
  }

  Material selectVehicleController(VoidCallback onTap, bool isTopSelector) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        //splashColor: Colors.red,
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.95 : 1.0), // Scale effect

          width: Dimensions.width30 * 1.7,
          height: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
            border: Border.all(color: Colors.white70, width: 1),
            color: _isPressed
                ? Colors.red.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            //color: Colors.black.withOpacity(0.1),
          ),
          child: Center(
            child: Icon(
              isTopSelector
                  ? Icons.keyboard_backspace_outlined
                  : Icons.keyboard_backspace_outlined,
              size: Dimensions.iconSize26 / 1.1,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector selectWashTypeController(
      VoidCallback onTap, bool isTopController) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: isTopController
              ? BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                )
              : BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
          border: Border.all(
              color: LiveColors.accent.withOpacity(0.12), width: 1.0),
          color: LiveColors.accent.withOpacity(0.2),
        ),
        child: Icon(
          isTopController
              ? Icons.arrow_drop_up_rounded
              : Icons.arrow_drop_down_rounded,
          size: Dimensions.height30 * 1.1,
          color: Colors.black.withOpacity(0.2),
        ),
      ),
    );
  }

  Container washTypeHeading(String washType, String price, var onTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          color: Colors.transparent,
          border:
              Border.all(color: LiveColors.accent.withOpacity(0.5), width: 1)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    color: LiveColors.accent.withOpacity(0.2),
                    child: Center(
                      child: SmallText(
                          overFlow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          maxLines: 1,
                          color: Colors.black,
                          size: Dimensions.font16 / 1.25,
                          text: washType),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    // padding: EdgeInsets.only(right: Dimensions.width30),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmallText(
                            overFlow: TextOverflow.clip,
                            family: 'Onest',
                            maxLines: 1,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.black,
                            size: Dimensions.font16 / 1.12,
                            text: 'R${price}.00*'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container washType(var onTap) {
    return Container(
      height: Dimensions.height45 * 3,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        //  border: Border.all(color: Colors.black.withOpacity(0.2), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          onTap: onTap,
          child: GenericWhiteContainer(
              isSelected: false,
              bottomPadding: 0.0,
              leftPadding: 0.0,
              rightPadding: 0.0,
              color: LiveColors.accent.withOpacity(0.2),
              child: Column(
                children: [
                  Spacer(
                    flex: 2,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: [
                  //       SpecificationColumn(
                  //         text: 'Full Wash',
                  //         image: 'assets/image/car-wash-subscription.png',
                  //         backgroundColor: Colors.orange.withOpacity(0.2),
                  //       ),
                  //       SpecificationColumn(
                  //         text: 'Vacuuming',
                  //         image: 'assets/image/vacuuming.png',
                  //         backgroundColor: Colors.blueGrey.withOpacity(0.2),
                  //       ),
                  //       SpecificationColumn(
                  //         text: 'Tyre Shine',
                  //         image: 'assets/image/tyre-shine.png',
                  //         backgroundColor: Colors.redAccent.withOpacity(0.2),
                  //       ),
                  //       SpecificationColumn(
                  //         text: 'Body Polish',
                  //         image: 'assets/image/body-polish.png',
                  //         backgroundColor: Colors.green.shade100,
                  //       )
                  //     ],
                  //   ),
                  // ),
                  AnimatedSpecifications(),
                  Spacer(
                    flex: 1,
                  ),
                  Container(
                    width: double.maxFinite,
                    height: Dimensions.height30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(Dimensions.radius15),
                          bottomRight: Radius.circular(Dimensions.radius15),
                        ),
                        color: Colors.black12),
                    child: Center(
                      child: HeadingStyleText(
                        size: Dimensions.font16 / 1.15,
                        color: Colors.white,
                        text: 'Select',
                        family: 'Poppins',
                        weight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  Hero displayVehicle(
      String imageString, String vehicleType, String categories) {
    return Hero(
      tag: vehicleType,
      transitionOnUserGestures: true,
      child: Container(
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SmallText(
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: Colors.white,
                        size: Dimensions.font20 / 1.1,
                        text: vehicleType),
                    SmallText(
                        color: Colors.white,
                        size: Dimensions.font16 / 1.8,
                        fontWeight: FontWeight.w300,
                        text: categories),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: Image(
                height: 200,
                image: AssetImage(
                  imageString,
                ),
                width: double.maxFinite,
                fit: BoxFit.scaleDown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container MainPageControllers(VoidCallback onTap) {
    return Container(
      height: Dimensions.height45 * 1.4,
      width: double.maxFinite,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: Colors.white, width: 3),
                  color: LiveColors.accent.withOpacity(0.3),
                ),
                child: Center(
                  child: HeadingStyleText(
                      text: 'Add to Wash',
                      size: Dimensions.font20 / 1.5,
                      family: 'Poppins',
                      weight: FontWeight.w400,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                border: Border.all(color: Colors.white, width: 3),
                color: LiveColors.accent.withOpacity(0.05),
              ),
              child: Center(
                child: HeadingStyleText(
                    text: 'Clear Selection',
                    size: Dimensions.font20 / 1.5,
                    family: 'Poppins',
                    weight: FontWeight.w400,
                    color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container IncludedVehicles(List<Map<String, dynamic>> vehicles) {
    final _cartController = Get.find<CartController>();
    final _cartList = _cartController.getItems;
    return Container(
      height: Dimensions.height45 * 1.4,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        color: LiveColors.accent.withOpacity(0.05),
        border: Border.all(color: Colors.white, width: 3.0),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 16.0, vertical: Dimensions.height10 / 2),
      child: vehicles.length == 0
          ? Center(
              child: SmallText(
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: Colors.grey.withOpacity(0.5),
                  size: Dimensions.font16 / 1.3,
                  text: 'You have not added any vehicles'),
            )
          // : ListView.builder(
          //     scrollDirection: Axis.horizontal,
          //     shrinkWrap: true,
          //     physics: NeverScrollableScrollPhysics(),
          //     itemCount: vehicles.length,
          //     itemBuilder: (_, index) {
          //       return Hero(
          //         tag:
          //         vehicles[index]['vehicleType'], // Same tag as in displayVehicle
          //         transitionOnUserGestures: true,
          //         child: Image.asset(
          //           vehicles[index]['imageString'],
          //           height: 50, // Miniaturized size
          //           width: 50,
          //           fit: BoxFit.cover,
          //         ),
          //       );
          //     },
          //   )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: vehicles.map((vehicle) {
                    return Stack(
                      children: [
                        Hero(
                          tag: vehicle[
                              'vehicleType'], // Same tag as in displayVehicle
                          transitionOnUserGestures: true,
                          child: Image.asset(
                            vehicle['imageString'],
                            height: 50, // Miniaturized size
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        vehicle['selectionQuantity'] > 0
                            ? Positioned(
                                top: 0.0,
                                right: 0.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade500,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radius15),
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child: HeadingStyleText(
                                      size: Dimensions.font20 / 1.5,
                                      color: Colors.white,
                                      text: vehicle['selectionQuantity']
                                          .toString(),
                                      family: 'Poppins',
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
