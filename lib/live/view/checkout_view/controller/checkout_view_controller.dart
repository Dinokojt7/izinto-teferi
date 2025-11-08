import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../controllers/new_cart_controller.dart';
import '../../../../models/new_cart_model.dart';

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
    try {
      final cartController = Get.find<NewCartController>();
      return cartController.totalAmount;
    } catch (e) {
      print('Error getting order subtotal: $e');
      return 0;
    }
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
    try {
      final cartController = Get.find<NewCartController>();
      final user = _auth.currentUser;

      if (user == null) throw Exception('User not authenticated');

      final orderId = _firestore.collection('orders').doc().id;
      final timestamp = FieldValue.serverTimestamp();

      // Convert cart items to serializable format - FIXED
      final List<Map<String, dynamic>> cartItems = [];
      for (final item in cartController.getItems) {
        if (item is NewCartModel) {
          cartItems.add({
            'id': item.id,
            'name': item.name ?? 'Unknown Item',
            'price': item.price ?? 0,
            'quantity': item.quantity ?? 1,
            'type': item.type ?? 'General',
            'image': item.img ?? '',
            'time': item.time ?? DateTime.now().toString(),
          });
        } else {
          // Fallback for any other type
          cartItems.add({
            'id': item.id?.toString() ?? 'unknown',
            'name': item.name?.toString() ?? 'Unknown Item',
            'price': item.price is int ? item.price : 0,
            'quantity': item.quantity is int ? item.quantity : 1,
            'type': item.type?.toString() ?? 'General',
            'image': item.img?.toString() ?? '',
          });
        }
      }

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
        'userEmail': user.email ?? 'No email',
        'status': 'pending',
        'createdAt': timestamp,
        'updatedAt': timestamp,

        // Order details
        'items': cartItems,
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

      print('✅ Order object created successfully: $orderId');
      return order;
    } catch (e) {
      print('❌ Error creating order object: $e');
      rethrow;
    }
  }

  List<String> _getServiceTypes(List<dynamic> items) {
    final types = <String>{};
    for (final item in items) {
      try {
        if (item.type != null) {
          types.add(item.type.toString());
        }
      } catch (e) {
        print('Error getting service type from item: $e');
      }
    }
    return types.toList();
  }

  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> address) async {
    try {
      print('🚀 Starting order submission...');
      _isLoadingIndicator = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated - please log in');
      }

      print('👤 User authenticated: ${user.uid}');

      final order = await createOrderObject(address);
      print('📦 Order object created: ${order['orderId']}');

      // Validate required fields
      if (order['orderId'] == null) {
        throw Exception('Order ID is null');
      }

      // Save to Firestore
      print('💾 Saving to Firestore...');
      await _firestore.collection('orders').doc(order['orderId']).set(order);
      print('✅ Saved to main orders collection');

      // Save to user's orders subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(order['orderId'])
          .set(order);
      print('✅ Saved to user orders subcollection');

      // Clear cart after successful order
      final cartController = Get.find<NewCartController>();
      final cartItemsCount = cartController.getItems.length;
      cartController.clear();
      print('🛒 Cart cleared. Had $cartItemsCount items');

      _isLoadingIndicator = false;
      notifyListeners();

      print('🎉 Order submission completed successfully!');
      return order;
    } catch (error, stackTrace) {
      _isLoadingIndicator = false;
      notifyListeners();
      print('❌ Order submission failed: $error');
      print('📋 Stack trace: $stackTrace');
      rethrow;
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
