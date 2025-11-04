import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
import '../../../widgets/buttons/cart_action_button.dart';
import '../../../widgets/expandable_text_widget.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/icons/back_arrow.dart';
import '../../../widgets/text_widgets/introduction_text.dart';
import '../view_widgets/size_selection_modal.dart';

class ViewSpecialtyInfo extends StatelessWidget {
  final int index;
  final List homeItemList;
  const ViewSpecialtyInfo(
      {Key? key, required this.index, required this.homeItemList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var item = homeItemList[index];
    final sizeController = Get.find<SizeSelectionController>();
    final shouldShowSizeSelector = sizeController.shouldShowSizeSelector(item);

    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.98),
        body: GetBuilder<SizeSelectionController>(
            // This ensures the favorite icon updates when size changes
            builder: (sizeController) {
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
                      BackArrow(
                        iconColor: Colors.black,
                        onTap: () => Navigator.of(context).pop(),
                      ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IntroductionText(text: item.name),
                                SizedBox(height: 4),
                                SmallText(
                                  height: 1.5,
                                  color: Colors.black,
                                  size: Dimensions.font16 / 1.1,
                                  text: item.type,
                                  maxLines: 1,
                                  overFlow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (!_shouldHideTemperature(item))
                            _buildTemperatureToggle(item),
                        ],
                      ),
                      SizedBox(height: Dimensions.height20),

                      // Cart quantity display
                      _buildCartQuantitySection(
                          item, context, shouldShowSizeSelector),

                      // Show size selector only for items that need it
                      if (shouldShowSizeSelector) _buildSizeSelector(item),

                      GenericHeaderRow(
                        headingChild: IntroductionText(
                            text:
                                'R${_getDisplayPrice(item, shouldShowSizeSelector)},00*'),
                        actionButtonChild: GetBuilder<NewCartController>(
                          builder: (cartController) {
                            final quantityInCart =
                                cartController.getQuantity(item);
                            return CartActionButton(
                              isActive: true,
                              description: quantityInCart > 0
                                  ? 'Update Cart ($quantityInCart)'
                                  : 'Add to basket',
                              onTap: () => _addToCart(item, cartController,
                                  context, shouldShowSizeSelector),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: Dimensions.height20),

                      Row(children: [
                        IntroductionText(
                            text: 'Introduction', textSize: Dimensions.font20),
                      ]),
                      SizedBox(height: Dimensions.height10 / 1.4),

                      _buildExpandableText(item.introduction),
                      SizedBox(height: Dimensions.height20),
                    ],
                  ),
                ),
              )
            ],
          );
        }));
  }

  Widget _buildCartQuantitySection(
      dynamic item, BuildContext context, bool shouldShowSizeSelector) {
    return GetBuilder<NewCartController>(
      builder: (cartController) {
        if (shouldShowSizeSelector) {
          // For size variant items, show breakdown by sizes
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
              border:
                  Border.all(color: LiveColors.standardBlue.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total quantity header
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

                // Show individual size quantities
                Column(
                  children: sizeVariants.map((variant) {
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
                  }).toList(),
                ),
                SizedBox(height: 8),

                // Add more button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _addToCart(item, cartController, context,
                            shouldShowSizeSelector);
                      },
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          // For regular items, show simple quantity
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
              border:
                  Border.all(color: LiveColors.standardBlue.withOpacity(0.2)),
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
                TextButton(
                  onPressed: () {
                    _addToCart(
                        item, cartController, context, shouldShowSizeSelector);
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
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSizeSelector(NewSpecialtyModel item) {
    return GetBuilder<SizeSelectionController>(
      builder: (sizeController) {
        final selectedSize =
            sizeController.getSelectedSize(item.id, availableSizes: item.size);
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
                items: item.size!.map((size) {
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
                }).toList(),
                onChanged: (newSize) {
                  if (newSize != null) {
                    sizeController.selectSize(item.id, newSize);
                  }
                },
              ),
            ),
            SizedBox(height: Dimensions.height10),

            // Show size details if available
            if (item.details != null) _buildSizeDetails(item, selectedSize),

            SizedBox(height: Dimensions.height20),
          ],
        );
      },
    );
  }

  Widget _buildSizeDetails(NewSpecialtyModel item, String selectedSize) {
    // Find details for the selected size
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
