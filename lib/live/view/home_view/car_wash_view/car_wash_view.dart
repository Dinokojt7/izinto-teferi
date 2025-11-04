import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/controllers/car_specialty_controller.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/add_car_button.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/add_vehicle.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/animated_specifications.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/car_wash_add_to_cart.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/car_wash_cart_button.dart';
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
import '../../../../controllers/new_cart_controller.dart';
import '../../../../controllers/recommended_specialty_controller.dart';
import '../../../../models/popular_specialty_model.dart';
import '../../../../pages/car_specialty/car_specialty_detail.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/texts/expandable_text.dart';
import '../../../../widgets/texts/small_text.dart';
import '../../../data/wash_types.dart';
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
  final cs.CarouselSliderController carouselController =
      cs.CarouselSliderController();
  final cs.CarouselSliderController washTypeController =
      cs.CarouselSliderController();

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

  @override
  Widget build(BuildContext context) {
    final addressViewController =
        Provider.of<MainAddressViewController>(context, listen: false);
    final _profileController =
        Provider.of<ProfileViewController>(context, listen: false);
    final List<dynamic> _addresses = _profileController.savedAddresses;
    var selectedAddresses =
        _addresses.where((address) => address['selected'] == true).toList();

    var street = '';
    var suburb = '';
    for (var address in selectedAddresses) {
      street = address['street'];
      suburb = address['suburb'];
    }

    return GetBuilder<CarWashController>(
      builder: (carWashController) {
        final washTypes = carWashController.washTypes;
        final selectedVehicleIndex = carWashController.selectVehicleIndex;
        final selectedWashTypeIndex = carWashController.washTypeIndex;
        final price = carWashController.calculateCharges();
        final carTypeList = carWashController.carWashSpecialties;
        final hasCartItems = carWashController.totalCarWashItems > 0;

        return GetBuilder<NewCartController>(
          builder: (cartController) {
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
                        // Header Row
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
                                SizedBox(width: Dimensions.width20 / 4),
                                HeadingStyleText(
                                  text: street,
                                  size: Dimensions.font20 / 1.5,
                                  family: 'Poppins',
                                  weight: FontWeight.w600,
                                ),
                                SizedBox(width: Dimensions.width10),
                                HeadingStyleText(
                                  text: suburb,
                                  size: Dimensions.font20 / 1.5,
                                  family: 'Poppins',
                                  weight: FontWeight.w300,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            Icon(
                              Icons.schedule,
                              color: Colors.black12.withOpacity(0.8),
                              size: 26,
                            ),
                          ],
                        ),

                        SectionDivider(),
                        SizedBox(height: Dimensions.height10),

                        // Vehicle Selection Section
                        CarWashHeading(text: 'Select Vehicle'),
                        SizedBox(height: Dimensions.height10),

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
                                      .map((e) => displayVehicle(
                                          e.img!, e.name!, e.introduction!))
                                      .toList(),
                                  options: cs.CarouselOptions(
                                    viewportFraction: 0.8,
                                    enlargeCenterPage: true,
                                    onPageChanged: (index, reason) {
                                      carWashController
                                          .selectVehicleType(index);
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: Dimensions.width30 * 1.1),
                                  child: Center(
                                    child: Container(
                                      height: Dimensions.height30,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          selectVehicleController(() {
                                            carouselController.previousPage(
                                              duration: Duration(seconds: 1),
                                              curve: Curves.elasticIn,
                                            );
                                          }, true),
                                          SizedBox(
                                              width: Dimensions.width10 / 2),
                                          Transform.rotate(
                                            angle: 3.14159,
                                            child: selectVehicleController(() {
                                              carouselController.nextPage(
                                                duration: Duration(seconds: 1),
                                                curve: Curves.elasticIn,
                                              );
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

                        SectionDivider(),
                        SizedBox(height: Dimensions.height10),

                        // Wash Type Selection Section
                        CarWashHeading(text: 'Select Wash Type'),
                        SizedBox(height: Dimensions.height20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ToggleWashButton(
                              icon: Icons.arrow_left,
                              onTap: () {
                                washTypeController.previousPage(
                                  duration: Duration(seconds: 1),
                                  curve: Curves.easeInToLinear,
                                );
                              },
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Container(
                                  height: Dimensions.height30,
                                  child: cs.CarouselSlider(
                                    carouselController: washTypeController,
                                    items: washTypes
                                        .map((e) => washTypeHeading(
                                              carWashController.washType,
                                              price.toString(),
                                              () async {
                                                await carWashController
                                                    .selectWashType(
                                                        selectedWashTypeIndex);
                                                carWashController
                                                    .showDetails(context);
                                              },
                                            ))
                                        .toList(),
                                    options: cs.CarouselOptions(
                                      scrollPhysics: FixedExtentScrollPhysics(),
                                      onPageChanged: (index, reason) {
                                        carWashController.selectWashType(index);
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
                            ),
                          ],
                        ),

                        SizedBox(height: Dimensions.height30 / 2),

                        // Wash Type Details
                        washType(() async {
                          await carWashController
                              .selectWashType(selectedWashTypeIndex);
                          carWashController.showDetails(context);
                        }),

                        SizedBox(height: Dimensions.height10),
                        SectionDivider(),

                        // Cart Summary Section
                        if (hasCartItems) _buildCartSummary(carWashController),

                        SizedBox(height: Dimensions.height20),

                        // Add to Cart Controls
                        CarWashAddToCart(
                          onAddToCart: () {
                            carWashController.addCarWashToCart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Car wash added to cart!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          onClearSelection: () {
                            carWashController.clearCarWashCart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Cart cleared'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          hasSelection: hasCartItems,
                        ),

                        SizedBox(height: Dimensions.height30),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: SpecialtyBottomCheckoutNav(),
            );
          },
        );
      },
    );
  }

  Widget _buildCartSummary(CarWashController controller) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width15),
      margin: EdgeInsets.only(bottom: Dimensions.height10),
      decoration: BoxDecoration(
        color: LiveColors.standardBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LiveColors.standardBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Car Wash Services in Cart:',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Total: ${controller.totalCarWashItems}',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                  color: LiveColors.standardBlue,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // List car wash items
          Column(
            children: controller.carWashCartItems.map((item) {
              final itemId = item['id'];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.2,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            item['description'],
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.3,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    CarWashCartButton(
                      itemId: itemId,
                      initialQuantity: item['quantity'],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'R${controller.totalCarWashAmount},00',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                  color: LiveColors.standardBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Existing helper methods (keep all your existing methods exactly as they were)
  Material selectVehicleController(VoidCallback onTap, bool isTopSelector) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          width: Dimensions.width30 * 1.7,
          height: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
            border: Border.all(color: Colors.white70, width: 1),
            color: _isPressed
                ? Colors.red.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
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

  Container washTypeHeading(String washType, String price, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        color: Colors.transparent,
        border: Border.all(color: LiveColors.accent.withOpacity(0.5), width: 1),
      ),
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
                        text: washType,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
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
                          text: 'R${price},00*',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container washType(VoidCallback onTap) {
    return Container(
      height: Dimensions.height45 * 3,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
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
                Spacer(flex: 2),
                AnimatedSpecifications(),
                Spacer(flex: 1),
                Container(
                  width: double.maxFinite,
                  height: Dimensions.height30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(Dimensions.radius15),
                      bottomRight: Radius.circular(Dimensions.radius15),
                    ),
                    color: Colors.black12,
                  ),
                  child: Center(
                    child: HeadingStyleText(
                      size: Dimensions.font16 / 1.15,
                      color: Colors.white,
                      text: 'Select',
                      family: 'Poppins',
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                      text: vehicleType,
                    ),
                    SmallText(
                      color: Colors.white,
                      size: Dimensions.font16 / 1.8,
                      fontWeight: FontWeight.w300,
                      text: categories,
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: Image(
                height: 200,
                image: AssetImage(imageString),
                width: double.maxFinite,
                fit: BoxFit.scaleDown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Supporting Widgets
class CarWashHeading extends StatelessWidget {
  final String text;
  const CarWashHeading({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeadingStyleText(
          text: text,
          size: Dimensions.font20,
          family: 'Poppins',
          weight: FontWeight.w600,
        ),
      ],
    );
  }
}

class SectionDivider extends StatelessWidget {
  const SectionDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.black12,
      height: 1,
      thickness: 0.5,
    );
  }
}

class ContainedDivider extends StatelessWidget {
  const ContainedDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.black26,
      height: 1,
      thickness: 1.0,
    );
  }
}

class CarWashCartButton extends StatelessWidget {
  final int itemId;
  final int initialQuantity;

  const CarWashCartButton({
    Key? key,
    required this.itemId,
    required this.initialQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final carWashController = Get.find<CarWashController>();

    return GetBuilder<CarWashController>(
      builder: (controller) {
        final item = controller.carWashCartItems.firstWhere(
          (item) => item['id'] == itemId,
          orElse: () => {'quantity': 0},
        );

        final quantity = item['quantity'] ?? 0;
        final isInCart = quantity > 0;

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: isInCart ? 96 : 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            color: Colors.black,
          ),
          child: isInCart
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity == 1) {
                          // Show remove confirmation
                          _showRemoveDialog(context, itemId, item['name']);
                        } else {
                          carWashController.updateCarWashQuantity(
                              itemId, quantity - 1);
                        }
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        child:
                            Icon(Icons.remove, color: Colors.white, size: 16),
                      ),
                    ),
                    Text(
                      quantity.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        carWashController.updateCarWashQuantity(
                            itemId, quantity + 1);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        child: Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font20,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _showRemoveDialog(BuildContext context, int itemId, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Item'),
        content: Text('Remove $itemName from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Remove item and dismiss dialog
              Get.find<CarWashController>().removeCarWashItem(itemId);
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
