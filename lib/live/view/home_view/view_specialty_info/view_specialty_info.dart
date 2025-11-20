import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/controllers/favorite_controller.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/controllers/size_selection_controller.dart';
import 'package:izinto/controllers/temperature_controller.dart';
import 'package:izinto/models/new_specialty_model.dart';
import 'package:izinto/models/popular_specialty_model.dart';
import 'package:izinto/models/recommended_specialty_model.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/generic_snackbar.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../../widgets/buttons/cart_action_button.dart';
import '../../../widgets/expandable_text_widget.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/icons/back_arrow.dart';
import '../../../widgets/text_widgets/introduction_text.dart';

class ViewSpecialtyInfo extends StatefulWidget {
  final int? index;
  final List? homeItemList;
  final dynamic item;
  final bool shouldReturnToBlack;

  const ViewSpecialtyInfo({
    Key? key,
    this.index,
    this.homeItemList,
    this.item,
    this.shouldReturnToBlack = true,
  }) : super(key: key);

  @override
  State<ViewSpecialtyInfo> createState() => _ViewSpecialtyInfoState();
}

class _ViewSpecialtyInfoState extends State<ViewSpecialtyInfo> {
  // Track if controllers are ready
  bool _controllersReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    try {
      // Ensure all required controllers are registered and ready
      if (!Get.isRegistered<SizeSelectionController>()) {
        Get.put(SizeSelectionController());
      }
      if (!Get.isRegistered<NewCartController>()) {
        Get.put(NewCartController(cartRepo: Get.find()));
      }
      if (!Get.isRegistered<FavoriteController>()) {
        Get.put(FavoriteController());
      }
      if (!Get.isRegistered<TemperatureController>()) {
        Get.put(TemperatureController());
      }

      setState(() {
        _controllersReady = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing controllers: $e');
      }
      setState(() {
        _hasError = true;
      });
    }
  }

  dynamic get item {
    try {
      if (widget.item != null) {
        return widget.item;
      }

      if (widget.index != null &&
          widget.homeItemList != null &&
          widget.index! < widget.homeItemList!.length) {
        return widget.homeItemList![widget.index!];
      }

      throw Exception('ViewSpecialtyInfo: Could not resolve item.');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting item: $e');
      }
      return _createFallbackItem();
    }
  }

  NewSpecialtyModel _createFallbackItem() {
    return NewSpecialtyModel(
      id: -1,
      name: 'Item Not Available',
      introduction: 'This item could not be loaded properly.',
      price: [0],
      size: ['Standard'],
      img: 'assets/image/placeholder.png',
      type: 'Unavailable',
      material: 'Unknown',
      provider: 'System',
    );
  }

  void _handleBackNavigation(BuildContext context) {
    try {
      final navColor = widget.shouldReturnToBlack ? Colors.black : Colors.white;
      final brightness =
          widget.shouldReturnToBlack ? Brightness.light : Brightness.dark;

      SystemNavigation().applyCustomSystemChromeSettings(
        navColor,
        brightness,
        navColor,
        brightness,
      );

      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  void _applySystemChromeSettings() {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);
  }

  void _onTap() {
    _applySystemChromeSettings();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorScreen('Failed to initialize controllers', _onTap);
    }

    if (!_controllersReady) {
      return _buildLoadingScreen();
    }

    ReleaseDebug.logItem('ViewSpecialtyInfo', item);

    if (item == null) {
      return _buildErrorScreen('Item data is null', _onTap);
    }

    if (_isItemInvalid(item)) {
      return _buildErrorScreen('Item data is incomplete or invalid', _onTap);
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _applySystemChromeSettings();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.97),
        body: _buildSafeGetBuilder<SizeSelectionController>(
          builder: (sizeController) {
            try {
              final shouldShowSizeSelector =
                  sizeController.shouldShowSizeSelector(item);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    toolbarHeight: 50,
                    title: Padding(
                      padding: EdgeInsets.only(right: Dimensions.width10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BackArrow(iconColor: Colors.black, onTap: _onTap),
                          _buildFavoriteIcon(item),
                        ],
                      ),
                    ),
                    pinned: true,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    expandedHeight: 300,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildProductImage(item),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: Dimensions.width20,
                        right: Dimensions.width20,
                      ),
                      child: _buildContent(item, shouldShowSizeSelector),
                    ),
                  )
                ],
              );
            } catch (e) {
              return _buildErrorScreen('Error building screen: $e', _onTap);
            }
          },
        ),
        bottomNavigationBar: _buildSafeGetBuilder<SizeSelectionController>(
          builder: (sizeController) {
            final shouldShowSizeSelector =
                sizeController.shouldShowSizeSelector(item);

            return _buildBottomCartSection(
                item, context, shouldShowSizeSelector);
          },
        ),
      ),
    );
  }

  // Safe GetBuilder wrapper to prevent null check errors
  Widget _buildSafeGetBuilder<T extends GetxController>({
    required Widget Function(T) builder,
    Widget? loadingWidget,
  }) {
    if (!Get.isRegistered<T>()) {
      return loadingWidget ?? SizedBox.shrink();
    }

    return GetBuilder<T>(
      initState: (_) {},
      dispose: (_) {},
      builder: (controller) {
        return builder(controller);
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.97),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(dynamic item, bool shouldShowSizeSelector) {
    try {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Dimensions.height20),
          _buildHeaderSection(item),
          SizedBox(height: Dimensions.height20),
          Divider(color: Colors.grey.shade300, height: 1),
          SizedBox(height: Dimensions.height20),
          if (shouldShowSizeSelector) _buildSizeSelector(item),
          _buildPriceAndAddSection(item, shouldShowSizeSelector),
          SizedBox(height: Dimensions.height20),
          Divider(color: Colors.grey.shade300, height: 1),
          SizedBox(height: Dimensions.height20),
          _buildIntroductionSection(item),
          SizedBox(height: Dimensions.height20),
        ],
      );
    } catch (e) {
      return Column(
        children: [
          Text('Error displaying content', style: TextStyle(color: Colors.red)),
          SizedBox(height: 20),
          Text('Details: $e'),
        ],
      );
    }
  }

  Widget _buildHeaderSection(dynamic item) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntroductionText(text: _safeGetName(item)),
              SizedBox(height: 4),
              SmallText(
                height: 1.5,
                color: Colors.black,
                size: Dimensions.font16 / 1.1,
                text: _getDisplayType(item),
                maxLines: 1,
                overFlow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (_shouldShowTemperature(item)) _buildTemperatureToggle(item),
      ],
    );
  }

  Widget _buildPriceAndAddSection(dynamic item, bool shouldShowSizeSelector) {
    return _buildSafeGetBuilder<NewCartController>(
      builder: (cartController) {
        // Get the current size selection
        final sizeController = Get.find<SizeSelectionController>();
        final selectedSize = shouldShowSizeSelector && item is NewSpecialtyModel
            ? sizeController.getSelectedSize(item.id, availableSizes: item.size)
            : '';

        // Get quantity for the SPECIFIC size variant
        final quantity = _getCurrentSizeVariantQuantity(
            cartController, item, shouldShowSizeSelector, selectedSize);

        final displayPrice = _getDisplayPrice(item, shouldShowSizeSelector);
        final totalPrice = displayPrice * quantity;

        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price Section
              IntroductionText(
                  text:
                      'R${_getDisplayPrice(item, shouldShowSizeSelector)},00*'),

              // Unified Add to Cart / Quantity Controller
              _buildUnifiedCartButton(
                item,
                cartController,
                quantity,
                shouldShowSizeSelector,
                selectedSize,
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to get current size variant quantity
  int _getCurrentSizeVariantQuantity(NewCartController cartController,
      dynamic item, bool shouldShowSizeSelector, String selectedSize) {
    if (shouldShowSizeSelector &&
        item is NewSpecialtyModel &&
        selectedSize.isNotEmpty) {
      // For size variants, create a temporary item with the size variant ID to check quantity
      final sizeVariantId = _generateSizeVariantId(item.id!, selectedSize);
      final tempSizeVariantItem = NewSpecialtyModel(
        id: sizeVariantId,
        name: item.name,
        price: [_getPriceForSize(item, selectedSize)],
        size: [selectedSize],
        img: item.img,
        type: item.type,
        material: item.material,
        provider: item.provider,
        originalId: item.id,
        selectedSize: selectedSize,
        isSizeVariant: true,
      );
      return cartController.getQuantity(tempSizeVariantItem);
    } else {
      // For regular items without size variants
      return cartController.getQuantity(item);
    }
  }

  Widget _buildUnifiedCartButton(
    dynamic item,
    NewCartController cartController,
    int quantity,
    bool shouldShowSizeSelector,
    String selectedSize,
  ) {
    return Container(
      height:
          quantity > 0 ? Dimensions.height30 * 1.2 : Dimensions.height30 * 1.7,
      width: quantity > 0 ? 130 : 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        color: Colors.black,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          onTap: quantity == 0
              ? () => _addToCart(item, cartController, context,
                  shouldShowSizeSelector, selectedSize)
              : null,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: quantity == 0
                ? _buildAddToCartContent()
                : _buildQuantityControllerContent(item, cartController,
                    quantity, shouldShowSizeSelector, selectedSize),
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartContent() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
        child: Text(
          'Add to cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: Dimensions.font16,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControllerContent(
    dynamic item,
    NewCartController cartController,
    int quantity,
    bool shouldShowSizeSelector,
    String selectedSize,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remove Button
        Expanded(
          child: GestureDetector(
            onTap: () => _handleRemoveItem(item, cartController, quantity,
                shouldShowSizeSelector, selectedSize),
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radius15),
                  bottomLeft: Radius.circular(Dimensions.radius15),
                ),
              ),
              child: Icon(Icons.remove, color: Colors.white, size: 18),
            ),
          ),
        ),

        // Quantity Display
        Container(
          constraints: BoxConstraints(minWidth: 30),
          child: Text(
            quantity.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: Dimensions.font16,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Add Button
        Expanded(
          child: GestureDetector(
            onTap: () => _addToCart(item, cartController, context,
                shouldShowSizeSelector, selectedSize),
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(Dimensions.radius15),
                  bottomRight: Radius.circular(Dimensions.radius15),
                ),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _handleRemoveItem(
    dynamic item,
    NewCartController cartController,
    int quantity,
    bool shouldShowSizeSelector,
    String selectedSize,
  ) {
    if (quantity == 1) {
      _showRemoveConfirmationDialog(
          item, cartController, shouldShowSizeSelector, selectedSize);
    } else {
      _removeFromCart(
          item, cartController, shouldShowSizeSelector, selectedSize);
    }
  }

  void _showRemoveConfirmationDialog(
    dynamic item,
    NewCartController cartController,
    bool shouldShowSizeSelector,
    String selectedSize,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
          title: Text(
            'Remove Item',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font16 * 1.2,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
          content: Text(
              'Are you sure you want to remove ${_safeGetName(item)} from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeFromCart(
                    item, cartController, shouldShowSizeSelector, selectedSize);
              },
              child: Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntroductionSection(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          IntroductionText(text: 'Introduction', textSize: Dimensions.font20),
        ]),
        SizedBox(height: Dimensions.height10),
        _buildExpandableText(_safeGetIntroduction(item)),
      ],
    );
  }

  Widget _buildBottomCartSection(
      dynamic item, BuildContext context, bool shouldShowSizeSelector) {
    return _buildSafeGetBuilder<NewCartController>(
      builder: (cartController) {
        try {
          // Get the current size selection
          final sizeController = Get.find<SizeSelectionController>();
          final selectedSize =
              shouldShowSizeSelector && item is NewSpecialtyModel
                  ? sizeController.getSelectedSize(item.id,
                      availableSizes: item.size)
                  : '';

          // Get quantity for the SPECIFIC size variant
          final quantity = _getCurrentSizeVariantQuantity(
              cartController, item, shouldShowSizeSelector, selectedSize);

          if (quantity == 0) {
            return SizedBox.shrink();
          }

          final displayPrice = _getDisplayPrice(item, shouldShowSizeSelector);
          final totalPrice = displayPrice * quantity;

          return Container(
            padding: EdgeInsets.all(Dimensions.width15),
            margin: EdgeInsets.symmetric(
                horizontal: Dimensions.width20, vertical: Dimensions.height10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 0.7,
                  offset: Offset(0, 1.7),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Item Count with size info if applicable
                Row(
                  children: [
                    Text(
                      'Items',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Text(
                      '$quantity ${quantity == 1 ? 'item' : 'items'}',
                      style: TextStyle(
                        fontSize: Dimensions.font16 / 1.2,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (shouldShowSizeSelector && selectedSize.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(left: Dimensions.width10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          selectedSize,
                          style: TextStyle(
                            fontSize: Dimensions.font16 / 1.2,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                  ],
                ),

                // Total Price
                Text(
                  'R$totalPrice,00',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSizeSelector(NewSpecialtyModel item) {
    return _buildSafeGetBuilder<SizeSelectionController>(
      builder: (sizeController) {
        try {
          final selectedSize = sizeController.getSelectedSize(item.id,
              availableSizes: item.size);
          final selectedPrice = _getPriceForSize(item, selectedSize);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Size:',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  value: selectedSize.isNotEmpty ? selectedSize : null,
                  isExpanded: true,
                  underline: SizedBox(),
                  hint: Text('Choose a size'),
                  items: _buildSizeDropdownItems(item),
                  onChanged: (newSize) {
                    if (newSize != null) {
                      sizeController.selectSize(item.id, newSize);
                    }
                  },
                ),
              ),
              SizedBox(height: Dimensions.height10),
              if (item.details != null) _buildSizeDetails(item, selectedSize),
              SizedBox(height: Dimensions.height20),
            ],
          );
        } catch (e) {
          return Text('Error loading size selector');
        }
      },
    );
  }

  List<DropdownMenuItem<String>> _buildSizeDropdownItems(
      NewSpecialtyModel item) {
    try {
      return item.size!.map((size) {
        final price = _getPriceForSize(item, size);
        return DropdownMenuItem<String>(
          value: size,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                size,
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'R$price,00',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList();
    } catch (e) {
      return [
        DropdownMenuItem(value: 'Error', child: Text('Error loading sizes'))
      ];
    }
  }

  Widget _buildSizeDetails(NewSpecialtyModel item, String selectedSize) {
    try {
      final sizeDetail = item.details?.firstWhere(
        (detail) => detail is Map && detail.containsKey(selectedSize),
        orElse: () => null,
      );

      if (sizeDetail == null) return SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(Dimensions.width10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                sizeDetail[selectedSize] ?? 'Size details',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.2,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return SizedBox.shrink();
    }
  }

  // Safe accessor methods
  String _safeGetName(dynamic item) {
    try {
      return item.name?.toString() ?? 'Unknown Item';
    } catch (e) {
      return 'Unknown Item';
    }
  }

  String _safeGetType(dynamic item) {
    try {
      return item.type?.toString() ?? 'General';
    } catch (e) {
      return 'General';
    }
  }

  String _getDisplayType(dynamic item) {
    final type = _safeGetType(item).toLowerCase();
    final name = _safeGetName(item).toLowerCase();

    if (name.contains('fitted carpet') || type.contains('fitted carpet')) {
      return 'Per sqm';
    }

    return _safeGetType(item);
  }

  String _safeGetIntroduction(dynamic item) {
    try {
      return item.introduction?.toString() ?? 'No description available.';
    } catch (e) {
      return 'No description available.';
    }
  }

  // Validation method
  bool _isItemInvalid(dynamic item) {
    try {
      return item.id == null ||
          item.name == null ||
          item.name.toString().isEmpty ||
          item.price == null ||
          item.price.isEmpty;
    } catch (e) {
      return true;
    }
  }

  // Error screen
  Widget _buildErrorScreen(String message, onTap) {
    return Scaffold(
      appBar: AppBar(
        leading: BackArrow(
          iconColor: Colors.black,
          onTap: onTap,
        ),
        title: Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Could not load item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  int _getDisplayPrice(dynamic item, bool shouldShowSizeSelector) {
    if (shouldShowSizeSelector && item is NewSpecialtyModel) {
      final sizeController = Get.find<SizeSelectionController>();
      final selectedSize =
          sizeController.getSelectedSize(item.id, availableSizes: item.size);

      if (selectedSize.isNotEmpty) {
        return _getPriceForSize(item, selectedSize);
      }
    }

    return _getPrice(item);
  }

  int _getPriceForSize(NewSpecialtyModel item, String size) {
    if (item.size == null || item.price == null) {
      return item.firstPrice;
    }

    final sizeIndex = item.size!.indexOf(size);

    if (sizeIndex == -1) {
      return item.firstPrice;
    }

    if (sizeIndex < item.price!.length) {
      return item.price![sizeIndex];
    }

    return item.firstPrice;
  }

  void _addToCart(dynamic item, NewCartController cartController,
      BuildContext context, bool shouldShowSizeSelector, String selectedSize) {
    if (shouldShowSizeSelector && item is NewSpecialtyModel) {
      if (selectedSize.isEmpty) {
        GenericSnackBar().showCustomSnackBar(
            null, context, 'Please select a size first', false);
        return;
      }
      _addSizeVariantToCart(item, selectedSize, cartController);
    } else {
      cartController.addItem(item, 1);
    }
  }

  void _removeFromCart(dynamic item, NewCartController cartController,
      bool shouldShowSizeSelector, String selectedSize) {
    if (shouldShowSizeSelector && item is NewSpecialtyModel) {
      if (selectedSize.isEmpty) {
        return;
      }
      _removeSizeVariantFromCart(item, selectedSize, cartController);
    } else {
      cartController.addItem(item, -1);
    }
  }

  void _addSizeVariantToCart(NewSpecialtyModel item, String selectedSize,
      NewCartController cartController) {
    final selectedPrice = _getPriceForSize(item, selectedSize);
    final cartItem = _createCartItemWithSize(item, selectedSize, selectedPrice);
    cartController.addItem(cartItem, 1);
  }

  void _removeSizeVariantFromCart(NewSpecialtyModel item, String selectedSize,
      NewCartController cartController) {
    final selectedPrice = _getPriceForSize(item, selectedSize);
    final cartItem = _createCartItemWithSize(item, selectedSize, selectedPrice);
    cartController.addItem(cartItem, -1);
  }

  Widget _buildExpandableText(String text) {
    return ExpandableTextWidget(text: text);
  }

  Widget _buildProductImage(dynamic item) {
    return Image.asset(
      item.img,
      width: double.maxFinite,
      fit: BoxFit.scaleDown,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[100],
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 60,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteIcon(dynamic item) {
    return _buildSafeGetBuilder<FavoriteController>(
      builder: (favoriteController) {
        final sizeController = Get.find<SizeSelectionController>();
        final shouldShowSizeSelector =
            sizeController.shouldShowSizeSelector(item);

        bool isFavorite;

        if (shouldShowSizeSelector && item is NewSpecialtyModel) {
          final selectedSize = sizeController.getSelectedSize(item.id,
              availableSizes: item.size);

          if (selectedSize.isNotEmpty) {
            isFavorite =
                favoriteController.isSizeVariantFavorite(item.id, selectedSize);
          } else {
            isFavorite = favoriteController.isBaseProductFavorite(item.id);
          }
        } else {
          isFavorite = favoriteController.isFavorite(item);
        }

        return GestureDetector(
          onTap: () {
            if (shouldShowSizeSelector && item is NewSpecialtyModel) {
              _handleSizeVariantFavorite(
                  item, favoriteController, sizeController);
            } else {
              favoriteController.toggleFavorite(item);
            }
          },
          child: Icon(
            isFavorite ? MdiIcons.heart : MdiIcons.heartOutline,
            color: isFavorite ? Colors.red : Colors.black12.withOpacity(0.8),
            size: 26,
          ),
        );
      },
    );
  }

  void _handleSizeVariantFavorite(
    NewSpecialtyModel item,
    FavoriteController favoriteController,
    SizeSelectionController sizeController,
  ) {
    final selectedSize =
        sizeController.getSelectedSize(item.id, availableSizes: item.size);

    if (selectedSize.isEmpty) {
      Get.defaultDialog(
        backgroundColor: Colors.white,
        radius: Dimensions.radius15,
        title: 'Select Size',
        content: Text('Please select a size before adding to favorites.'),
        textConfirm: 'OK',
        onConfirm: () => Get.back(),
      );
      return;
    }

    final favoriteVariant = item.createFavoriteVariant(selectedSize);
    favoriteController.toggleFavorite(favoriteVariant);
  }

  Widget _buildTemperatureToggle(dynamic item) {
    // Disable temperature for car wash items
    if (_isCarWashItem(item)) {
      return SizedBox.shrink();
    }

    return _buildSafeGetBuilder<TemperatureController>(
      builder: (tempController) {
        final isHeated = tempController.isItemHeated(item.id);
        return GestureDetector(
          onTap: () => tempController.toggleTemperature(item.id),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHeated
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.thermostat,
                  color: isHeated ? Colors.red : Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  isHeated ? 'Heated' : 'Normal',
                  style: TextStyle(
                    fontSize: 12,
                    color: isHeated ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _shouldShowTemperature(dynamic item) {
    // Disable temperature for car wash items
    if (_isCarWashItem(item)) {
      return false;
    }

    final type = item.type?.toLowerCase() ?? '';
    final material = item.material?.toLowerCase() ?? '';
    return !(type.contains('gas') || material.contains('deep cleaning'));
  }

  bool _isCarWashItem(dynamic item) {
    final type = item.type?.toLowerCase() ?? '';
    final name = item.name?.toLowerCase() ?? '';
    final material = item.material?.toLowerCase() ?? '';

    return type.contains('car wash') ||
        name.contains('car wash') ||
        material.contains('car wash') ||
        type.contains('vehicle') ||
        name.contains('vehicle');
  }

  int _getPrice(dynamic item) {
    if (item is NewSpecialtyModel) return item.firstPrice;
    if (item is SpecialtyModel) return item.price ?? 0;
    if (item is Specialties) return item.price ?? 0;
    return 0;
  }

  NewSpecialtyModel _createCartItemWithSize(
      NewSpecialtyModel item, String size, int price) {
    final uniqueId = _generateSizeVariantId(item.id, size);

    return NewSpecialtyModel(
      id: uniqueId,
      name: item.name,
      introduction: item.introduction,
      price: [price],
      size: [size],
      img: item.img,
      details: item.details,
      type: item.type,
      material: item.material,
      provider: item.provider,
      time: item.time,
      originalId: item.id,
      selectedSize: size,
      isSizeVariant: true,
    );
  }

  int _generateSizeVariantId(int? originalId, String size) {
    if (originalId == null) return size.hashCode.abs();
    final sizeHash = size.hashCode;
    final uniqueId = (originalId * 1000) + (sizeHash % 1000).abs();
    return uniqueId.abs() % 1000000000;
  }
}

// Helper class for release mode debugging
class ReleaseDebug {
  static void logItem(String tag, dynamic item) {
    if (kDebugMode) {}
  }
}
