// order_history_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadUserOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _orders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      print('Error loading orders: $error');
    }
  }

  // Get the latest non-cancelled order
  Map<String, dynamic>? getLatestOrder() {
    if (_orders.isEmpty) return null;

    // Filter out cancelled orders and sort by createdAt in descending order
    final nonCancelledOrders = _orders.where((order) {
      final status = order['status']?.toString().toLowerCase() ?? '';
      return status != 'cancelled' && status != 'canceled';
    }).toList();

    if (nonCancelledOrders.isEmpty) return null;

    // Sort by createdAt in descending order (newest first)
    nonCancelledOrders.sort((a, b) {
      final aTime = _parseTimestamp(a['createdAt']);
      final bTime = _parseTimestamp(b['createdAt']);
      return bTime.compareTo(aTime);
    });

    return nonCancelledOrders.first;
  }

  // Alternative method: Get the latest order including cancelled ones (if needed elsewhere)
  Map<String, dynamic>? getLatestOrderIncludingCancelled() {
    if (_orders.isEmpty) return null;

    // Sort all orders by createdAt in descending order
    _orders.sort((a, b) {
      final aTime = _parseTimestamp(a['createdAt']);
      final bTime = _parseTimestamp(b['createdAt']);
      return bTime.compareTo(aTime);
    });

    return _orders.first;
  }

  // Helper method to get order status for checking
  String getOrderStatus(Map<String, dynamic> order) {
    return order['status']?.toString().toLowerCase() ?? '';
  }

  // Helper method to check if order is cancelled
  bool isOrderCancelled(Map<String, dynamic> order) {
    final status = getOrderStatus(order);
    return status == 'cancelled' || status == 'canceled';
  }

  // Helper method to parse different timestamp formats
  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return DateTime.now(); // Fallback
  }

  // Additional helper: Get count of non-cancelled orders
  int getNonCancelledOrderCount() {
    return _orders.where((order) => !isOrderCancelled(order)).length;
  }

  // Additional helper: Get only non-cancelled orders
  List<Map<String, dynamic>> getNonCancelledOrders() {
    return _orders.where((order) => !isOrderCancelled(order)).toList();
  }
}
