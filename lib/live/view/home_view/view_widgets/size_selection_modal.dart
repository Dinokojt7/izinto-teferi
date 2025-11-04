// lib/live/view/cart_view/view_widgets/size_selection_modal.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/controllers/size_selection_controller.dart';
import 'package:izinto/models/new_specialty_model.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:izinto/live/widgets/top_nortch.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/small_black_text.dart';

class SizeSelectionModal extends StatefulWidget {
  final NewSpecialtyModel item;
  final Function(String selectedSize, int selectedPrice)? onAddToCart;

  const SizeSelectionModal({
    Key? key,
    required this.item,
    this.onAddToCart,
  }) : super(key: key);

  @override
  _SizeSelectionModalState createState() => _SizeSelectionModalState();
}

class _SizeSelectionModalState extends State<SizeSelectionModal> {
  String? _selectedSize;
  int? _selectedPrice;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Set default selection
    if (widget.item.size != null && widget.item.size!.isNotEmpty) {
      _selectedSize = widget.item.size!.first;
      _selectedPrice = _getPriceForSize(_selectedSize!);
    }
  }

  int _getPriceForSize(String size) {
    final sizeIndex = widget.item.size?.indexOf(size) ?? 0;
    if (widget.item.price != null && sizeIndex < widget.item.price!.length) {
      return widget.item.price![sizeIndex];
    }
    return widget.item.firstPrice;
  }

  void _addToCart() {
    if (_selectedSize == null || _selectedPrice == null) return;

    final cartController = Get.find<NewCartController>();

    // Create a unique cart item with the selected size
    final cartItem = _createCartItemWithSize(_selectedSize!, _selectedPrice!);

    // Add to cart with quantity
    cartController.addItem(cartItem, _quantity);

    // Update size selection controller
    final sizeController = Get.find<SizeSelectionController>();
    sizeController.selectSize(widget.item.id, _selectedSize!);

    // Call callback if provided
    widget.onAddToCart?.call(_selectedSize!, _selectedPrice!);

    // Close modal
    Navigator.of(context).pop();
  }

  NewSpecialtyModel _createCartItemWithSize(String size, int price) {
    // Create a unique ID by combining original ID with size
    final uniqueId = _generateUniqueId(widget.item.id, size);

    return NewSpecialtyModel(
      id: uniqueId,
      name: '${widget.item.name} ($size)',
      introduction: widget.item.introduction,
      price: [price],
      size: [size],
      img: widget.item.img,
      details: widget.item.details,
      type: widget.item.type,
      material: widget.item.material,
      provider: widget.item.provider,
      time: widget.item.time,
      originalId: widget.item.id,
      selectedSize: size, // Store selected size
    );
  }

  int _generateUniqueId(int? originalId, String size) {
    // Generate a unique ID by combining original ID and size hash
    final sizeHash = size.hashCode;
    return originalId != null
        ? (originalId * 1000) + (sizeHash % 1000).abs()
        : sizeHash.abs();
  }

  @override
  Widget build(BuildContext context) {
    final availableSizes = widget.item.size ?? [];
    final prices = widget.item.price ?? [widget.item.firstPrice];

    return Container(
      height: MediaQuery.of(context).size.height / 2,
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width30, vertical: Dimensions.width20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header section
          Column(
            children: [
              TopNotch(color: Colors.black.withOpacity(0.1)),
              SizedBox(height: Dimensions.height20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeadingStyleText(
                    text: 'Select Size & Quantity',
                    weight: FontWeight.w600,
                    size: Dimensions.font20,
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height10),
              Divider(
                indent: 20,
                endIndent: 20,
                color: Colors.black26,
                height: 20,
              ),
            ],
          ),

          // Product info
          Row(
            children: [
              // Product image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(
                        widget.item.img ?? 'assets/image/placeholder.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadingStyleText(
                      text: widget.item.name ?? 'Product',
                      weight: FontWeight.w600,
                      size: Dimensions.font16,
                    ),
                    SizedBox(height: 4),
                    SmallBlackText(
                      text: widget.item.type ?? '',
                      size: Dimensions.font16 / 1.1,
                      font: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Size selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallBlackText(
                text: 'SELECT SIZE',
                size: Dimensions.font16 / 1.1,
                font: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: Dimensions.height10),
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableSizes.length,
                  itemBuilder: (context, index) {
                    final size = availableSizes[index];
                    final price =
                        index < prices.length ? prices[index] : prices.last;
                    final isSelected = _selectedSize == size;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSize = size;
                          _selectedPrice = price;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: Dimensions.width10),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                          vertical: Dimensions.height10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[50] : Colors.grey[50],
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              size,
                              style: TextStyle(
                                fontSize: Dimensions.font16 / 1.1,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'R$price,00',
                              style: TextStyle(
                                fontSize: Dimensions.font16 / 1.2,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected ? Colors.blue : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Quantity selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallBlackText(
                text: 'QUANTITY',
                size: Dimensions.font16 / 1.2,
                font: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Decrease button
                    IconButton(
                      icon: Icon(Icons.remove, size: 20),
                      onPressed: _quantity > 1
                          ? () {
                              setState(() => _quantity--);
                            }
                          : null,
                      color: _quantity > 1 ? Colors.black : Colors.grey,
                    ),

                    // Quantity display
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: Dimensions.width20),
                      child: Text(
                        _quantity.toString(),
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Increase button
                    IconButton(
                      icon: Icon(Icons.add, size: 20),
                      onPressed: _quantity < 20
                          ? () {
                              setState(() => _quantity++);
                            }
                          : null,
                      color: _quantity < 20 ? Colors.black : Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Total price and add to cart button
          Column(
            children: [
              Divider(color: Colors.grey[300]),
              SizedBox(height: Dimensions.height10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmallBlackText(
                    text: 'TOTAL',
                    size: Dimensions.font16,
                    font: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                  HeadingStyleText(
                    text: 'R${((_selectedPrice ?? 0) * _quantity)},00',
                    weight: FontWeight.w700,
                    size: Dimensions.font20,
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              SaveButton(
                buttonHeight: Dimensions.bottomHeightBar / 2.1,
                isActive: _selectedSize != null,
                description: 'Add to Cart',
                onTap: _selectedSize != null ? _addToCart : () {},
                isAuthScreen: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
