import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../controllers/new_cart_controller.dart';
import '../../../../models/new_cart_model.dart';
import '../../../../models/new_specialty_model.dart';
import '../../../../services/notification_service.dart';

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
  // Add this method to CheckoutViewController for generating short order IDs
  String _generateShortOrderId() {
    final random = Random();
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    // Generate 2 random capital letters
    final letterPart = String.fromCharCodes(List.generate(
        2, (_) => letters.codeUnitAt(random.nextInt(letters.length))));

    // Generate 5 random numbers
    final numberPart = List.generate(5, (_) => random.nextInt(10)).join();

    return '$letterPart$numberPart';
  }

  Future<Map<String, dynamic>> createOrderObject(
      Map<String, dynamic> address) async {
    try {
      final cartController = Get.find<NewCartController>();
      final user = _auth.currentUser;

      if (user == null) throw Exception('User not authenticated');

      final orderId = _generateShortOrderId();
      final timestamp = FieldValue.serverTimestamp();

      // FIXED: Convert cart items with proper serialization
      final List<Map<String, dynamic>> cartItems = [];
      for (final item in cartController.getItems) {
        if (item is NewCartModel) {
          // Create a safe serializable version of the cart item
          final serializableItem = {
            'id': item.id,
            'name': item.name,
            'price': item.price,
            'time': item.time,
            'img': item.img,
            'type': item.type,
            'material': item.material,
            'quantity': item.quantity,
            'isExist': item.isExist,
            'provider': item.provider,
            // Handle specialty field carefully
            'specialty': _serializeSpecialty(item.specialty),
          };
          cartItems.add(serializableItem);
        }
      }

      // Build order object
      final order = {
        'orderId': orderId,
        'userId': user.uid,
        'userEmail': user.email ?? 'No email',
        'status': 'pending',
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'items': cartItems,
        'subtotal': orderSubtotal,
        'serviceFee': serviceFee,
        'tipAmount': optionalTip,
        'totalAmount': orderTotal,
        'deliveryAddress': address,
        'deliveryInstructions': {
          'leaveAtDoor': _shouldLeaveAtTheDoor,
          'dontRingBell': _isBellAllowed,
          'callWhenArrive': _shouldCallWhenArrive,
          'additionalNotes': _deliveryNote,
        },
        'paymentMethod': _selectedPaymentMethod,
        'paymentStatus': 'pending',
        'serviceTypes': _getServiceTypes(cartController.getItems),
      };

      print('✅ Order object created with ID: $orderId');
      return order;
    } catch (e) {
      print('❌ Error creating order object: $e');
      rethrow;
    }
  }

// Add this helper method to handle specialty serialization
  dynamic _serializeSpecialty(dynamic specialty) {
    try {
      if (specialty == null) return null;

      if (specialty is NewSpecialtyModel) {
        // Convert NewSpecialtyModel to a serializable map
        return {
          'id': specialty.id,
          'name': specialty.name,
          'introduction': specialty.introduction,
          'price': specialty.price,
          'size': specialty.size,
          'img': specialty.img,
          'type': specialty.type,
          'material': specialty.material,
          'provider': specialty.provider,
          'time': specialty.time,
          'originalId': specialty.originalId,
          'selectedSize': specialty.selectedSize,
          'isSizeVariant': specialty.isSizeVariant,
        };
      } else if (specialty is Map) {
        // Already a map, return as is
        return specialty;
      } else {
        // Fallback: convert to string or basic representation
        return specialty.toString();
      }
    } catch (e) {
      print('⚠️ Error serializing specialty: $e');
      return null;
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

// In CheckoutViewController - Update submitOrder with better cart clearing
// In CheckoutViewController - Update submitOrder to include notification
  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> address) async {
    try {
      _isLoadingIndicator = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final cartController = Get.find<NewCartController>();
      final order = await createOrderObject(address);

      // Save to Firestore
      await _firestore.collection('orders').doc(order['orderId']).set(order);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(order['orderId'])
          .set(order);

      // ✅ CRITICAL: Send order notification after successful order creation
      await sendOrderNotification(order);

      cartController.clear();
      _isLoadingIndicator = false;
      notifyListeners();

      return order;
    } catch (error, stackTrace) {
      _isLoadingIndicator = false;
      notifyListeners();
      rethrow;
    }
  }

  bool get isFormValid {
    return _selectedPaymentMethod.isNotEmpty;
  }

// Simple and reliable
  Future<void> sendOrderNotification(Map<String, dynamic> order) async {
    try {
      final notificationService = NotificationService();

      await notificationService.showOrderNotification(
        orderId: order['orderId'],
        title: 'Order Received! 🎉',
        body:
            'Your order ${order['orderId']} has been received and is being prepared.',
      );

      print('✅ Order notification sent');
    } catch (e) {
      print('❌ Error sending order notification: $e');
    }
  }

  @override
  void dispose() {
    deliveryNotesController.dispose();
    super.dispose();
  }
}
