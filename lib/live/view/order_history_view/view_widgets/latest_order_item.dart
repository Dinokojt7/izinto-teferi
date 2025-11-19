import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../utils/dimensions.dart';
import '../../../utilities/service_type_utils.dart';
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
    final totalAmount = order['totalAmount'] ?? 0;
    final status = order['status'] ?? 'pending';
    final orderId = order['orderId'] ?? 'N/A';
    final items = order['items'] ?? [];
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
                SizedBox(height: Dimensions.height10),

                // Image and Service Type Row
                _buildImageAndServiceTypeRow(items),
                SizedBox(height: Dimensions.width10),

                // Address Section
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
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
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      // Price
                      SmallBlackText(
                        size: Dimensions.font20 / 1.1,
                        font: 'Poppins',
                        text: 'R$totalAmount,00',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),

                // View Button
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

  // New method for image and service type row
  Widget _buildImageAndServiceTypeRow(List<dynamic> items) {
    final serviceTypes = _getAllServiceTypes(items);
    final displayText = serviceTypes.join(', ');

    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stacked service type images
          Container(
            width: 120,
            child: Stack(
              children: _buildServiceTypeImages(serviceTypes),
            ),
          ),

          SizedBox(width: Dimensions.width15),

          // Service types text
          Expanded(
            child: Text(
              displayText.isNotEmpty ? displayText : 'Various Services',
              style: TextStyle(
                fontSize: Dimensions.font16 / 1.3,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: Colors.black,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Show "+X more" if there are many service types
          if (serviceTypes.length > 3)
            Padding(
              padding: EdgeInsets.only(left: Dimensions.width10),
              child: Text(
                '+${serviceTypes.length - 3} more',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.4,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Get all service types from items
  List<String> _getAllServiceTypes(List<dynamic> items) {
    final Set<String> serviceTypes = {};

    for (final item in items) {
      try {
        if (item is Map<String, dynamic>) {
          final provider = item['provider']?.toString();
          if (provider != null && provider.isNotEmpty) {
            final serviceType =
                ServiceTypeUtils.getServiceTypeFromProvider(provider);
            if (serviceType.isNotEmpty) {
              serviceTypes.add(serviceType);
            }
          }
        }
      } catch (e) {

      }
    }

    return serviceTypes.toList();
  }

  // Build service type images
  List<Widget> _buildServiceTypeImages(List<String> serviceTypes) {
    final List<Widget> stackedWidgets = [];
    final int displayCount = serviceTypes.length > 3 ? 3 : serviceTypes.length;

    for (int i = 0; i < displayCount; i++) {
      final serviceType = serviceTypes[i];
      final imagePath = ServiceTypeUtils.getServiceTypeImage(serviceType);
      final double offset = i * 15.0;

      stackedWidgets.add(
        Positioned(
          left: offset,
          child: Container(
            width: 50,
            height: 50,
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
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.category,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    // If no service types found, show a default placeholder
    if (stackedWidgets.isEmpty) {
      stackedWidgets.add(
        Positioned(
          left: 0,
          child: Container(
            width: 50,
            height: 50,
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
            child: Icon(
              Icons.shopping_bag,
              size: 24,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      );
    }

    return stackedWidgets;
  }

  // Original stacked images method (kept for reference but not used in new layout)
  List<Widget> _buildStackedImages(List<dynamic> items, BuildContext context) {
    final List<Widget> stackedWidgets = [];
    final int displayCount = items.length > 3 ? 3 : items.length;

    for (int i = 0; i < displayCount; i++) {
      final item = items[i];
      final imageUrl = _getItemImage(item);
      final double offset = i * 12.0;

      stackedWidgets.add(
        Positioned(
          left: offset,
          child: GestureDetector(
            onTap: () {
              _showFullImageList(context, items);
            },
            child: Transform.rotate(
              angle: i == 0 ? 0 : (i % 2 == 0 ? -0.05 : 0.05),
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Order Items',
              style: TextStyle(
                fontSize: Dimensions.font16 * 1.1,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: Dimensions.height20),
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

      return null;
    }
  }

  String _getAddress(Map<String, dynamic> order) {
    try {
      final deliveryAddress = order['deliveryAddress'] as Map<String, dynamic>?;
      if (deliveryAddress == null) {
        return 'Address not available';
      }
      final street = deliveryAddress['street']?.toString() ?? '';
      final suburb = deliveryAddress['suburb']?.toString() ?? '';
      if (street.length > 20) {
        return street;
      } else {
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

      return 'Address unavailable';
    }
  }
}
