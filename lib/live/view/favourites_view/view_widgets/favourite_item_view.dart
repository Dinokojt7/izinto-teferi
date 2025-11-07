import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../controllers/favorite_controller.dart';
import '../../../../models/new_specialty_model.dart';
import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../../widgets/text_widgets/small_black_text.dart';
import '../../checkout_view/view_widgets/generic_white_container.dart';
import '../../home_view/view_specialty_info/view_specialty_info.dart';

class FavoriteItemView extends StatefulWidget {
  final dynamic item;
  final int index;

  const FavoriteItemView({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<FavoriteItemView> createState() => _FavoriteItemViewState();
}

class _FavoriteItemViewState extends State<FavoriteItemView> {
  @override
  Widget build(BuildContext context) {
    final specialty = _getSpecialty(widget.item);
    final hasSize = specialty is NewSpecialtyModel &&
        specialty.selectedSize != null &&
        specialty.selectedSize!.isNotEmpty;
    final selectedSize = hasSize ? specialty.selectedSize : null;
    final isSizeVariant =
        specialty is NewSpecialtyModel && specialty.isSizeVariant == true;
    final baseProductName = specialty.name ?? 'Unknown Item';
    final price = specialty.price?.isNotEmpty == true ? specialty.price![0] : 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
      child: GenericWhiteContainer(
        leftPadding: 4.0,
        rightPadding: 4.0,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: Dimensions.width15,
            vertical: Dimensions.height10,
          ),
          leading: _buildProductImage(specialty),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with price and favorite icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmallBlackText(
                    size: Dimensions.font20 / 1.1,
                    font: 'Poppins',
                    text: 'R${price},00*',
                    fontWeight: FontWeight.w600,
                  ),
                  _buildFavoriteIcon(specialty, context),
                ],
              ),
              SizedBox(height: 2),

              // Product name
              Text(
                baseProductName,
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.3,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Dimensions.height10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Size badge if available or Product type
                  isSizeVariant && selectedSize != null
                      ? Container(
                          margin: EdgeInsets.only(top: 4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: LiveColors.standardBlue.withOpacity(0.1),
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
                        )
                      : Text(
                          specialty.type ?? '',
                          style: TextStyle(
                            fontSize: Dimensions.font16 / 1.3,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                  //More text link
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        SystemNavigation().applyCustomSystemChromeSettings(
                            Colors.white,
                            Brightness.dark,
                            Colors.white,
                            Brightness.dark);
                      });
                      Get.to(
                        () => ViewSpecialtyInfo(
                          index: 0,
                          homeItemList: [widget.item],
                          shouldReturnToBlack: true,
                        ),
                        transition: Transition.native,
                        duration: Duration(milliseconds: 500),
                      );
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
                ],
              ),
            ],
          ),
          onTap: () {
            setState(() {
              SystemNavigation().applyCustomSystemChromeSettings(
                  Colors.white, Brightness.dark, Colors.white, Brightness.dark);
            });
            Get.to(
              () => ViewSpecialtyInfo(
                index: 0,
                homeItemList: [widget.item],
                shouldReturnToBlack: true,
              ),
              transition: Transition.native,
              duration: Duration(milliseconds: 500),
            );
          },
        ),
      ),
    );
  }

  // Helper method to extract specialty from item
  dynamic _getSpecialty(dynamic item) {
    if (item is NewSpecialtyModel) {
      return item;
    } else if (item is Map) {
      // Convert map back to NewSpecialtyModel
      final map = item as Map;
      return NewSpecialtyModel(
        id: map['id'],
        name: map['name'],
        introduction: map['introduction'],
        price: map['price'] != null ? List<int>.from(map['price']) : null,
        size: map['size'] != null ? List<String>.from(map['size']) : null,
        img: map['img'],
        details: map['details'],
        type: map['type'],
        material: map['material'],
        provider: map['provider'],
        time: map['time'],
        originalId: map['originalId'],
        selectedSize: map['selectedSize'],
        isSizeVariant: map['isSizeVariant'] ?? false,
      );
    } else {
      // Fallback: create a basic specialty from item data
      return NewSpecialtyModel(
        id: item.id,
        name: item.name,
        price: [item.price ?? 0],
        img: item.img,
        type: item.type,
        material: item.material,
        provider: item.provider,
      );
    }
  }

  Widget _buildProductImage(dynamic specialty) {
    String imagePath = specialty.img ?? 'assets/image/placeholder.png';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: Image.asset(
        imagePath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
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
                  size: 20,
                ),
                SizedBox(height: 2),
                Text(
                  'No Image',
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.5,
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

  Widget _buildFavoriteIcon(dynamic specialty, BuildContext context) {
    return GetBuilder<FavoriteController>(
      builder: (favoriteController) {
        final isFavorite = favoriteController.isFavorite(specialty);
        return GestureDetector(
          onTap: () {
            favoriteController.clearFavoritesData(
              context,
              'Remove ${specialty.name ?? "item"} from favorites?',
              'Remove',
              false,
              widget.index,
              specialty,
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  isFavorite ? Colors.red.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? MdiIcons.heart : MdiIcons.heartOutline,
              color: isFavorite ? Colors.red : Colors.black.withOpacity(0.5),
              size: 22,
            ),
          ),
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, dynamic specialty, int price) {
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
                _buildProductImage(specialty),
                SizedBox(width: Dimensions.width15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(specialty, specialty.selectedSize),
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
                        specialty.type ?? '',
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.1,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'R$price,00',
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
            if (specialty.introduction != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    specialty.introduction!,
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

  String _getDisplayName(dynamic specialty, String? selectedSize) {
    String baseName = specialty.name ?? 'Unknown Item';

    // If item has a selected size, append it to the name
    if (selectedSize != null && selectedSize.isNotEmpty) {
      return '$baseName ($selectedSize)';
    }

    return baseName;
  }
}
