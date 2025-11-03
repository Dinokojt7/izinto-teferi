import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../controllers/favorite_controller.dart';
import '../../../../controllers/new_cart_controller.dart';
import '../../../../controllers/temperature_controller.dart';
import '../../../../models/new_cart_model.dart';
import '../../../../models/new_specialty_model.dart';
import '../../../../pages/cart/cart_processes_and_widgets/no_items.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/miscellaneous/app_icon.dart';
import '../../../../widgets/texts/small_text.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/generic_snackbar.dart';
import '../../../widgets/text_widgets/small_black_text.dart';
import '../../checkout_view/view_widgets/generic_white_container.dart';
import 'cart_product_actions.dart';

class CartProductView extends StatelessWidget {
  final List cartList;
  final int index;
  const CartProductView({
    super.key,
    required this.cartList,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final item = cartList[index];
    final isGasRefill = item.type?.toLowerCase().contains('gas') ?? false;
    final isHomeCare =
        item.material?.toLowerCase().contains('deep cleaning') ?? false;
    final hasSize = item is NewCartModel &&
        item.specialty is Map &&
        (item.specialty['selectedSize'] != null &&
            item.specialty['selectedSize'].isNotEmpty);
    final selectedSize = hasSize ? item.specialty['selectedSize'] : null;

    return Padding(
      padding:
          EdgeInsets.only(left: 16.0, top: 10.0, right: 16.0, bottom: 10.0),
      child: GenericWhiteContainer(
        topPadding: 10.0,
        leftPadding: 4.0,
        rightPadding: 6.0,
        bottomPadding: 10.0,
        child: Row(
          children: [
            // Temperature icon with conditional styling
            _buildTemperatureIcon(item, isGasRefill, isHomeCare, context),

            // Image with error handling
            Container(
              padding: EdgeInsets.only(left: 8, right: 12),
              child: _buildProductImage(item),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with price and favorite icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallBlackText(
                        text: 'R${item.price!.toString()},00*',
                        size: Dimensions.font20 / 1.1,
                        font: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      _buildFavoriteIcon(item, context),
                    ],
                  ),

                  SizedBox(height: 4),

                  // Product name with size if available
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SmallText(
                              height: 1.5,
                              color: Colors.black,
                              size: Dimensions.font16 / 1.3,
                              fontWeight: FontWeight.w500,
                              text: _getDisplayName(item, selectedSize),
                              maxLines: 1,
                              overFlow: TextOverflow.ellipsis,
                            ),
                            // Show size badge if available
                            if (hasSize && selectedSize != null)
                              Container(
                                margin: EdgeInsets.only(top: 2),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      LiveColors.standardBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  selectedSize,
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 / 1.2,
                                    color: LiveColors.standardBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2),

                  // Product type
                  Row(
                    children: [
                      Expanded(
                        child: SmallText(
                          height: 1.5,
                          color: Colors.black,
                          size: Dimensions.font16 / 1.5,
                          text: item.type ?? '',
                          maxLines: 1,
                          overFlow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Dimensions.height10),

                  // Bottom row with more info and quantity controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showProductDetails(context, item);
                        },
                        child: SmallBlackText(
                          text: 'More info',
                          decoration: TextDecoration.underline,
                          size: Dimensions.font20 / 1.8,
                          font: 'Poppins',
                          fontWeight: FontWeight.w600,
                          overFlow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      CartProductActions(
                        quantity: item.quantity,
                        index: index,
                        productName: item.name,
                        viewContext: context,
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureIcon(
      dynamic item, bool isGasRefill, bool isHomeCare, BuildContext context) {
    if (isGasRefill || isHomeCare) {
      // Dimmed/grayed out for gas refill and home care
      return AppIcon(
        size: 24,
        icon: Icons.thermostat,
        backgroundColor: Colors.grey.withOpacity(0.1),
        iconColor: Colors.grey,
      );
    } else {
      // Toggleable for laundry and pet care
      return GetBuilder<TemperatureController>(
        builder: (tempController) {
          final isHeated = tempController.isItemHeated(item.id);
          return GestureDetector(
            onTap: () {
              tempController.toggleTemperature(item.id);
              GenericSnackBar().showCustomSnackBar(
                  null,
                  context,
                  isHeated
                      ? 'Temperature set to normal'
                      : 'Temperature set to heated',
                  false);
            },
            child: AppIcon(
              size: 24,
              icon: Icons.thermostat,
              backgroundColor: isHeated
                  ? Colors.red.withOpacity(0.1)
                  : LiveColors.standardBlue.withOpacity(0.05),
              iconColor: isHeated ? Colors.red : Colors.black,
            ),
          );
        },
      );
    }
  }

  Widget _buildProductImage(dynamic item) {
    String imagePath = item.img ?? 'assets/image/placeholder.png';

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: Image.asset(
        imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 24,
                ),
                SizedBox(height: 4),
                Text(
                  'No Image',
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.3,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteIcon(dynamic item, BuildContext context) {
    return GetBuilder<FavoriteController>(
      builder: (favoriteController) {
        final isFavorite = favoriteController.isFavorite(item.id);
        return GestureDetector(
          onTap: () {
            favoriteController.toggleFavorite(item);
            GenericSnackBar().showCustomSnackBar(
                null,
                context,
                isFavorite ? 'Removed from favorites' : 'Added to favorites',
                false);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  isFavorite ? Colors.red.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? MdiIcons.heart : MdiIcons.heartOutline,
              color: isFavorite ? Colors.red : Colors.black.withOpacity(0.5),
              size: 20,
            ),
          ),
        );
      },
    );
  }

  String _getDisplayName(dynamic item, String? selectedSize) {
    String baseName = item.name ?? 'Unknown Item';

    // If item has a selected size, append it to the name
    if (selectedSize != null && selectedSize.isNotEmpty) {
      return '$baseName ($selectedSize)';
    }

    return baseName;
  }

  void _showProductDetails(BuildContext context, dynamic item) {
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Row(
              children: [
                _buildProductImage(item),
                SizedBox(width: Dimensions.width15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(
                            item,
                            item.specialty is Map
                                ? item.specialty['selectedSize']
                                : null),
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
                        item.type ?? '',
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.1,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'R${item.price},00',
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
            if (item.specialty is Map && item.specialty['introduction'] != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    item.specialty['introduction'],
                    style: TextStyle(
                      fontSize: Dimensions.font16 / 1.1,
                      height: 1.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    'No description available',
                    style: TextStyle(
                      fontSize: Dimensions.font16 / 1.1,
                      color: Colors.grey[500],
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
}
