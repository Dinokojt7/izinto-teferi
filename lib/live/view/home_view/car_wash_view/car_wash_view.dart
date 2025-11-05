import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/car_wash_add_to_cart.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/specialty_bottom_checkout_nav.dart';
import 'package:provider/provider.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/icons/back_arrow.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;

import '../../../../widgets/texts/small_text.dart';
import '../controller/home_view_controller.dart';

class CarWashView extends StatefulWidget {
  const CarWashView({Key? key}) : super(key: key);

  @override
  State<CarWashView> createState() => _CarWashViewState();
}

class _CarWashViewState extends State<CarWashView> {
  final cs.CarouselSliderController _carouselController =
      cs.CarouselSliderController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarWashController>(
      builder: (carWashController) {
        final selectedVehicleIndex = carWashController.selectVehicleIndex;
        final selectedWashTypeIndex = carWashController.washTypeIndex;
        final price = carWashController.calculateCharges();
        final carTypeList = carWashController.carWashSpecialties;
        final hasCartItems = carWashController.totalCarWashItems > 0;
        final hasSelection =
            selectedVehicleIndex != -1 && selectedWashTypeIndex != -1;

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Main App Bar
              SliverAppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 60,
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackArrow(
                        iconColor: Colors.black,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      HeadingStyleText(
                        text: 'Car Wash',
                        size: Dimensions.font20,
                        family: 'Poppins',
                        weight: FontWeight.w600,
                      ),
                      Container(
                        width: 40, // Placeholder for balance
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                expandedHeight: Dimensions.screenHeight * 0.4,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildCarImageSection(carWashController),
                ),
              ),

              // Floating Selection Bridge
              SliverToBoxAdapter(
                child: _buildSelectionBridge(carWashController, hasSelection),
              ),

              // Wash Type Selection Section
              SliverToBoxAdapter(
                child: _buildWashTypeSelection(carWashController),
              ),

              // Cart Summary Section
              if (hasCartItems)
                SliverToBoxAdapter(
                  child: _buildCartSummary(carWashController),
                ),

              // Add to Cart Section
              SliverToBoxAdapter(
                child: _buildAddToCartSection(carWashController, hasSelection),
              ),

              // Bottom Spacer
              SliverToBoxAdapter(
                child: SizedBox(height: Dimensions.height30 * 2),
              ),
            ],
          ),
          bottomNavigationBar: SpecialtyBottomCheckoutNav(
            totalAmount: carWashController.totalCarWashAmount,
            onCheckout: () {
              final homeViewController =
                  Provider.of<HomeViewController>(context, listen: false);
              Navigator.of(context).pop(); // Pop car wash view first
              homeViewController.changeIndex(2, false); // Navigate to cart
            },
            isActive: hasCartItems,
          ),
        );
      },
    );
  }

  Widget _buildCarImageSection(CarWashController controller) {
    final carTypeList = controller.carWashSpecialties;
    final selectedIndex = controller.selectVehicleIndex;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            LiveColors.accent.withOpacity(0.3),
            LiveColors.accent.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Car Image Carousel
          cs.CarouselSlider(
            carouselController: _carouselController,
            items: carTypeList.map((vehicle) {
              return Center(
                child: Image.asset(
                  vehicle.img!,
                  height: Dimensions.screenHeight * 0.25,
                  fit: BoxFit.contain,
                ),
              );
            }).toList(),
            options: cs.CarouselOptions(
              viewportFraction: 0.8,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                controller.selectVehicleType(index);
              },
            ),
          ),

          // Car Info Overlay
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeadingStyleText(
                          text: carTypeList[selectedIndex].name!,
                          size: Dimensions.font26 / 1.1,
                          family: 'Poppins',
                          weight: FontWeight.w700,
                        ),
                        SizedBox(height: Dimensions.height10 / 2),
                        SmallText(
                          text: carTypeList[selectedIndex].introduction!,
                          color: Colors.black54,
                          size: Dimensions.font16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBridge(
      CarWashController controller, bool hasSelection) {
    final carTypeList = controller.carWashSpecialties;
    final selectedIndex = controller.selectVehicleIndex;

    return Container(
      height: Dimensions.height45 * 1.2,
      margin: EdgeInsets.symmetric(
          horizontal: Dimensions.width20, vertical: Dimensions.height10),
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Selected Car Thumbnail
          if (hasSelection)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(carTypeList[selectedIndex].img!),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: LiveColors.accent, width: 2),
              ),
            ),
          if (hasSelection) SizedBox(width: Dimensions.width10),

          Expanded(
            child: Text(
              hasSelection
                  ? carTypeList[selectedIndex].name!
                  : 'Select a vehicle',
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w600,
                color: hasSelection ? Colors.black : Colors.grey,
              ),
            ),
          ),

          // Select Button
          ElevatedButton(
            onPressed: () {
              // Already selected - show confirmation or details
              if (hasSelection) {
                // Show vehicle details or do nothing
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSelection ? LiveColors.accent : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
              ),
            ),
            child: Text(hasSelection ? 'Selected' : 'Select'),
          ),

          SizedBox(width: Dimensions.width10),

          // Next Button
          ElevatedButton(
            onPressed: () {
              _carouselController.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
              ),
            ),
            child: Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildWashTypeSelection(CarWashController controller) {
    final washTypes = controller.washTypes;
    final selectedIndex = controller.washTypeIndex;

    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
            child: HeadingStyleText(
              text: 'Select Wash Type',
              size: Dimensions.font20,
              family: 'Poppins',
              weight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Dimensions.height15),

          // Horizontal Wash Type List
          Container(
            height: Dimensions.screenHeight * 0.2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              itemCount: washTypes.length,
              itemBuilder: (context, index) {
                final washType = washTypes[index];
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () => controller.selectWashType(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: Dimensions.screenWidth * 0.8,
                    margin: EdgeInsets.only(right: Dimensions.width15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                      border: Border.all(
                        color: isSelected
                            ? LiveColors.accent
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(Dimensions.width15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          HeadingStyleText(
                            text: washType['washType'],
                            size: Dimensions.font16 * 1.1,
                            family: 'Poppins',
                            weight: FontWeight.w600,
                          ),
                          SizedBox(height: Dimensions.height10),

                          // Included Features
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: (washType['included'] as List)
                                    .map<Widget>((feature) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Color(feature['color'])
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Image.asset(
                                            feature['image'],
                                            width: 16,
                                            height: 16,
                                          ),
                                        ),
                                        SizedBox(width: Dimensions.width10),
                                        Expanded(
                                          child: Text(
                                            feature['text'],
                                            style: TextStyle(
                                              fontSize: Dimensions.font16 / 1.1,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          // Description
                          SizedBox(height: Dimensions.height10),
                          Text(
                            washType['description'],
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.1,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CarWashController controller) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width15),
      margin: EdgeInsets.symmetric(
          horizontal: Dimensions.width20, vertical: Dimensions.height10),
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
          // ... rest of your cart summary
        ],
      ),
    );
  }

  Widget _buildAddToCartSection(
      CarWashController controller, bool hasSelection) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20, vertical: Dimensions.height20),
      child: CarWashAddToCart(
        onAddToCart: () {
          if (hasSelection) {
            controller.addCarWashToCart();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Car wash added to cart!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        onClearSelection: () {
          controller.clearCarWashCart();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selection cleared'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 1),
            ),
          );
        },
        hasSelection: hasSelection && controller.totalCarWashItems > 0,
        isActive: hasSelection,
      ),
    );
  }
}
