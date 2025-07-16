import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutController extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List _chatRoom = [];
  bool _isExpanded = false;
  String _orderId = '';
  int _orderStatus = 0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List get chatRoom => _chatRoom;
  bool get isExpanded => _isExpanded;
  String get orderId => _orderId;
  int get orderStatus => _orderStatus;

  Future<void> toggleExpansion(context) async {
    _isExpanded = !_isExpanded;
    DraggableScrollableActuator.reset(context);
    notifyListeners();
  }

  Future<void> reOrder(int? totalOrderAmount, int itemCount) async {
    // Implement your logic here
    notifyListeners();
  }

  Future<void> sendOrderToDatabase(int? totalOrderAmount, int itemCount,
      List cart, List orderMessages) async {
    DateTime orderTime = DateTime.now();

    ///the next few variables are used to generate random order number
    final String orderNumber = UniqueKey().hashCode.toString();
    final _random = Random();
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final randomLetters = letters[_random.nextInt(letters.length)] +
        letters[_random.nextInt(letters.length)];
    final String orderNumberFormatted =
        randomLetters + orderNumber.substring(orderNumber.length - 5);

    ///we record order time with the value bellow
    String formattedOrderTime = DateFormat('dd MMM hh:mm').format(orderTime);

    User? user = await _firebaseAuth.currentUser;

    /// Convert the list to a map
    List cartItemMaps = cart.map((item) => item.toJson()).toList();
    List chatRoomMaps = _chatRoom.map((item) => item.toJson()).toList();

    _isLoading = true;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Active")
        .doc('current order')
        .set({
      'New order': cartItemMaps,
      'fetched by': '',
      'chat room': chatRoomMaps,
      'total order amount': totalOrderAmount,
      'total item count': itemCount,
      'createdAt': formattedOrderTime,
      'order number': orderNumberFormatted,
      'eta': '',
      'payment type': '',
      'updated delivery slot': '',
      'order status': 0
    });
    notifyListeners();
  }

  Future<void> restrictOrder() async {
    // Implement your logic here
    notifyListeners();
  }

  Future<void> resendToUs(int? totalOrderAmount, int itemCount) async {
    // Implement your logic here
    notifyListeners();
  }

  Future<void> sendOrderToUs(String? totalOrderAmount, int totalItem, List cart,
      List orderMessages, String newOrderNumber) async {
    // Implement your logic here
    notifyListeners();
  }
}
