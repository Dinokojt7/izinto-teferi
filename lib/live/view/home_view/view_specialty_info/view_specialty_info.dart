import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../controllers/favorite_controller.dart';
import '../../../../controllers/new_cart_controller.dart';
import '../../../../controllers/size_selection_controller.dart';
import '../../../../controllers/temperature_controller.dart';
import '../../../../models/new_specialty_model.dart';
import '../../../../models/popular_specialty_model.dart';
import '../../../../models/recommended_specialty_model.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/texts/expandable_text.dart';
import '../../../../widgets/texts/small_text.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/generic_snackbar.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../../widgets/buttons/cart_action_button.dart';
import '../../../widgets/expandable_text_widget.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/icons/back_arrow.dart';
import '../../../widgets/text_widgets/introduction_text.dart';
import '../view_widgets/size_selection_modal.dart';

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
  dynamic get item {
    try {
      // Priority 1: Use directly passed item
      if (widget.item != null) {
        return widget.item;
      }

      // Priority 2: Use index-based lookup (backward compatibility)
      if (widget.index != null &&
          widget.homeItemList != null &&
          widget.index! < widget.homeItemList!.length) {
        return widget.homeItemList![widget.index!];
      }

      // Fallback: Handle error case
      throw Exception('ViewSpecialtyInfo: Could not resolve item. '
          'Either provide item directly or provide valid index and homeItemList.');
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving item: $e');
      }
      // Return a safe fallback item
      return _createFallbackItem();
    }
  }

  // Create a safe fallback item when data is invalid
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
      Navigator.of(context).pop(); // Fallback pop
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
    // Debug logging for release mode
    ReleaseDebug.logItem('ViewSpecialtyInfo', item);

    // SAFETY CHECK: Validate item before rendering
    if (item == null) {
      return _buildErrorScreen('Item data is null', _onTap);
    }

    // Additional safety check for critical properties
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
        backgroundColor: Colors.white.withOpacity(0.98),
        body: GetBuilder<SizeSelectionController>(builder: (sizeController) {
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
        }),
      ),
    );
  }

  Widget _buildContent(dynamic item, bool shouldShowSizeSelector) {
    try {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(item),
          SizedBox(height: Dimensions.height20),

          // Cart quantity display
          _buildCartQuantitySection(item, context, shouldShowSizeSelector),

          // Show size selector only for items that need it
          if (shouldShowSizeSelector) _buildSizeSelector(item),

          _buildActionSection(item, shouldShowSizeSelector),
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
                text: _safeGetType(item),
                maxLines: 1,
                overFlow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (!_shouldHideTemperature(item)) _buildTemperatureToggle(item),
      ],
    );
  }

  Widget _buildActionSection(dynamic item, bool shouldShowSizeSelector) {
    return GenericHeaderRow(
      headingChild: IntroductionText(
          text: 'R${_getDisplayPrice(item, shouldShowSizeSelector)},00*'),
      actionButtonChild: GetBuilder<NewCartController>(
        builder: (cartController) {
          try {
            final quantityInCart = cartController.getQuantity(item);
            return CartActionButton(
              isActive: true,
              description: quantityInCart > 0
                  ? 'Update Cart ($quantityInCart)'
                  : 'Add to basket',
              onTap: () => _addToCart(
                  item, cartController, context, shouldShowSizeSelector),
            );
          } catch (e) {
            return CartActionButton(
              isActive: false,
              description: 'Error',
              onTap: () {},
            );
          }
        },
      ),
    );
  }

  Widget _buildIntroductionSection(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          IntroductionText(text: 'Introduction', textSize: Dimensions.font20),
        ]),
        SizedBox(height: Dimensions.height10 / 1.4),
        _buildExpandableText(_safeGetIntroduction(item)),
      ],
    );
  }

  Widget _buildCartQuantitySection(
      dynamic item, BuildContext context, bool shouldShowSizeSelector) {
    return GetBuilder<NewCartController>(
      builder: (cartController) {
        try {
          if (shouldShowSizeSelector && item is NewSpecialtyModel) {
            return _buildSizeVariantCartSection(item, cartController);
          } else {
            return _buildSimpleCartSection(item, cartController);
          }
        } catch (e) {
          return SizedBox.shrink(); // Silent fail for cart section
        }
      },
    );
  }

  Widget _buildSizeVariantCartSection(
      NewSpecialtyModel item, NewCartController cartController) {
    try {
      final sizeVariants = cartController.getSizeVariants(item.id);
      final totalQuantity = cartController.getBaseProductQuantity(item.id);

      if (totalQuantity == 0) {
        return SizedBox.shrink();
      }

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
                  'In your cart:',
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.1,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Total: $totalQuantity',
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.1,
                    fontWeight: FontWeight.w600,
                    color: LiveColors.standardBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ..._buildSizeVariantList(sizeVariants),
            SizedBox(height: 8),
            _buildAddMoreButton(item, cartController, true),
          ],
        ),
      );
    } catch (e) {
      return SizedBox.shrink();
    }
  }

  List<Widget> _buildSizeVariantList(List<dynamic> sizeVariants) {
    return sizeVariants.map((variant) {
      try {
        final size = variant.specialty is NewSpecialtyModel
            ? (variant.specialty as NewSpecialtyModel).selectedSize
            : 'Standard';
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '• $size:',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.2,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${variant.quantity} items',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.2,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        return SizedBox.shrink();
      }
    }).toList();
  }

  Widget _buildSimpleCartSection(
      dynamic item, NewCartController cartController) {
    try {
      final quantityInCart = cartController.getQuantity(item);

      if (quantityInCart == 0) {
        return SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(Dimensions.width15),
        margin: EdgeInsets.only(bottom: Dimensions.height10),
        decoration: BoxDecoration(
          color: LiveColors.standardBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LiveColors.standardBlue.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'In your cart: $quantityInCart items',
              style: TextStyle(
                fontSize: Dimensions.font16 / 1.1,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            _buildAddMoreButton(item, cartController, false),
          ],
        ),
      );
    } catch (e) {
      return SizedBox.shrink();
    }
  }

  Widget _buildAddMoreButton(
      dynamic item, NewCartController cartController, bool isSizeVariant) {
    return TextButton(
      onPressed: () {
        _addToCart(item, cartController, context, isSizeVariant);
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        backgroundColor: LiveColors.standardBlue,
      ),
      child: Text(
        'Add More',
        style: TextStyle(
          fontSize: Dimensions.font16 / 1.2,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSizeSelector(NewSpecialtyModel item) {
    return GetBuilder<SizeSelectionController>(
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
                  color: LiveColors.standardBlue,
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
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: LiveColors.standardBlue, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                sizeDetail[selectedSize] ?? 'Size details',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.2,
                  color: Colors.blue[800],
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

  // ... (rest of the helper methods from previous version with try-catch wrappers)
  // Include all the _getPrice, _getPriceForSize, _addToCart, _buildFavoriteIcon,
  // _buildTemperatureToggle, _buildProductImage, _buildExpandableText methods
  // but wrap each one in try-catch blocks as shown above

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

    // Add bounds checking
    if (sizeIndex == -1) {
      return item.firstPrice;
    }

    if (sizeIndex < item.price!.length) {
      return item.price![sizeIndex];
    }

    // Fallback: If size index is out of price bounds, use first price
    return item.firstPrice;
  }

  void _addToCart(dynamic item, NewCartController cartController,
      BuildContext context, bool shouldShowSizeSelector) {
    if (shouldShowSizeSelector && item is NewSpecialtyModel) {
      final sizeController = Get.find<SizeSelectionController>();
      final selectedSize =
          sizeController.getSelectedSize(item.id, availableSizes: item.size);

      if (selectedSize.isEmpty) {
        // Show error if no size selected
        GenericSnackBar().showCustomSnackBar(
            null, context, 'Please select a size first', false);
        return;
      }

      // Create unique variant and add to cart
      _addSizeVariantToCart(item, selectedSize, cartController, context);
    } else {
      // Add single item directly
      cartController.addItem(item, 1);
      _showSuccessSnackbar(context, '${item.name} added to cart!');
    }
  }

  void _addSizeVariantToCart(NewSpecialtyModel item, String selectedSize,
      NewCartController cartController, BuildContext context) {
    final selectedPrice = _getPriceForSize(item, selectedSize);

    // Create unique cart item with size variant
    final cartItem = _createCartItemWithSize(item, selectedSize, selectedPrice);

    // Add to cart
    cartController.addItem(cartItem, 1);

    _showSuccessSnackbar(context, '$selectedSize ${item.name} added to cart!');

    // Optional: Show confirmation dialog for first addition
    _showSizeConfirmationDialog(item, selectedSize, selectedPrice, context);
  }

  void _showSizeConfirmationDialog(NewSpecialtyModel item, String selectedSize,
      int selectedPrice, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Size Added'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$selectedSize ${item.name}'),
            SizedBox(height: 8),
            Text('R$selectedPrice,00',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('You can add different sizes as separate items in your cart.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
    return GetBuilder<FavoriteController>(
      builder: (favoriteController) {
        final sizeController = Get.find<SizeSelectionController>();
        final shouldShowSizeSelector =
            sizeController.shouldShowSizeSelector(item);

        bool isFavorite;

        if (shouldShowSizeSelector && item is NewSpecialtyModel) {
          // For size variant items, check if the CURRENTLY SELECTED size is favorite
          final selectedSize = sizeController.getSelectedSize(item.id,
              availableSizes: item.size);

          if (selectedSize.isNotEmpty) {
            // Check if this specific size variant is favorite
            isFavorite =
                favoriteController.isSizeVariantFavorite(item.id, selectedSize);
          } else {
            // No size selected, check if base product has any favorites
            isFavorite = favoriteController.isBaseProductFavorite(item.id);
          }
        } else {
          // For regular items
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

// Helper method to handle size variant favorites
  void _handleSizeVariantFavorite(
    NewSpecialtyModel item,
    FavoriteController favoriteController,
    SizeSelectionController sizeController,
  ) {
    final selectedSize =
        sizeController.getSelectedSize(item.id, availableSizes: item.size);

    if (selectedSize.isEmpty) {
      // Show dialog to select size first
      Get.defaultDialog(
        title: 'Select Size',
        content: Text('Please select a size before adding to favorites.'),
        textConfirm: 'OK',
        onConfirm: () => Get.back(),
      );
      return;
    }

    // Create size variant for favorite
    final favoriteVariant = item.createFavoriteVariant(selectedSize);
    favoriteController.toggleFavorite(favoriteVariant);
  }

  Widget _buildTemperatureToggle(dynamic item) {
    return GetBuilder<TemperatureController>(
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

  bool _shouldHideTemperature(dynamic item) {
    final type = item.type?.toLowerCase() ?? '';
    final material = item.material?.toLowerCase() ?? '';
    return type.contains('gas') || material.contains('deep cleaning');
  }

  int _getPrice(dynamic item) {
    if (item is NewSpecialtyModel) return item.firstPrice;
    if (item is SpecialtyModel) return item.price ?? 0;
    if (item is Specialties) return item.price ?? 0;
    return 0;
  }

  // Create a copy of the item with selected size and price
  NewSpecialtyModel _createCartItemWithSize(
      NewSpecialtyModel item, String size, int price) {
    // Generate unique ID by combining original ID with size
    final uniqueId = _generateSizeVariantId(item.id, size);

    return NewSpecialtyModel(
      id: uniqueId, // ✅ Unique ID for cart
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
      originalId: item.id, // ✅ Store original product ID
      selectedSize: size, // ✅ Store selected size
      isSizeVariant: true, // ✅ Mark as size variant
    );
  }

  int _generateSizeVariantId(int? originalId, String size) {
    if (originalId == null) return size.hashCode.abs();

    // Create unique ID: originalId * 1000 + sizeHash
    final sizeHash = size.hashCode;
    final uniqueId = (originalId * 1000) + (sizeHash % 1000).abs();

    // Ensure it's positive and within int range
    return uniqueId.abs() % 1000000000; // Limit to 9 digits
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
