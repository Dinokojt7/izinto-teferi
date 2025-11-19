// Updated OrderHistoryItem.dart
import 'package:flutter/material.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/view/order_history_view/view_widgets/view_order_screen/view_order_screen.dart';
import 'package:izinto/live/view/order_history_view/view_widgets/view_order_screen/view_widgets/service_type_row.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../../widgets/buttons/save_button.dart';
import '../../../widgets/text_widgets/small_black_text.dart';
import '../../order_support/order_support_chat.dart';

class OrderHistoryItem extends StatefulWidget {
  final Map<String, dynamic> order;
  final int index;
  const OrderHistoryItem({
    super.key,
    required this.order,
    required this.index,
  });

  @override
  State<OrderHistoryItem> createState() => _OrderHistoryItemState();
}

class _OrderHistoryItemState extends State<OrderHistoryItem> {
  bool _isLoading = false;

  // In OrderHistoryItem class
  Future<void> _handleViewButtonPress() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _openOrderDetails(context, widget.order);
    } catch (e) {

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openOrderDetails(
      BuildContext context, Map<String, dynamic> order) async {
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);

    // Navigate to ViewOrderScreen
    homeViewController.onIndependentPageNavigation(
      context,
      ViewOrderScreen(
        order: order,
        orderNumber: order['orderId']?.toString() ?? 'N/A',
        isFromCheckout: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.order['totalAmount'] ?? 0;
    final status = widget.order['status'] ?? 'pending';
    final createdAt = widget.order['createdAt'] != null
        ? _formatTimestamp(widget.order['createdAt'])
        : 'Unknown date';
    final orderId = widget.order['orderId'] ?? 'N/A';
    final items = widget.order['items'] ?? [];
    final serviceTypes = widget.order['serviceTypes'] ?? [];
    final address = _getAddress(widget.order);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        child: Container(
          height: Dimensions.screenHeight / 4,
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
                horizontal: Dimensions.width30, vertical: Dimensions.height20),
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
                SizedBox(height: Dimensions.height10 / 2),

                // Address Section - Reduced height
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width15,
                      vertical: Dimensions.height10, // Reduced vertical padding
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
                          size: 14, // Slightly smaller icon
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: Dimensions.width10 / 2),
                        Flexible(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.4, // Smaller font
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: Dimensions.height10 / 2),

                // Image, item service provider and view button
                ServiceTypeRow(
                  items: items,
                  status: status,
                  onTap: _handleViewButtonPress,
                  isLoading: _isLoading,
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

      final double offset = i * 12.0;

      stackedWidgets.add(
        Positioned(
          left: offset,
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

  // Address Helper Method
  String _getAddress(Map<String, dynamic> order) {
    try {
      final deliveryAddress = order['deliveryAddress'] as Map<String, dynamic>?;

      if (deliveryAddress == null) {
        return 'Address not available';
      }

      final street = deliveryAddress['street']?.toString() ?? '';
      final suburb = deliveryAddress['suburb']?.toString() ?? '';

      if (street.length > 5) {
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

  // Updated order details modal with support FAB
  Future<void> _showOrderDetails(
      BuildContext context, Map<String, dynamic> order) async {
    final items = order['items'] ?? [];
    final deliveryAddress = order['deliveryAddress'] ?? {};
    final deliveryInstructions = order['deliveryInstructions'] ?? {};
    final paymentMethod = order['paymentMethod'] ?? 'Unknown';
    final status = order['status'] ?? 'pending';
    final orderId = order['orderId'] ?? 'N/A';
    final totalAmount = order['totalAmount'] ?? 0;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Stack(
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

                // Order header
                Row(
                  children: [
                    // Stacked images for order
                    Container(
                      width: 80,
                      height: 80,
                      child: Stack(
                        children: _buildStackedImages(items, context),
                      ),
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #$orderId',
                            style: TextStyle(
                              fontSize: Dimensions.font16 * 1.2,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4),
                          _buildStatusBadge(status),
                          SizedBox(height: 8),
                          Text(
                            'R$totalAmount,00',
                            style: TextStyle(
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),

                // Order details sections
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Items section
                        _buildDetailSection(
                          title: 'Items (${items.length})',
                          content: Column(
                            children: items
                                .map<Widget>((item) => Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          // Item image
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                            ),
                                            child: _getItemImage(item) != null
                                                ? Image.asset(
                                                    _getItemImage(item)!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Icon(
                                                        Icons.shopping_bag,
                                                        size: 20,
                                                        color: Colors
                                                            .grey.shade400,
                                                      );
                                                    },
                                                  )
                                                : Icon(
                                                    Icons.shopping_bag,
                                                    size: 20,
                                                    color: Colors.grey.shade400,
                                                  ),
                                          ),
                                          SizedBox(width: Dimensions.width10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['name'] ??
                                                      'Unknown Item',
                                                  style: TextStyle(
                                                    fontSize:
                                                        Dimensions.font16 / 1.1,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  'R${item['price'] ?? 0},00',
                                                  style: TextStyle(
                                                    fontSize:
                                                        Dimensions.font16 / 1.2,
                                                    color: Colors.grey.shade600,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),

                        SizedBox(height: Dimensions.height20),

                        // Delivery address
                        _buildDetailSection(
                          title: 'Delivery Address',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (deliveryAddress['street'] != null)
                                Text(
                                  deliveryAddress['street'],
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 / 1.1,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              if (deliveryAddress['suburb'] != null)
                                Text(
                                  deliveryAddress['suburb'],
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 / 1.1,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              if (deliveryAddress['zip'] != null)
                                Text(
                                  deliveryAddress['zip'],
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 / 1.1,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: Dimensions.height20),

                        // Delivery instructions
                        if (deliveryInstructions.isNotEmpty)
                          _buildDetailSection(
                            title: 'Delivery Instructions',
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (deliveryInstructions['leaveAtDoor'] == true)
                                  _buildInstructionItem('Leave at door'),
                                if (deliveryInstructions['dontRingBell'] ==
                                    true)
                                  _buildInstructionItem("Don't ring bell"),
                                if (deliveryInstructions['callWhenArrive'] ==
                                    true)
                                  _buildInstructionItem('Call when arriving'),
                                if (deliveryInstructions['additionalNotes'] !=
                                        null &&
                                    deliveryInstructions['additionalNotes']
                                        .isNotEmpty)
                                  Text(
                                    deliveryInstructions['additionalNotes'],
                                    style: TextStyle(
                                      fontSize: Dimensions.font16 / 1.1,
                                      fontFamily: 'Poppins',
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        SizedBox(height: Dimensions.height20),

                        // Payment method
                        _buildDetailSection(
                          title: 'Payment',
                          content: Text(
                            _getPaymentMethodDisplayName(paymentMethod),
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.1,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Support FAB for pending orders only
          if (status.toLowerCase() == 'pending' ||
              status.toLowerCase() == 'in_progress' ||
              status.toLowerCase() == 'processing')
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  _openSupportChat(context, order);
                },
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 56,
                  height: 56,
                  child: Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Dimensions.font16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        content,
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInstructionItem(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: LiveColors.standardBlue,
          size: 16,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: Dimensions.font16 / 1.1,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'yoco':
        return 'Yoco Payment Link';
      case 'cash':
        return 'Cash on Delivery';
      case 'card':
        return 'Card Payment';
      case 'eft':
        return 'EFT Payment';
      default:
        return method;
    }
  }

  void _openSupportChat(BuildContext context, Map<String, dynamic> order) {
    Navigator.of(context).pop(); // Close the bottom sheet first
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    // Navigate to support chat
    homeViewController.onIndependentPageNavigation(
      context,
      OrderSupportChat(order: order),
    );
  }
}
