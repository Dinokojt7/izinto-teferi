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

  // In OrderHistoryController - Add this method
  Map<String, dynamic>? getLatestOrder() {
    if (_orders.isEmpty) return null;

    // Sort by createdAt in descending order
    _orders.sort((a, b) {
      final aTime = _parseTimestamp(a['createdAt']);
      final bTime = _parseTimestamp(b['createdAt']);
      return bTime.compareTo(aTime); // Newest first
    });

    return _orders.first;
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
}
