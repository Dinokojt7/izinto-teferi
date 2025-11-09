import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../utils/dimensions.dart';
import '../../../widgets/buttons/save_button.dart';
import '../../../widgets/text_widgets/small_black_text.dart';

class LatestOrderItem extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  const LatestOrderItem({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getFirstItemImage(order);
    final totalAmount = order['totalAmount'] ?? 0;
    final status = order['status'] ?? 'pending';
    final createdAt = order['createdAt'] != null
        ? _formatTimestamp(order['createdAt'])
        : 'Unknown date';
    final orderId = order['orderId'] ?? 'N/A';
    final items = order['items'] ?? [];
    final serviceTypes = order['serviceTypes'] ?? [];
    final address = _getAddress(order);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20 / 2),
        child: Container(
          height: Dimensions.screenHeight / 2.5,
          width: Dimensions.screenWidth,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 0.7,
                offset: Offset(0, 1.7),
              ),
            ],
            border: Border.all(
              width: 0.5,
              color: Colors.black.withOpacity(0.04),
            ),
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width30 / 1.2,
                vertical: Dimensions.height20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Order ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmallBlackText(
                      size: Dimensions.font20 / 1.1,
                      font: 'Poppins',
                      text: 'Order ${orderId}',
                      fontWeight: FontWeight.w600,
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                // Image and Service Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Stacked images container
                          Container(
                            width: 120, // Enough width to show the stack effect
                            child: Stack(
                              children: _buildStackedImages(items, context),
                            ),
                          ),

                          // Optional: Add a "+X more" text if there are many items
                          if (items.length > 3)
                            Padding(
                              padding:
                                  EdgeInsets.only(left: Dimensions.width10),
                              child: Text(
                                '+${items.length - 3} more',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 / 1.3,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                  ],
                ),
                SizedBox(height: Dimensions.width10),

                // Address Section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width:
                        double.infinity, // Ensures it takes full width safely
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width15,
                      vertical: Dimensions.height20 * 1.1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radius15 / 2),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: Dimensions.width10 / 2),
                        Flexible(
                          // Prevent text overflow
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.3,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Items and Price Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Items count
                      Text(
                        'Items ${items.length}',
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.2,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400, // Lighter weight
                          fontFamily: 'Poppins',
                        ),
                      ),

                      // Price - same font weight as orderId
                      SmallBlackText(
                        size: Dimensions.font20 / 1.1,
                        font: 'Poppins',
                        text: 'R$totalAmount,00',
                        fontWeight: FontWeight.w600, // Same as orderId
                      ),
                    ],
                  ),
                ),

                // Track Order Button
                SaveButton(
                  isActive: true,
                  description: 'View',
                  isAuthScreen: false,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStackedImages(List<dynamic> items, BuildContext context) {
    final List<Widget> stackedWidgets = [];
    final int displayCount = items.length > 3 ? 3 : items.length;

    for (int i = 0; i < displayCount; i++) {
      final item = items[i];
      final imageUrl = _getItemImage(item);

      // Calculate offset for stacking effect
      final double offset = i * 12.0; // Adjust this value for more/less overlap

      stackedWidgets.add(
        Positioned(
          left: offset,
          child: GestureDetector(
            onTap: () {
              _showFullImageList(context, items);
            },
            child: Transform.rotate(
              angle: i == 0
                  ? 0
                  : (i % 2 == 0 ? -0.05 : 0.05), // Slight rotation for realism
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(1, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null
                      ? Image.asset(
                          imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.shopping_bag,
                                size: 24,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.shopping_bag,
                            size: 24,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return stackedWidgets;
  }

// Helper method to get image from individual item
  String? _getItemImage(dynamic item) {
    try {
      if (item is Map<String, dynamic>) {
        return item['image'] as String? ??
            item['img'] as String? ??
            item['imageUrl'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

// Method to show full horizontal image list
  void _showFullImageList(BuildContext context, List<dynamic> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        padding: EdgeInsets.all(Dimensions.width20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // Title
            Text(
              'Order Items',
              style: TextStyle(
                fontSize: Dimensions.font16 * 1.1,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // Horizontal scrollable images
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final imageUrl = _getItemImage(item);
                  final itemName = _getItemName(item);

                  return Container(
                    width: 80,
                    margin: EdgeInsets.only(right: Dimensions.width15),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: imageUrl != null
                              ? Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.shopping_bag,
                                      size: 24,
                                      color: Colors.grey.shade400,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.shopping_bag,
                                  size: 24,
                                  color: Colors.grey.shade400,
                                ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          itemName,
                          style: TextStyle(
                            fontSize: Dimensions.font16 / 1.3,
                            color: Colors.grey.shade700,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper to get item name
  String _getItemName(dynamic item) {
    try {
      if (item is Map<String, dynamic>) {
        return item['name']?.toString() ?? 'Item';
      }
      return 'Item';
    } catch (e) {
      return 'Item';
    }
  }

  Padding buildThumbnail(String? imageUrl) {
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width10, top: Dimensions.height10 / 2),
      child: Container(
        height: Dimensions.height45 * 1.1,
        width: Dimensions.width30 * 2.3,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius20 / 2),
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: imageUrl != null
            ? Image.asset(
                imageUrl,
                width: 30.0,
                height: 30.0,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.shopping_bag, size: 24);
                },
              )
            : Icon(Icons.shopping_bag, size: 24),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'in_progress':
      case 'processing':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        statusText = 'In Progress';
        break;
      case 'pending':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        statusText = 'Pending';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: Dimensions.font16 / 1.4,
          color: textColor,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return DateFormat('MMM dd, yyyy').format(date);
      } else if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return DateFormat('MMM dd, yyyy').format(date);
      }
      return 'Unknown date';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String? _getFirstItemImage(Map<String, dynamic> order) {
    try {
      final items = order['items'] as List<dynamic>?;

      if (items != null && items.isNotEmpty) {
        final firstItem = items.first;

        if (firstItem is Map<String, dynamic>) {
          return firstItem['image'] as String? ??
              firstItem['img'] as String? ??
              firstItem['imageUrl'] as String?;
        }
      }

      return null;
    } catch (e) {
      print('Error getting first item image: $e');
      return null;
    }
  }

  // Address Helper Method
  String _getAddress(Map<String, dynamic> order) {
    try {
      final deliveryAddress = order['deliveryAddress'] as Map<String, dynamic>?;

      if (deliveryAddress == null) {
        return 'Address not available';
      }

      final street = deliveryAddress['street']?.toString() ?? '';
      final suburb = deliveryAddress['suburb']?.toString() ?? '';

      // Check if street has more than 5 characters
      if (street.length > 20) {
        return street;
      } else {
        // Use both street and suburb
        if (street.isNotEmpty && suburb.isNotEmpty) {
          return '$street, $suburb';
        } else if (street.isNotEmpty) {
          return street;
        } else if (suburb.isNotEmpty) {
          return suburb;
        } else {
          return 'Address not specified';
        }
      }
    } catch (e) {
      print('Error getting address: $e');
      return 'Address unavailable';
    }
  }
}
