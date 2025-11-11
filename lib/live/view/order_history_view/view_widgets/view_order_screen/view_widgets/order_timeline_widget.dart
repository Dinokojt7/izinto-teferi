// order_timeline_widget.dart
import 'package:flutter/material.dart';
import 'package:izinto/models/user.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// order_timeline_widget.dart
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../utilities/colors.dart';

class OrderTimelineWidget extends StatefulWidget {
  final String serviceType;
  final DateTime createdAt;
  final String? itemTime;
  final String orderId;
  final Map<String, dynamic> order;

  const OrderTimelineWidget({
    Key? key,
    required this.serviceType,
    required this.createdAt,
    required this.itemTime,
    required this.orderId,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderTimelineWidget> createState() => _OrderTimelineWidgetState();
}

class _OrderTimelineWidgetState extends State<OrderTimelineWidget> {
  late String _currentStatus;
  late DateTime _fulfilledTime;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order['status'] ?? 'pending';
    _fulfilledTime = _calculateFulfilledTime(
        DateTime.now(), widget.serviceType, widget.itemTime);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_getCurrentUserId())
          .collection('orders')
          .doc(widget.orderId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final orderData = snapshot.data!.data() as Map<String, dynamic>?;
          if (orderData != null) {
            _currentStatus = orderData['status'] ?? 'pending';

            // Update fulfilled time if status changed
            if (_currentStatus == 'completed' ||
                _currentStatus == 'fulfilled') {
              final completedAt = _parseTimestamp(orderData['completedAt']);
              if (completedAt != null) {
                _fulfilledTime = completedAt;
              }
            }
          }
        }

        return Container(
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 0.7,
                offset: Offset(0, 1.7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Dimensions.height20),
              _buildVerticalTimeline(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalTimeline() {
    final now = DateTime.now();
    final isPending = _currentStatus == 'pending';
    final isInProgress =
        _currentStatus == 'in_progress' || _currentStatus == 'processing';
    final isCompleted =
        _currentStatus == 'completed' || _currentStatus == 'fulfilled';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dots and connectors (vertical)
        Column(
          children: [
            _buildTimelineDot(true, LiveColors.accent), // Pending - blue
            _buildVerticalConnector(true),
            _buildTimelineDot(isInProgress || isCompleted,
                isInProgress ? LiveColors.accent : LiveColors.accent),
            _buildVerticalConnector(isCompleted),
            _buildTimelineDot(
                isCompleted,
                isCompleted
                    ? LiveColors.accent
                    : Colors.grey.shade400), // Fulfilled - light grey
          ],
        ),
        SizedBox(width: Dimensions.width15),

        // Timeline content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineStep(
                status: 'Pending',
                description: 'Order received and confirmed',
                time: widget.createdAt,
                isCompleted: true,
                isActive: false,
                statusColor: LiveColors.accent, // Blue text for pending
              ),
              SizedBox(height: Dimensions.height20),
              _buildTimelineStep(
                status: 'In Progress',
                description: _getInProgressDescription(),
                time: isInProgress ? now : _calculateInProgressTime(),
                isCompleted: isInProgress || isCompleted,
                isActive: isInProgress,
                statusColor: isInProgress
                    ? LiveColors.accent
                    : Colors.grey.shade700, // Orange when active
              ),
              SizedBox(height: Dimensions.height20),
              _buildTimelineStep(
                status: 'Fulfilled',
                description: _getFulfilledDescription(),
                time: _fulfilledTime,
                isCompleted: isCompleted,
                isActive: false,
                statusColor: isCompleted
                    ? LiveColors.accent
                    : Colors.grey.shade600, // Light grey for fulfilled
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDot(bool isCompleted, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? color : Colors.transparent,
        border: Border.all(
          color: LiveColors.accent,
          width: 2,
        ),
      ),
      child: isCompleted
          ? Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildVerticalConnector(bool isCompleted) {
    return Container(
      width: 2,
      height: 60,
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? LiveColors.accent
            : Colors.grey.shade300, // Blue connector
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String status,
    required String description,
    required DateTime time,
    required bool isCompleted,
    required bool isActive,
    required Color statusColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status,
          style: TextStyle(
            fontSize: Dimensions.font16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: statusColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: Dimensions.font16 / 1.3,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 4),
        Text(
          _formatDetailedTime(time),
          style: TextStyle(
            fontSize: Dimensions.font16 / 1.4,
            fontWeight: FontWeight.w500,
            color: statusColor,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  DateTime _calculateFulfilledTime(
      DateTime now, String serviceType, String? itemTime) {
    if (serviceType == 'Laundry') {
      return now.add(Duration(hours: 24));
    } else if (now.hour >= 18) {
      final tomorrow = now.add(Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8);
    } else if (itemTime == '30 min' || itemTime == '45 min') {
      return now.add(Duration(hours: 1));
    } else {
      return now.add(Duration(hours: 2));
    }
  }

  DateTime _calculateInProgressTime() {
    // In Progress typically starts shortly after order creation
    return widget.createdAt.add(Duration(minutes: 15));
  }

  String _getInProgressDescription() {
    if (_currentStatus == 'in_progress' || _currentStatus == 'processing') {
      return 'Service provider is working on your order';
    } else if (_currentStatus == 'completed' || _currentStatus == 'fulfilled') {
      return 'Service was completed';
    }
    return 'Service will start soon';
  }

  String _getFulfilledDescription() {
    if (_currentStatus == 'completed' || _currentStatus == 'fulfilled') {
      return 'Service completed successfully';
    }
    return 'Estimated completion time';
  }

  String _formatDetailedTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • h:mm a').format(dateTime);
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        return timestamp;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getCurrentUserId() {
    final user = Provider.of<UserModel>(context);
    String userId = user.uid;
    return userId;
  }
}
