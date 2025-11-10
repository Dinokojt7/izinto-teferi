// view_order_screen.dart
import 'package:flutter/material.dart';
import 'package:izinto/live/view/order_history_view/view_widgets/view_order_screen/view_widgets/order_timeline_widget.dart';
import 'package:izinto/live/view/order_history_view/view_widgets/view_order_screen/view_widgets/service_type_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../auxiliery_classes/generic_app_bar.dart';
import '../../../../utilities/generic_system_navigation.dart';
import '../../../../utilities/service_type_utils.dart';
import '../../../home_view/controller/home_view_controller.dart';

class ViewOrderScreen extends StatefulWidget {
  final String orderNumber;
  final Map<String, dynamic> order;
  final bool isFromCheckout;
  const ViewOrderScreen({
    Key? key,
    required this.orderNumber,
    required this.order,
    this.isFromCheckout = false,
  }) : super(key: key);

  @override
  State<ViewOrderScreen> createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrderScreen> {
  String _selectedServiceType = '';
  List<String> _serviceTypes = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.white, Brightness.dark, Colors.white, Brightness.dark);
    });
    _initializeServiceTypes();
  }

  void _initializeServiceTypes() {
    _serviceTypes = ServiceTypeUtils.getAllServiceTypesFromOrder(widget.order);
    if (_serviceTypes.isNotEmpty) {
      _selectedServiceType = _serviceTypes.first;
    }
  }

  void _applySystemChromeSettings() {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);
  }

  void _handleBackNavigation() {
    _applySystemChromeSettings();
    Navigator.of(context).pop();
  }

  void _onServiceTypeChanged(String serviceType) {
    setState(() {
      _selectedServiceType = serviceType;
    });
  }

  void _showDetailsBottomSheet() {
    showModalBottomSheet(
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
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: Dimensions.height10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Order header
                Row(
                  children: [
                    // Stacked images for order
                    Container(
                      width: 60,
                      height: 60,
                      child: _buildServiceTypeImageStack(),
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${widget.order['orderId'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: Dimensions.font16 * 1.2,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4),
                          _buildStatusBadge(
                              widget.order['status'] ?? 'pending'),
                          SizedBox(height: 8),
                          // Service provider display
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getServiceProviderDisplay(),
                              style: TextStyle(
                                fontSize: Dimensions.font16 / 1.3,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                                fontFamily: 'Poppins',
                              ),
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
                        // Service Items Section
                        _buildServiceItemsSection(),
                        SizedBox(height: Dimensions.height20),

                        // Delivery address
                        _buildDetailSection(
                          title: 'Delivery Address',
                          content: _buildAddressContent(),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Delivery instructions
                        if (_hasDeliveryInstructions())
                          _buildDetailSection(
                            title: 'Delivery Instructions',
                            content: _buildInstructionsContent(),
                          ),

                        if (_hasDeliveryInstructions())
                          SizedBox(height: Dimensions.height20),

                        // Payment method
                        _buildDetailSection(
                          title: 'Payment',
                          content: Text(
                            _getPaymentMethodDisplayName(
                                widget.order['paymentMethod'] ?? 'Unknown'),
                            style: TextStyle(
                              fontSize: Dimensions.font16 / 1.1,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Support FAB for pending orders only
          if (_shouldShowSupportFab())
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  _openSupportChat(context, widget.order);
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

  @override
  Widget build(BuildContext context) {
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (widget.isFromCheckout) {
            _applySystemChromeSettings();
            homeViewController.changeIndex(0, false);
          } else {
            _applySystemChromeSettings();
            Navigator.of(context).pop();
          }
        } else {
          _applySystemChromeSettings();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.97),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              GenericAppBar(
                removeLeading: widget.isFromCheckout,
                onTap: _handleBackNavigation,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                heading: widget.orderNumber,
              ),
              SizedBox(
                height: Dimensions.height10,
              ),

              // Service Type Dropdown with View Details - Split layout
              ServiceTypeDropdown(
                serviceTypes: _serviceTypes,
                selectedServiceType: _selectedServiceType,
                onServiceTypeChanged: _onServiceTypeChanged,
                order: widget.order,
                onViewDetails: _showDetailsBottomSheet,
              ),
              SizedBox(
                height: Dimensions.height10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Vacuuming Image
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        margin: EdgeInsets.symmetric(
                          horizontal: Dimensions.width30,
                          vertical: Dimensions.height20,
                        ),
                        child: Image.asset(
                          'assets/image/vacuuming.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.shopping_bag,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: Dimensions.bottomHeightBar / 2,
                      ),
                      // Order Timeline
                      _buildOrderTimeline(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for bottom sheet content
  Widget _buildServiceTypeImageStack() {
    final items = _getSafeItemsList(_selectedServiceType);
    final displayCount = items.length > 3 ? 3 : items.length;

    return Stack(
      children: List.generate(displayCount, (index) {
        final item = items[index];
        final imageUrl = _getItemImage(item);
        final double offset = index * 15.0;

        return Positioned(
          left: offset,
          child: Container(
            width: 40,
            height: 40,
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
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shopping_bag,
                          size: 20,
                          color: Colors.grey.shade400,
                        );
                      },
                    )
                  : Icon(
                      Icons.shopping_bag,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
            ),
          ),
        );
      }),
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

  String _getServiceProviderDisplay() {
    final items = _getSafeItemsList(_selectedServiceType);
    if (items.isEmpty) return 'Izinto';

    final providers = items.map((item) {
      final provider = item['provider']?.toString();
      return ServiceTypeUtils.getProviderDisplayName(provider);
    }).toSet();

    return providers.join(', ');
  }

  Widget _buildServiceItemsSection() {
    final items = _getSafeItemsList(_selectedServiceType);
    final collectivePrice = ServiceTypeUtils.calculateServiceTypeTotal(items);

    return _buildDetailSection(
      title: 'Items (${items.length})',
      content: Column(
        children: [
          ...items
              .map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _getItemImage(item) != null
                              ? Image.asset(
                                  _getItemImage(item)!,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.shopping_bag,
                                  color: Colors.grey.shade400),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Unknown Item',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 / 1.1,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    'R${_calculateItemTotal(item)},00',
                                    style: TextStyle(
                                      fontSize: Dimensions.font16 / 1.2,
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(width: Dimensions.width10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getTimeColor(
                                          item['time']?.toString()),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item['time']?.toString() ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: Dimensions.font16 / 1.4,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          SizedBox(height: Dimensions.height10),
          Container(
            padding: EdgeInsets.all(Dimensions.width15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total for ${_selectedServiceType}',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'R${collectivePrice.toStringAsFixed(0)},00',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 1.1,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimeColor(String? time) {
    if (time == '30 min' || time == '45 min') {
      return Colors.orange;
    }
    return Colors.grey.shade600;
  }

  Widget _buildAddressContent() {
    final deliveryAddress = widget.order['deliveryAddress'] ?? {};
    return Column(
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
    );
  }

  bool _hasDeliveryInstructions() {
    final instructions = widget.order['deliveryInstructions'] ?? {};
    return instructions.isNotEmpty;
  }

  Widget _buildInstructionsContent() {
    final instructions = widget.order['deliveryInstructions'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (instructions['leaveAtDoor'] == true)
          _buildInstructionItem('Leave at door'),
        if (instructions['dontRingBell'] == true)
          _buildInstructionItem("Don't ring bell"),
        if (instructions['callWhenArrive'] == true)
          _buildInstructionItem('Call when arriving'),
        if (instructions['additionalNotes'] != null &&
            instructions['additionalNotes'].isNotEmpty)
          Text(
            instructions['additionalNotes'],
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.1,
              fontFamily: 'Poppins',
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildInstructionItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 16),
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
      ],
    );
  }

  bool _shouldShowSupportFab() {
    final status = widget.order['status']?.toString().toLowerCase() ?? '';
    return status == 'pending' ||
        status == 'in_progress' ||
        status == 'processing';
  }

// In ViewOrderScreen, update the _buildOrderTimeline method:
  Widget _buildOrderTimeline() {
    try {
      final createdAt = _parseOrderTimestamp(widget.order['createdAt']);
      final items = _getSafeItemsList(_selectedServiceType);
      final firstItemTime =
          items.isNotEmpty ? items.first['time']?.toString() : null;
      final orderId = widget.order['orderId'] ?? widget.order['id'] ?? 'N/A';

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: OrderTimelineWidget(
          serviceType: _selectedServiceType,
          createdAt: createdAt,
          itemTime: firstItemTime,
          orderId: orderId,
          order: widget.order,
        ),
      );
    } catch (e) {
      print('Timeline build error: $e');
      return Container(
        padding: EdgeInsets.all(Dimensions.height20),
        child: Text(
          'Unable to load timeline',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: Dimensions.font16,
          ),
        ),
      );
    }
  }

  // Helper methods
  List<Map<String, dynamic>> _getSafeItemsList(String serviceType) {
    try {
      return ServiceTypeUtils.getItemsByServiceType(widget.order, serviceType);
    } catch (e) {
      print('Error getting items list: $e');
      return [];
    }
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

  String _calculateItemTotal(Map<String, dynamic> item) {
    final price = (item['price'] ?? 0).toDouble();
    final quantity = (item['quantity'] ?? 1).toInt();
    return (price * quantity).toStringAsFixed(0);
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

  DateTime _parseOrderTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        return timestamp;
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  void _openSupportChat(BuildContext context, Map<String, dynamic> order) {
    // Implement support chat navigation
    print('Opening support chat for order: ${order['orderId']}');
  }
}
