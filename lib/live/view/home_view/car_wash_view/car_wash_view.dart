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

import '../../../../models/new_specialty_model.dart';
import '../../../../widgets/texts/small_text.dart';
import '../controller/home_view_controller.dart';

class CarWashView extends StatefulWidget {
  const CarWashView({Key? key}) : super(key: key);

  @override
  State<CarWashView> createState() => _CarWashViewState();
}

class _CarWashViewState extends State<CarWashView> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _failedImageIndices = <int>{};
  bool _isLoading = false;
  bool _isAddingToCart = false;
  bool _showVehicleType = false;

  @override
  void initState() {
    super.initState();
    // Ensure cart is loaded when view starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CarWashController>();
      controller.loadCarWashCart();
      controller.syncWithMainCart();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeVehicleWithLoader(int index, CarWashController controller) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 300));

    controller.selectVehicleType(index);

    setState(() {
      _isLoading = false;
    });
  }

  void _addToCartWithLoader(CarWashController controller) async {
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    await Future.delayed(Duration(milliseconds: 1000));

    controller.addCarWashToCart();

    setState(() {
      _isAddingToCart = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Car wash added to cart!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCartDetailsDialog(CarWashController controller) {
    final cartItems = controller.carWashCartDetails;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        child: Container(
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeadingStyleText(
                text: 'Car Wash Services in Cart',
                size: Dimensions.font16 * 1.1,
                family: 'Poppins',
                weight: FontWeight.w600,
              ),
              SizedBox(height: Dimensions.height15),
              if (cartItems.isNotEmpty) ...[
// In the _showCartDetailsDialog method, update the ListView builder part:
                Container(
                  height: Dimensions.screenHeight * 0.3,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final imagePath =
                          item['image'] ?? 'assets/image/car_placeholder.png';
                      final vehicleType = item['vehicleType'] ?? 'Vehicle';
                      final washType = item['washType'] ?? 'Wash Type';
                      final price = item['price'] ?? 0;
                      final quantity = item['quantity'] ?? 0;

                      return Container(
                        margin: EdgeInsets.only(bottom: Dimensions.height10),
                        padding: EdgeInsets.all(Dimensions.width10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15),
                        ),
                        child: Row(
                          children: [
                            // Vehicle Image with error handling
                            Container(
                              width: Dimensions.height45,
                              height: Dimensions.height45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radius15 / 1.2),
                                color: Colors.grey.shade200,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radius15 / 1.2),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.directions_car,
                                      color: Colors.grey.shade400,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicleType,
                                    style: TextStyle(
                                      fontSize: Dimensions.font16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height10 / 4),
                                  Text(
                                    washType,
                                    style: TextStyle(
                                      fontSize: Dimensions.font16 / 1.1,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height10 / 4),
                                  Text(
                                    'R$price x $quantity',
                                    style: TextStyle(
                                      fontSize: Dimensions.font16 / 1.1,
                                      fontWeight: FontWeight.w500,
                                      color: LiveColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Total for this item
                            Text(
                              'R${price * quantity}',
                              style: TextStyle(
                                fontSize: Dimensions.font16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: Dimensions.height15),
                Divider(),
                SizedBox(height: Dimensions.height10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Items:',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${controller.totalCarWashItems}',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w600,
                        color: LiveColors.standardBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'R${controller.totalCarWashAmount}',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w600,
                        color: LiveColors.standardBlue,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  height: Dimensions.height45 * 2,
                  child: Center(
                    child: Text(
                      'No car wash services in cart',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: Dimensions.height20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      color: LiveColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearConfirmationDialog(CarWashController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        title: HeadingStyleText(
          text: 'Clear All Selections?',
          size: Dimensions.font16 * 1.1,
          family: 'Poppins',
          weight: FontWeight.w600,
        ),
        content: Text(
          'This will remove all car wash services from your cart. This action cannot be undone.',
          style: TextStyle(
            fontSize: Dimensions.font16,
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: Dimensions.font16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.clearCarWashCart();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All selections cleared'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Clear All',
              style: TextStyle(
                fontSize: Dimensions.font16,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
              // Increased height SliverAppBar (45%)
              SliverAppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: Dimensions.height30,
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
                      Container(width: Dimensions.width30),
                    ],
                  ),
                ),
                backgroundColor: LiveColors.accent.withOpacity(0.3),
                elevation: 0,
                pinned: true,
                expandedHeight: Dimensions.screenHeight * 0.35,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildTopSection(carWashController),
                ),
              ),

              // Vehicle Selection Bridge positioned at middle
              SliverToBoxAdapter(
                child: Container(
                  height: Dimensions.screenHeight * 0.4,
                  child: Column(
                    children: [
                      SizedBox(height: Dimensions.screenHeight * 0.05),
                      _buildVehicleSelectionConsole(carWashController),
                      Expanded(
                        child: _buildWashTypeSelection(carWashController),
                      ),
                    ],
                  ),
                ),
              ),

              // Add to Cart Section - Sticks to bottom
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    Expanded(child: SizedBox()),
                    _buildAddToCartSection(carWashController, hasSelection),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              _buildBottomNavBar(carWashController, hasCartItems),
        );
      },
    );
  }

  Widget _buildBottomNavBar(CarWashController controller, bool hasCartItems) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radius30 * 1.6),
          topRight: Radius.circular(Dimensions.radius30 * 1.6),
        ),
      ),
      height: Dimensions.bottomHeightBar / 1.3,
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20, vertical: Dimensions.height20 / 1.1),
      child: Row(
        children: [
          // Cart Items Count Button - Always visible if there are items
          if (controller.totalCarWashItems > 0)
            GestureDetector(
              onTap: () => _showCartDetailsDialog(controller),
              child: Container(
                width: Dimensions.height45,
                height: Dimensions.height45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${controller.totalCarWashItems}',
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

          if (controller.totalCarWashItems > 0)
            SizedBox(width: Dimensions.width10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Charges',
                  maxLines: 2,
                  style: TextStyle(
                    height: 1.2,
                    overflow: TextOverflow.ellipsis,
                    fontSize: Dimensions.font16 / 1.3,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 2),
                Text(
                  'R${controller.totalCarWashAmount},00*',
                  maxLines: 2,
                  style: TextStyle(
                    height: 1.2,
                    overflow: TextOverflow.ellipsis,
                    fontSize: Dimensions.font16 / 1.2,
                    fontFamily: 'Poppins',
                    color: LiveColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Checkout Button
          Container(
            height: Dimensions.height45,
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
            decoration: BoxDecoration(
              color: hasCartItems
                  ? LiveColors.accent.withOpacity(0.2)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
            ),
            child: TextButton(
              onPressed: hasCartItems
                  ? () {
                      final homeViewController =
                          Provider.of<HomeViewController>(context,
                              listen: false);
                      Navigator.of(context).pop();
                      homeViewController.changeIndex(2, false);
                    }
                  : null,
              child: Text(
                'Checkout',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(CarWashController controller) {
    final carTypeList = controller.carWashSpecialties;
    final selectedIndex = controller.selectVehicleIndex;
    final selectedVehicle = carTypeList[selectedIndex];

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
      child: Column(
        children: [
          SizedBox(height: Dimensions.height45),

          // Big Main Car Image
          Container(
            height: Dimensions.screenHeight * 0.18,
            alignment: Alignment.center,
            child: _isLoading
                ? _buildImageShimmer()
                : _buildMainCarImage(selectedVehicle.img, selectedIndex),
          ),

          SizedBox(height: Dimensions.height10),

          // Vehicle Info Container - Always shows both name and type
          _isLoading
              ? _buildVehicleInfoShimmer()
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      maxWidth:
                          Dimensions.screenWidth * 0.9, // Prevent overflow
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radius20 * 3),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IntrinsicWidth(
                      // Makes container fit content width
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Vehicle Name Section - Blue background
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width20,
                              vertical: Dimensions.height10,
                            ),
                            decoration: BoxDecoration(
                              color: LiveColors.accent,
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    Radius.circular(Dimensions.radius20 * 3),
                                bottomLeft:
                                    Radius.circular(Dimensions.radius20 * 3),
                              ),
                            ),
                            child: HeadingStyleText(
                              text: selectedVehicle.name!,
                              size: Dimensions.font16 / 1.1,
                              family: 'Poppins',
                              weight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),

                          // Vehicle Type Section - Lighter blue background
                          Flexible(
                            // Prevents overflow
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width15,
                                vertical: Dimensions.height10,
                              ),
                              decoration: BoxDecoration(
                                color: LiveColors.accent.withOpacity(0.15),
                                borderRadius: BorderRadius.only(
                                  topRight:
                                      Radius.circular(Dimensions.radius20 * 3),
                                  bottomRight:
                                      Radius.circular(Dimensions.radius20 * 3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: Dimensions.height20,
                                    width: 1,
                                    color: LiveColors.accent.withOpacity(0.5),
                                  ),
                                  SizedBox(width: Dimensions.width10),
                                  Flexible(
                                    // Prevents text overflow
                                    child: SmallText(
                                      text: selectedVehicle.introduction!,
                                      color: Colors.black87,
                                      size: Dimensions.font16 / 1.2,
                                      fontWeight: FontWeight.w500,
                                      maxLines: 1,
                                      softWrap: true,
                                      overFlow: TextOverflow.ellipsis,
                                    ),
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

          SizedBox(height: Dimensions.height10),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          maxWidth: Dimensions.screenWidth * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius20 * 3),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shimmer for vehicle name section
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radius20 * 3),
                    bottomLeft: Radius.circular(Dimensions.radius20 * 3),
                  ),
                ),
                child: Container(
                  width: Dimensions.width30 *
                      3, // Adjust based on typical name length
                  height: Dimensions.font16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radius20 / 2),
                  ),
                ),
              ),

              // Shimmer for vehicle type section
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Dimensions.radius20 * 3),
                    bottomRight: Radius.circular(Dimensions.radius20 * 3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: Dimensions.height20,
                      width: 1,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(width: Dimensions.width10),
                    Container(
                      width: Dimensions.width30 *
                          4, // Adjust based on typical type length
                      height: Dimensions.font16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius20 / 2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageShimmer() {
    return Container(
      width: Dimensions.screenWidth * 0.5,
      height: Dimensions.screenHeight * 0.12,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(Dimensions.radius15 / 1.2),
      ),
      child: Center(
        child: Icon(
          Icons.directions_car,
          size: Dimensions.iconSize26 * 2,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildMainCarImage(String? imagePath, int index) {
    final isFailed = _failedImageIndices.contains(index);

    if (isFailed || imagePath == null) {
      return _buildImagePlaceholder();
    }

    return Image.asset(
      imagePath,
      height: Dimensions.screenHeight * 0.3,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        if (!_failedImageIndices.contains(index)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _failedImageIndices.add(index);
            });
          });
        }
        return _buildImagePlaceholder();
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: Dimensions.screenHeight * 0.12,
      width: Dimensions.screenWidth * 0.5,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: Dimensions.iconSize26 * 2,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            'Car Image',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: Dimensions.font16 / 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelectionConsole(CarWashController controller) {
    final carTypeList = controller.carWashSpecialties;
    final selectedIndex = controller.selectVehicleIndex;
    final price = controller.calculateCharges();

    // Calculate square size - 1/5 of screen width
    final squareSize = Dimensions.screenWidth / 5;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: Column(
        children: [
          // "Select Vehicle" Label - Own Row aligned left
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: Dimensions.height15),
            child: Text(
              'Select Vehicle',
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),

          // Console and Price Row - Full width, flat layout
          Row(
            children: [
              // Vehicle Selection Squares
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(carTypeList.length, (index) {
                    final vehicle = carTypeList[index];
                    final isSelected = index == selectedIndex;
                    final isFailed = _failedImageIndices.contains(index);

                    return GestureDetector(
                      onTap: () => _changeVehicleWithLoader(index, controller),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: squareSize,
                        height: squareSize, // Square aspect ratio
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15 / 1.1),
                          border: Border.all(
                            color: isSelected
                                ? LiveColors.accent
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Vehicle Image or Placeholder
                            Center(
                              child: isFailed || vehicle.img == null
                                  ? Icon(
                                      Icons.directions_car,
                                      size: Dimensions.iconSize24,
                                      color: Colors.grey.shade400,
                                    )
                                  : Image.asset(
                                      vehicle.img!,
                                      width: squareSize * 0.6,
                                      height: squareSize * 0.6,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        if (!_failedImageIndices
                                            .contains(index)) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            setState(() {
                                              _failedImageIndices.add(index);
                                            });
                                          });
                                        }
                                        return Icon(
                                          Icons.directions_car,
                                          size: Dimensions.iconSize24,
                                          color: Colors.grey.shade400,
                                        );
                                      },
                                    ),
                            ),

                            // Selection Indicator
                            if (isSelected)
                              Positioned(
                                top: Dimensions.height10 / 2,
                                right: Dimensions.height10 / 2,
                                child: Container(
                                  width: Dimensions.iconSize16,
                                  height: Dimensions.iconSize16,
                                  decoration: BoxDecoration(
                                    color: LiveColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Spacer between console and price
              SizedBox(width: Dimensions.width15),

              // Price Display - Black container
              Container(
                width: squareSize,
                height: squareSize,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radius15 / 1.1),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'R$price',
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10 / 4),
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.1,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWashTypeSelection(CarWashController controller) {
    final washTypes = controller.washTypes;
    final selectedIndex = controller.washTypeIndex;

    return Container(
      padding: EdgeInsets.only(
        top: Dimensions.height20,
        left: Dimensions.width20,
        right: Dimensions.width20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Wash Type',
            style: TextStyle(
              fontSize: Dimensions.font16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: Dimensions.height15),

          // Horizontal Wash Type List
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: washTypes.length,
              itemBuilder: (context, index) {
                final washType = washTypes[index];
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () => controller.selectWashType(index),
                  child: Container(
                    width: Dimensions.screenWidth * 0.7,
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
                          // Header with selection indicator
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  washType['washType'],
                                  style: TextStyle(
                                    fontSize: Dimensions.font16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: LiveColors.accent,
                                  size: Dimensions.iconSize24 / 1.1,
                                ),
                            ],
                          ),
                          SizedBox(height: Dimensions.height10),

                          // Horizontal Included Features
                          Container(
                            height: Dimensions.height30,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: (washType['included'] as List)
                                  .map<Widget>((feature) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      right: Dimensions.width10),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.width10,
                                    vertical: Dimensions.height10 / 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(feature['color'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radius15 / 0.9),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        feature['image'],
                                        width: Dimensions.iconSize16,
                                        height: Dimensions.iconSize16,
                                      ),
                                      SizedBox(width: Dimensions.width10 / 2),
                                      Text(
                                        feature['text'],
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 / 1.1,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Description
                          SizedBox(height: Dimensions.height10),
                          Expanded(
                            child: Text(
                              washType['description'],
                              style: TextStyle(
                                fontSize: Dimensions.font16 / 1.1,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
        horizontal: Dimensions.width20,
        vertical: Dimensions.height10,
      ),
      decoration: BoxDecoration(
        color: LiveColors.standardBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.radius15 / 1.1),
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
          SizedBox(height: Dimensions.height10 / 2),
          Text(
            'Amount: R${controller.totalCarWashAmount}',
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.1,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartSection(
      CarWashController controller, bool hasSelection) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.bottomHeightBar / 1.3),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: CarWashAddToCart(
        onAddToCart: () => _addToCartWithLoader(controller),
        onClearSelection: () => _showClearConfirmationDialog(controller),
        hasSelection: hasSelection && controller.totalCarWashItems > 0,
        isActive: hasSelection,
        isLoading: _isAddingToCart,
      ),
    );
  }
}
