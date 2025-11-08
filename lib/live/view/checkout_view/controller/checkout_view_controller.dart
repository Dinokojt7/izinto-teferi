import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../controllers/new_cart_controller.dart';

class CheckoutViewController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Primary state
  bool _isLoadingIndicator = false;
  bool get isLoadingIndicator => _isLoadingIndicator;

  // Delivery instructions
  bool _shouldLeaveAtTheDoor = false;
  bool get shouldLeaveAtTheDoor => _shouldLeaveAtTheDoor;

  bool _isBellAllowed = false;
  bool get isBellAllowed => _isBellAllowed;

  bool _shouldCallWhenArrive = false;
  bool get shouldCallWhenArrive => _shouldCallWhenArrive;

  // Service Tip
  int _selectedTipIndex = -1;
  int get selectedTipIndex => _selectedTipIndex;

  final List<Map<String, dynamic>> _tipOptions = [
    {'amount': 10, 'image': 'assets/image/lollipop.png', 'text': 'R10'},
    {'amount': 15, 'image': 'assets/image/hot-tea.png', 'text': 'R15'},
    {'amount': 20, 'image': 'assets/image/beer.png', 'text': 'R20'},
    {'amount': 25, 'image': 'assets/image/mai-thai.png', 'text': 'R25'},
    {'amount': 30, 'image': 'assets/image/waffle.png', 'text': 'R30'},
    {'amount': 40, 'image': 'assets/image/pizza.png', 'text': 'R40'},
    {'amount': 50, 'image': 'assets/image/coffee-bag.png', 'text': 'R50'},
  ];

  List<Map<String, dynamic>> get tipOptions => _tipOptions;
  int get selectedTipAmount =>
      _selectedTipIndex >= 0 ? _tipOptions[_selectedTipIndex]['amount'] : 0;

  // Payment Method
  String _selectedPaymentMethod = '';
  String get selectedPaymentMethod => _selectedPaymentMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'yoco',
      'name': 'Yoco Payment Link',
      'image': 'assets/image/yoco-payment-link.png',
      'description': 'Secure online payment'
    },
    {
      'type': 'cash',
      'name': 'Cash Payment',
      'image': 'assets/image/cash-payments.png',
      'description': 'Pay with cash on delivery'
    },
    {
      'type': 'card',
      'name': 'Card Payment',
      'image': 'assets/image/card-payments.png',
      'description': 'Pay with card'
    },
    {
      'type': 'eft',
      'name': 'EFT Payment',
      'image': 'assets/image/eft-payment.png',
      'description': 'Electronic Funds Transfer'
    },
  ];

  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;

  // Delivery notes
  String _deliveryNote = 'Any other delivery notes? Add them here!';
  String get deliveryNote => _deliveryNote;

  TextEditingController deliveryNotesController = TextEditingController();

  // Order summary (dynamic)
  int get orderSubtotal {
    final cartController = Get.find<NewCartController>();
    return cartController.totalAmount;
  }

  int get serviceFee => 35; // Fixed service fee
  int get optionalTip => selectedTipAmount;

  int get orderTotal => orderSubtotal + serviceFee + optionalTip;
  bool get isFreeDelivery => true;

  // Methods
  void toggleLeaveAtDoor(bool value) {
    _shouldLeaveAtTheDoor = value;
    notifyListeners();
  }

  void toggleBellAllowed(bool value) {
    _isBellAllowed = value;
    notifyListeners();
  }

  void toggleCallWhenArrive(bool value) {
    _shouldCallWhenArrive = value;
    notifyListeners();
  }

  void selectTip(int index) {
    if (_selectedTipIndex == index) {
      // Tapping the same tip - deselect it
      _selectedTipIndex = -1;
    } else {
      // Select new tip
      _selectedTipIndex = index;
    }
    notifyListeners();
  }

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void updateDeliveryNote(String note) {
    _deliveryNote = note;
    notifyListeners();
  }

  // Order Processing
  Future<Map<String, dynamic>> createOrderObject(
      Map<String, dynamic> address) async {
    final cartController = Get.find<NewCartController>();
    final user = _auth.currentUser;

    if (user == null) throw Exception('User not authenticated');

    final orderId = _firestore.collection('orders').doc().id;
    final timestamp = FieldValue.serverTimestamp();

    // Build delivery instructions
    final deliveryInstructions = {
      'leaveAtDoor': _shouldLeaveAtTheDoor,
      'dontRingBell': _isBellAllowed,
      'callWhenArrive': _shouldCallWhenArrive,
      'additionalNotes': _deliveryNote,
    };

    // Build order object
    final order = {
      'orderId': orderId,
      'userId': user.uid,
      'userEmail': user.email,
      'status': 'pending',
      'createdAt': timestamp,
      'updatedAt': timestamp,

      // Order details
      'items': cartController.getItems.map((item) => item.toJson()).toList(),
      'subtotal': orderSubtotal,
      'serviceFee': serviceFee,
      'tipAmount': optionalTip,
      'totalAmount': orderTotal,

      // Delivery information
      'deliveryAddress': address,
      'deliveryInstructions': deliveryInstructions,

      // Payment information
      'paymentMethod': _selectedPaymentMethod,
      'paymentStatus': 'pending',

      // Service information
      'serviceTypes': _getServiceTypes(cartController.getItems),
    };

    return order;
  }

  List<String> _getServiceTypes(List<dynamic> items) {
    final types = <String>{};
    for (final item in items) {
      if (item.type != null) {
        types.add(item.type);
      }
    }
    return types.toList();
  }

  Future<void> submitOrder(Map<String, dynamic> address) async {
    try {
      _isLoadingIndicator = true;
      notifyListeners();

      final order = await createOrderObject(address);

      // Save to Firestore
      await _firestore.collection('orders').doc(order['orderId']).set(order);

      // Also save to user's orders subcollection
      final user = _auth.currentUser;
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('orders')
          .doc(order['orderId'])
          .set(order);

      // Clear cart after successful order
      final cartController = Get.find<NewCartController>();
      cartController.clear();

      _isLoadingIndicator = false;
      notifyListeners();
    } catch (error) {
      _isLoadingIndicator = false;
      notifyListeners();
      throw error;
    }
  }

  bool get isFormValid {
    return _selectedPaymentMethod.isNotEmpty;
  }

  @override
  void dispose() {
    deliveryNotesController.dispose();
    super.dispose();
  }
}
