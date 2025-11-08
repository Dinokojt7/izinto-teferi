import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/text_widgets/small_black_text.dart';
import '../../checkout_view/view_widgets/generic_white_container.dart';

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
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final totalAmount = order['totalAmount'] ?? 0;
    final status = order['status'] ?? 'pending';
    final createdAt = order['createdAt'] != null
        ? _formatTimestamp(order['createdAt'])
        : 'Unknown date';
    final orderId = order['orderId'] ?? 'N/A';
    final items = order['items'] ?? [];
    final serviceTypes = order['serviceTypes'] ?? [];

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
          leading: _buildOrderImage(serviceTypes),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with price and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmallBlackText(
                    size: Dimensions.font20 / 1.1,
                    font: 'Poppins',
                    text: 'R$totalAmount,00',
                    fontWeight: FontWeight.w600,
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              SizedBox(height: 2),

              // Order ID and date
              Text(
                'Order #$orderId',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.3,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Dimensions.height10 / 2),

              // Service types
              if (serviceTypes.isNotEmpty)
                Text(
                  serviceTypes.join(', '),
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.3,
                    color: Colors.grey.shade600,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              SizedBox(height: Dimensions.height10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date and item count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.3,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.4,
                          color: Colors.grey.shade500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  // Order details link
                  GestureDetector(
                    onTap: () {
                      _showOrderDetails(context, order);
                    },
                    child: SmallBlackText(
                      text: 'Order details',
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
            _showOrderDetails(context, order);
          },
        ),
      ),
    );
  }

  Widget _buildOrderImage(List<dynamic> serviceTypes) {
    // Determine icon based on service types
    IconData icon;
    Color iconColor;

    if (serviceTypes.contains('Laundry')) {
      icon = MdiIcons.washingMachine;
      iconColor = LiveColors.standardBlue;
    } else if (serviceTypes.contains('Car Wash')) {
      icon = MdiIcons.carWash;
      iconColor = Colors.blue.shade600;
    } else if (serviceTypes.contains('Gas Refill')) {
      icon = MdiIcons.gasCylinder;
      iconColor = Colors.orange.shade600;
    } else if (serviceTypes.contains('Home Care')) {
      icon = MdiIcons.home;
      iconColor = Colors.green.shade600;
    } else if (serviceTypes.contains('Pet Care')) {
      icon = MdiIcons.paw;
      iconColor = Colors.brown.shade600;
    } else {
      icon = MdiIcons.packageVariant;
      iconColor = LiveColors.standardBlue;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: iconColor.withOpacity(0.1),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 30,
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

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    final items = order['items'] ?? [];
    final deliveryAddress = order['deliveryAddress'] ?? {};
    final deliveryInstructions = order['deliveryInstructions'] ?? {};
    final paymentMethod = order['paymentMethod'] ?? 'Unknown';
    final status = order['status'] ?? 'pending';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                _buildOrderImage(order['serviceTypes'] ?? []),
                SizedBox(width: Dimensions.width15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['orderId'] ?? 'N/A'}',
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
                        'R${order['totalAmount'] ?? 0},00',
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
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name'] ?? 'Unknown Item',
                                          style: TextStyle(
                                            fontSize: Dimensions.font16 / 1.1,
                                            fontFamily: 'Poppins',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        'R${item['price'] ?? 0},00',
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 / 1.1,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
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
                            if (deliveryInstructions['dontRingBell'] == true)
                              _buildInstructionItem("Don't ring bell"),
                            if (deliveryInstructions['callWhenArrive'] == true)
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
        SizedBox(height: 8),
        content,
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
        return 'Card Payment (PayStack)';
      case 'eft':
        return 'EFT Payment';
      default:
        return method;
    }
  }
}
