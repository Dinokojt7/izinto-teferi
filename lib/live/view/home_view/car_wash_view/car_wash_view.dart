import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/auxiliery_classes/live_progress_indicator.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/car_wash_add_to_cart.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/car_wash_bottom_sheet.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/specialty_bottom_checkout_nav.dart';
import 'package:izinto/live/widgets/buttons/blue_text_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/icons/back_arrow.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

import '../../../../models/new_specialty_model.dart';
import '../../../../widgets/texts/small_text.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/top_nortch.dart';
import '../../address_view/controller/address_dropdown_controller.dart';
import '../../profile_view/controller/profile_view_controller.dart';
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
  bool _showTooltip = false;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _showTooltip = false;
    _isTapped = false;
    // Ensure cart is loaded when view starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CarWashController>();
      controller.loadCarWashCart();
      controller.syncWithMainCart();
    });
  }

  String _getLeftIntroductionParts(String introduction) {
    final parts = introduction.split(',').map((part) => part.trim()).toList();
    final half = (parts.length / 2).ceil();
    return parts.sublist(0, half).join(', ');
  }

  String _getRightIntroductionParts(String introduction) {
    final parts = introduction.split(',').map((part) => part.trim()).toList();
    final half = (parts.length / 2).ceil();
    return parts.sublist(half).join(', ');
  }

  double _calculateLeftMargin(String introduction, index) {
    final leftText = _getLeftIntroductionParts(introduction);
    final textLength = leftText.length;

    // More text = more margin needed
    if (index == 0) return Dimensions.screenWidth * 0.57;
    if (index == 1) return Dimensions.screenWidth * 0.58;
    if (index == 2) return Dimensions.screenWidth * 0.54;
    return Dimensions.screenWidth * 0.8;
  }

  double _calculateRightMargin(String introduction, index) {
    final rightText = _getRightIntroductionParts(introduction);
    final textLength = rightText.length;

    // More text = more margin needed
    if (index == 0) return Dimensions.screenWidth * 0.48;
    if (index == 1) return Dimensions.screenWidth * 0.58;
    if (index == 2) return Dimensions.screenWidth * 0.60;
    return Dimensions.screenWidth * 0.4;
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
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // This makes the bottom sheet reactive to changes
          final cartItems = controller.carWashCartDetails;
          final totalItems = controller.totalCarWashItems;
          final totalAmount = controller.totalCarWashAmount;

          return Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.85,
                padding: EdgeInsets.all(Dimensions.width20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: Dimensions.height10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header Row with items count and remove all
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Dimensions.width15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
                      ),
                      child: GenericHeaderRow(
                        headingChild: Row(
                          children: [
                            Text(
                              'Your items',
                              style: TextStyle(
                                fontSize: Dimensions.font20 / 1.1,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),
                            Text(
                              '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                              style: TextStyle(
                                fontSize: Dimensions.font16 / 1.5,
                                color: Colors.grey.shade600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        actionButtonChild: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _showClearAllConfirmationDialog(controller);
                          },
                          child: Text(
                            'Remove all',
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.3,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: Dimensions.height20),

                    // Cart Items List
                    Expanded(
                      child: cartItems.isNotEmpty
                          ? Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: cartItems.length,
                                    itemBuilder: (context, index) {
                                      final item = cartItems[index];
                                      return Column(
                                        children: [
                                          _buildCartItemCard(
                                              controller,
                                              item,
                                              index,
                                              () => setState(
                                                  () {}) // Refresh function
                                              ),
                                          if (index < cartItems.length - 1)
                                            Divider(
                                              color: Colors.grey.shade200,
                                              height: 1,
                                              thickness: 0.5,
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),

                                // Spacer before total
                                SizedBox(height: Dimensions.height20),

                                // Total Section
                                Container(
                                  padding: EdgeInsets.all(Dimensions.width15),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radius15),
                                    border: Border.all(
                                        color: Colors.blue.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: TextStyle(
                                          fontSize: Dimensions.font16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      Text(
                                        'R${totalAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 * 1.1,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.local_car_wash,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height20),
                                  Text(
                                    'No car wash services',
                                    style: TextStyle(
                                      fontSize: Dimensions.font16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: Dimensions.height10),
                                  Text(
                                    'Add services to see them here',
                                    style: TextStyle(
                                      fontSize: Dimensions.font16 / 1.2,
                                      color: Colors.grey.shade500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

// Updated cart item card with reactivity
  Widget _buildCartItemCard(
    CarWashController controller,
    Map<String, dynamic> item,
    int index,
    VoidCallback refreshCallback, // Add this callback
  ) {
    final imagePath = item['image'] ?? 'assets/image/car_placeholder.png';
    final vehicleType = item['vehicleType'] ?? 'Vehicle';
    final washType = item['washType'] ?? 'Wash Type';
    final price = item['price'] ?? 0;
    final quantity = item['quantity'] ?? 0;
    final itemId = item['id'];
    final description = item['description'] ?? '';

    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.grey.shade400,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: Dimensions.width15),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Type and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        vehicleType,
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'R${price.toStringAsFixed(0)},00',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: Colors.black, // Changed from blue to black
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Dimensions.height10 / 2),

                // Wash Type (Full text, no ellipsis)
                Text(
                  washType,
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.2,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),

                SizedBox(height: Dimensions.height10),

                // Description if available
                if (description.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.3,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Dimensions.height10),
                    ],
                  ),

                // Quantity Controls
                Container(
                  width: 120,
                  height: Dimensions.height30 * 1.2,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radius20 / 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Decrement Button
                      GestureDetector(
                        onTap: () {
                          if (quantity == 1) {
                            // Show remove confirmation
                            _showRemoveItemDialog(
                                controller, itemId, vehicleType, washType,
                                onRemove: () {
                              refreshCallback(); // Refresh the bottom sheet
                            });
                          } else {
                            controller.updateCarWashQuantity(
                                itemId, quantity - 1);
                            controller.update();
                            refreshCallback(); // Refresh the bottom sheet
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: Dimensions.iconSize16,
                          ),
                        ),
                      ),

                      // Quantity
                      Container(
                        constraints: BoxConstraints(minWidth: 20),
                        child: Text(
                          quantity.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: Dimensions.font16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Increment Button
                      GestureDetector(
                        onTap: () {
                          controller.updateCarWashQuantity(
                              itemId, quantity + 1);
                          controller.update();
                          refreshCallback(); // Refresh the bottom sheet
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: Dimensions.iconSize16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Updated remove item dialog to accept refresh callback
  void _showRemoveItemDialog(
    CarWashController controller,
    String itemId,
    String vehicleType,
    String washType, {
    VoidCallback? onRemove,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Item'),
        content: Text('Remove $vehicleType - $washType from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.removeFromCarWashCart(itemId);
              controller.update();
              Navigator.of(context).pop();
              onRemove?.call(); // Call refresh callback
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Remove',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(BuildContext context, String vehicleType,
      String washType, int price, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: EdgeInsets.all(Dimensions.width20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: LiveColors.accent.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radius20 / 2),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: LiveColors.accent,
                    size: 30,
                  ),
                ),
                SizedBox(width: Dimensions.width15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleType,
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 1.1,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        washType,
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.1,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'R$price',
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w700,
                          color: LiveColors.standardBlue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  description.isNotEmpty
                      ? description
                      : 'No additional details available for this service.',
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.1,
                    height: 1.5,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllConfirmationDialog(CarWashController controller) {
    bool isLoading = false;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return CarWashBottomSheet(
            headerText: 'Clear All Services?',
            description:
                'This will remove all car wash services from your cart. This action cannot be undone.',
            action: 'Clear All',
            isMiniaturized: false,
            isLoading: isLoading,
            onTap: () async {
              setState(() => isLoading = true);
              await Future.delayed(Duration(milliseconds: 500));

              controller.clearCarWashCart();
              controller.update(); // Force UI rebuild

              setState(() => isLoading = false);
              Navigator.of(context).pop(); // Close clear all dialog

              // Show success feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All services cleared from cart'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarWashController>(
      builder: (carWashController) {
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
        final selectedVehicleIndex = carWashController.selectVehicleIndex;
        final selectedWashTypeIndex = carWashController.washTypeIndex;
        final price = carWashController.calculateCharges();
        final carTypeList = carWashController.carWashSpecialties;
        final hasCartItems = carWashController.totalCarWashItems > 0;
        final hasSelection =
            selectedVehicleIndex != -1 && selectedWashTypeIndex != -1;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              body: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Increased height SliverAppBar (45%)
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    toolbarHeight: Dimensions.height30,
                    title: buildAppBar(context, street, suburb),
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
                      height: Dimensions.screenHeight * 0.43,
                      color: Colors.grey.shade50,
                      child: Column(
                        children: [
                          SizedBox(height: Dimensions.screenHeight * 0.02),
                          _buildVehicleSelectionConsole(carWashController),
                          Expanded(
                              child:
                                  _buildWashTypeSelection(carWashController)),
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
            ),
            _isLoading ? LiveProgressIndicator() : Container()
          ],
        );
      },
    );
  }

  Padding buildAppBar(BuildContext context, String street, String suburb) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width10 / 2, vertical: Dimensions.height30),
      child: Column(
        children: [
          SizedBox(height: Dimensions.height20 / 3),
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
                MdiIcons.magnify,
                color: Colors.black12.withOpacity(0.8),
                size: 26,
              ),
            ],
          ),
        ],
      ),
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
                  : Colors.grey.shade800,
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
                  color: hasCartItems ? Colors.white : Colors.white10,
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
            LiveColors.whiteTextColor.withOpacity(0.3),
            LiveColors.whiteTextColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: Dimensions.height45 * 1.4),

          // Big Main Car Image
          Container(
            height: Dimensions.screenHeight * 0.22,
            alignment: Alignment.center,
            child: _isLoading
                ? _buildImageShimmer()
                : _buildMainCarImage(selectedVehicle.img, selectedIndex),
          ),

          SizedBox(height: Dimensions.height10),

          // Vehicle Info with Tooltip
          _isLoading
              ? _buildVehicleInfoShimmer()
              : Container(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Left Tooltip - First half of introduction parts
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.only(
                          right: _showTooltip
                              ? _calculateLeftMargin(
                                  selectedVehicle.introduction!, selectedIndex)
                              : 0,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                          vertical: Dimensions.height10 / 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Dimensions.radius20 * 3),
                            bottomLeft:
                                Radius.circular(Dimensions.radius20 * 3),
                          ),
                          border: Border.all(
                            color: LiveColors.accent.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SmallText(
                          text: _showTooltip
                              ? _getLeftIntroductionParts(
                                  selectedVehicle.introduction!)
                              : '',
                          color: Colors.black87,
                          size: Dimensions.font16 / 1.4,
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                          softWrap: false,
                          overFlow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Right Tooltip - Second half of introduction parts
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.only(
                          left: _showTooltip
                              ? _calculateRightMargin(
                                  selectedVehicle.introduction!, selectedIndex)
                              : 0,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                          vertical: Dimensions.height10 / 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(Dimensions.radius20 * 3),
                            bottomRight:
                                Radius.circular(Dimensions.radius20 * 3),
                          ),
                          border: Border.all(
                            color: LiveColors.accent.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SmallText(
                          text: _showTooltip
                              ? _getRightIntroductionParts(
                                  selectedVehicle.introduction!)
                              : '',
                          color: Colors.black87,
                          size: Dimensions.font16 / 1.4,
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                          softWrap: false,
                          overFlow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Main Name Container with tap behavior
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(
                          horizontal: _showTooltip
                              ? Dimensions.screenWidth * 0.3
                              : Dimensions.width10,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showTooltip = !_showTooltip;
                            });
                          },
                          onTapDown: (_) {
                            setState(() {
                              _isTapped = true;
                            });
                          },
                          onTapCancel: () {
                            setState(() {
                              _isTapped = false;
                            });
                          },
                          onTapUp: (_) {
                            setState(() {
                              _isTapped = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 100),
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width20,
                              vertical: Dimensions.height10,
                            ),
                            decoration: BoxDecoration(
                              color: _isTapped ? Colors.white : Colors.white,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radius20 * 3),
                              boxShadow: _isTapped
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: HeadingStyleText(
                              text: selectedVehicle.name!,
                              size: Dimensions.font20 / 1.4,
                              family: 'Poppins',
                              weight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          SizedBox(height: Dimensions.height10),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center name shimmer
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: Dimensions.screenWidth * 0.25),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height10,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(Dimensions.radius20 * 3),
            ),
          ),
        ],
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
      margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: Column(
        children: [
          // "Select Vehicle" Label - Own Row aligned left
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: Dimensions.height10),
            child: GenericHeaderRow(
              headingChild: HeadingStyleText(
                text: 'Select Vehicle',
                size: Dimensions.font16 / 1.2,
                weight: FontWeight.w600,
              ),
            ),
          ),

          // Console and Price Row - Full width, flat layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Vehicle Selection Squares
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(carTypeList.length, (index) {
                  final vehicle = carTypeList[index];
                  final isSelected = index == selectedIndex;
                  final isFailed = _failedImageIndices.contains(index);

                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isTapped = false;
                          _showTooltip = false;
                        });
                        _changeVehicleWithLoader(index, controller);
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: squareSize / 1.2,
                        height: squareSize / 1.2, // Square aspect ratio
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15 / 1.1),
                          border: Border.all(
                            color: isSelected
                                ? LiveColors.accent
                                : Colors.grey.shade300,
                            width: 1,
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
                                child: Icon(
                                  Icons.check,
                                  color: Colors.black45,
                                  size: Dimensions.iconSize24 / 1.4,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // Spacer between console and price

              // Price Display - Black container
              GenericHeaderRow(
                headingChild: HeadingStyleText(
                  text: 'R$price.00*',
                  size: Dimensions.font16,
                  weight: FontWeight.w600,
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
        top: Dimensions.height30 / 1.2,
        left: Dimensions.width20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Wash',
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.2,
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
                final washTypeName =
                    _removeWashFromString(washType['washType']);

                return Stack(
                  children: [
                    // Main Container
                    Container(
                      width: Dimensions.screenWidth * 0.8,
                      height: Dimensions.screenHeight / 5.7,
                      margin: EdgeInsets.only(
                        top: Dimensions.height20 *
                            1.2, // Space for the name label
                        right: Dimensions.width15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
                        border: Border.all(
                          color: isSelected
                              ? LiveColors.accent
                              : Colors.grey.shade300,
                          width: 1,
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
                        padding: EdgeInsets.only(
                            left: Dimensions.width15,
                            top: Dimensions.height30,
                            right: Dimensions.width15,
                            bottom: Dimensions.height15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Middle Section - Features list
                            Container(
                              height: Dimensions.screenWidth / 6,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: (washType['included'] as List)
                                    .map<Widget>((feature) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showFeatureTooltip(
                                          context, feature['text']);
                                    },
                                    child: Container(
                                      width: Dimensions.screenWidth / 6,
                                      margin: EdgeInsets.only(
                                          right: Dimensions.width10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radius15 / 2),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          feature['image'],
                                          width: Dimensions.iconSize24 * 2,
                                          height: Dimensions.iconSize24 * 1.5,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            SizedBox(height: Dimensions.height10),

                            // Bottom Section - Description text
                            GestureDetector(
                              onTap: () {
                                _showDescriptionTooltip(
                                    context, washType['description']);
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SmallText(
                                      text: washType['description'],
                                      color: Colors.black87,
                                      size: Dimensions.font16 / 1.4,
                                      fontWeight: FontWeight.w500,
                                      maxLines: 1,
                                      softWrap: false,
                                      overFlow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Name Container - Positioned at top border
// Name Container - Positioned at top border
                    Positioned(
                      top: 4,
                      left: Dimensions.width20 * 2,
                      right: Dimensions.width20 * 2,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isTapped = false;
                            _showTooltip = false;
                          });
                          controller.selectWashType(index);
                        },
                        onTapDown: (_) {
                          setState(() {
                            _isTapped = true;
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            _isTapped = false;
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            _isTapped = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width20,
                            vertical: Dimensions.height10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius20 * 3),
                            border: Border.all(
                              color: isSelected
                                  ? LiveColors.accent
                                  : Colors.grey.shade300,
                              width: isSelected ? 0 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: HeadingStyleText(
                            text: washTypeName,
                            size: Dimensions.font20 / 1.4,
                            family: 'Poppins',
                            weight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors
                                    .black, // Text color changes with container
                            align: TextAlign.center,
                            maxLines: 2,
                            overFlow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Keep the same tooltip methods with consistent styling
  void _showFeatureTooltip(BuildContext context, String featureText) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: Dimensions.screenHeight * 0.3,
        left: Dimensions.screenWidth * 0.1,
        right: Dimensions.screenWidth * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radius20 * 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SmallText(
                text: featureText,
                color: Colors.black87,
                size: Dimensions.font16 / 1.4,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                softWrap: false,
                overFlow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after 3 seconds with fade
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _showDescriptionTooltip(BuildContext context, String description) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: Dimensions.screenHeight * 0.25,
        left: Dimensions.screenWidth * 0.1,
        right: Dimensions.screenWidth * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radius20 * 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SmallText(
                text: description,
                color: Colors.black87,
                size: Dimensions.font16 / 1.4,
                fontWeight: FontWeight.w500,
                maxLines: 2,
                softWrap: false,
                overFlow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after 3 seconds with fade
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

// Helper method to remove "Wash" from the string
  String _removeWashFromString(String washType) {
    return washType.replaceAll(' Wash', '').replaceAll('wash', '').trim();
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
      margin: EdgeInsets.only(bottom: Dimensions.bottomHeightBar / 15),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
      ),
      decoration: BoxDecoration(),
      child: CarWashAddToCart(
        itemCount: '${controller.totalCarWashItems}',
        onAddToCart: () => _addToCartWithLoader(controller),
        onClearSelection: () => _showCartDetailsDialog(controller),
        hasSelection: hasSelection && controller.totalCarWashItems > 0,
        isActive: hasSelection,
        isLoading: _isAddingToCart,
      ),
    );
  }
}
