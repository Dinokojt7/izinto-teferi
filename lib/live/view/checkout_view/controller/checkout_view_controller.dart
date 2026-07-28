import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:izinto/live/utilities/generic_snackbar.dart';
import '../../../../controllers/new_cart_controller.dart';
import '../../../../models/new_cart_model.dart';
import '../../../../models/new_specialty_model.dart';
import '../../../../services/notification_service.dart';
import '../../../../utils/dimensions.dart';
import '../../../widgets/buttons/save_button.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../view_widgets/call_checkout.dart';

class CheckoutViewController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isWalletApplied = false;
  bool get isWalletApplied => _isWalletApplied;
  int _walletDiscount = 0;
  int get walletDiscount => _walletDiscount;
  int _availableWalletBalance = 0;
  int get availableWalletBalance => _availableWalletBalance;

  // Add to CheckoutViewController class
  LaundryValidationResult? _laundryValidationInfo;
  LaundryValidationResult? get laundryValidationInfo => _laundryValidationInfo;

  void setLaundryValidationInfo(LaundryValidationResult validation) {
    _laundryValidationInfo = validation;
    notifyListeners();
  }

  void clearLaundryValidationInfo() {
    _laundryValidationInfo = null;
    notifyListeners();
  }

  // Override order calculations to exclude laundry items when needed
  int get orderSubtotal {
    try {
      final cartController = Get.find<NewCartController>();
      int subtotal = cartController.totalAmount;

      // Exclude laundry items if validation info exists
      if (_laundryValidationInfo != null &&
          _laundryValidationInfo!.hasLowLaundryItems) {
        subtotal -= _laundryValidationInfo!.laundryTotal;
      }

      return subtotal;
    } catch (e) {
      return 0;
    }
  }

  // Add to CheckoutViewController class
  void resetCheckoutState() {
    _isWalletApplied = false;
    _walletDiscount = 0;
    _selectedPaymentMethod = '';
    _selectedTipIndex = -1;
    _shouldLeaveAtTheDoor = false;
    _isBellAllowed = false;
    _shouldCallWhenArrive = false;
    _deliveryNote = 'Any additional notes? Add them here!';
    deliveryNotesController.text = '';

    // Clear promo code state
    _enteredPromoCode = '';
    _isPromoCodeValid = false;
    _promoCodeType = null;
    _promoDiscount = 0;

    // Clear laundry validation
    clearLaundryValidationInfo();

    // Reload wallet balance in case it changed
    loadWalletBalance();

    notifyListeners();

    print('🔄 Checkout state reset for new order');
  }

  // Update order total calculation to use the adjusted subtotal
  int get orderTotal {
    int total = orderSubtotal + optionalTip - _promoDiscount - _walletDiscount;
    return total < 0 ? 0 : total; // Ensure total doesn't go negative
  }

  // Modify createOrderObject to exclude laundry items from final order
  Future<Map<String, dynamic>> createOrderObject(
      Map<String, dynamic> address) async {
    try {
      final cartController = Get.find<NewCartController>();
      final user = _auth.currentUser;

      if (user == null) throw Exception('User not authenticated');

      final orderId = _generateShortOrderId();
      final timestamp = FieldValue.serverTimestamp();

      // FIXED: Convert cart items with proper serialization, excluding laundry if needed
      final List<Map<String, dynamic>> cartItems = [];
      for (final item in cartController.getItems) {
        // Skip laundry items if they don't meet minimum
        if (_shouldExcludeLaundryItem(item)) {
          continue;
        }

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
        'paymentMethod': _isWalletApplied && _walletDiscount >= orderTotal
            ? 'wallet'
            : _selectedPaymentMethod,
        'paymentStatus': _isWalletApplied && _walletDiscount >= orderTotal
            ? 'paid'
            : 'pending',
        'walletPayment': _isWalletApplied,
        'walletAmount': _walletDiscount,
        'serviceTypes': _getServiceTypes(cartItems),

        // Add laundry exclusion info for tracking
        if (_laundryValidationInfo != null &&
            _laundryValidationInfo!.hasLowLaundryItems)
          'laundryExcluded': {
            'totalExcluded': _laundryValidationInfo!.laundryTotal,
            'reason': 'Below minimum order threshold',
            'itemsCount': _laundryValidationInfo!.laundryItems.length,
            'excludedItems': _laundryValidationInfo!.laundryItems
                .map((item) => {
                      'id': item.id,
                      'name': item.name,
                      'price': item.price,
                      'quantity': item.quantity,
                    })
                .toList(),
          },
      };

      print(
          '📦 Order includes ${cartItems.length} items (laundry excluded: ${_laundryValidationInfo != null && _laundryValidationInfo!.hasLowLaundryItems})');
      return order;
    } catch (e) {
      rethrow;
    }
  }

  bool _shouldExcludeLaundryItem(NewCartModel item) {
    if (_laundryValidationInfo == null ||
        !_laundryValidationInfo!.hasLowLaundryItems) {
      return false;
    }

    // Check if this item is one of the low-value laundry items
    final provider = item.provider?.toString().toLowerCase() ?? '';
    final isLaundryItem =
        provider.contains('easy laundry') || provider.contains('laundry');

    if (!isLaundryItem) return false;

    // Check if this specific item is in our exclusion list
    return _laundryValidationInfo!.laundryItems
        .any((laundryItem) => laundryItem.id == item.id);
  }

  // Update submitOrder to clear laundry info after successful order
  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> address) async {
    try {
      _isLoadingIndicator = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 5));

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final cartController = Get.find<NewCartController>();
      final order = await createOrderObject(address);

      // Add promo code info to order if applicable
      bool driverReferralFirstOrderRecorded = false;
      if (_isPromoCodeValid && _enteredPromoCode.isNotEmpty) {
        order['promoCodeUsed'] = _enteredPromoCode;
        order['promoDiscount'] = _promoDiscount;

        if (_promoCodeType == 'driver_customer_referral') {
          // First qualifying order for a driver-referred customer: flags the
          // account permanently and pays the driver a flat first-order reward.
          await _recordDriverReferralFirstOrder(
              _enteredPromoCode, user.uid, order['orderId'] as String);
          driverReferralFirstOrderRecorded = true;
        } else {
          // Legacy flat-R50 self-referral flow — unchanged
          await _rewardPromoCodeOwner(_enteredPromoCode);
        }
      }

      // Independent of any code entered this session: if this customer was
      // already attributed to a driver on a previous order, every order after
      // the first automatically earns that driver a recurring commission.
      if (!driverReferralFirstOrderRecorded) {
        await _recordDriverReferralRecurringCommission(
            user.uid, order['orderId'] as String);
      }

      // Add wallet usage info to order if applicable
      if (_isWalletApplied && _walletDiscount > 0) {
        order['walletUsed'] = _walletDiscount;
        order['walletBalanceBefore'] = _availableWalletBalance;
        order['walletBalanceAfter'] = _availableWalletBalance - _walletDiscount;

        // Deduct from user's wallet
        await _deductFromWallet(_walletDiscount);
      }

      // Save to Firestore
      await _firestore.collection('orders').doc(order['orderId']).set(order);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(order['orderId'])
          .set(order);

      // Clear cart only after successful order creation
      cartController.clear();
      resetCheckoutState();

      // Clear discounts and laundry info after successful order
      clearPromoCode();
      clearWalletUsage();
      clearLaundryValidationInfo();

      // Send notification
      await sendOrderNotification(order);

      _isLoadingIndicator = false;
      notifyListeners();

      return order;
    } catch (error) {
      _isLoadingIndicator = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadWalletBalanceFromFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _availableWalletBalance = (userDoc.data()?['wallet'] ?? 0).toInt();
          notifyListeners();
        }
      }
    } catch (e) {
      _availableWalletBalance = 0;
    }
  }

  Future<void> _deductFromWallet(int amount) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final newBalance = _availableWalletBalance - amount;

        // Update in Firebase
        await _firestore.collection('users').doc(user.uid).update({
          'wallet': newBalance,
          'lastWalletDeduction': FieldValue.serverTimestamp(),
        });

        // Update local state
        _availableWalletBalance = newBalance;
      }
    } catch (e) {}
  }

  void toggleWalletUsage() {
    if (_isWalletApplied) {
      // Remove wallet discount
      _isWalletApplied = false;
      _walletDiscount = 0;

      // If we were using wallet as primary payment, clear it
      if (_selectedPaymentMethod == 'wallet') {
        _selectedPaymentMethod = '';
      }
    } else {
      // Apply wallet discount
      _isWalletApplied = true;
      final orderAmount = orderSubtotal + optionalTip - _promoDiscount;
      _walletDiscount = _availableWalletBalance > orderAmount
          ? orderAmount
          : _availableWalletBalance;

      // Only auto-select wallet as payment method if it covers FULL amount
      if (_walletDiscount >= orderAmount) {
        _selectedPaymentMethod = 'wallet';
      }
    }
    notifyListeners();
  }

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void clearWalletUsage() {
    _isWalletApplied = false;
    _walletDiscount = 0;
    notifyListeners();
  }

  void clearPromoCode() {
    _enteredPromoCode = '';
    _isPromoCodeValid = false;
    _promoCodeType = null;
    _promoDiscount = 0;
    notifyListeners();
  }

  // Initialize wallet when controller is created
  CheckoutViewController() {
    loadWalletBalance();
    _loadReferralConfig();
  }

  // Driver-referral program config (app_config/referral_program), with
  // sensible defaults so checkout still works if the doc hasn't been created.
  Map<String, dynamic> _referralConfig = {
    'firstOrderFlatReward': 80,
    'recurringCommissionPercent': 5,
    'minOrderSubtotal': 500,
    'maxDiscountAmount': 250,
  };

  Future<void> _loadReferralConfig() async {
    try {
      final configDoc = await _firestore
          .collection('app_config')
          .doc('referral_program')
          .get();
      final data = configDoc.data();
      if (data != null) {
        _referralConfig = {..._referralConfig, ...data};
      }
    } catch (e) {
      // Keep defaults if the config doc doesn't exist or can't be read
    }
  }

  // Load wallet balance
  void loadWalletBalance() {
    try {
      _loadWalletBalanceFromFirebase();
    } catch (e) {
      _availableWalletBalance = 0;
    }
  }

  // TODO(god-file): this controller is ~1000 lines and owns delivery
  // instructions, tipping, payment method selection, wallet logic, and order
  // submission all in one class. Consider splitting by concern (e.g. a
  // dedicated wallet/payment sub-controller) before adding the Yoco
  // integration work on top of it.

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

  // TODO(paystack-to-yoco): the 'yoco' entry below is UI-only — selecting it
  // just stores the string 'yoco' as paymentMethod on the order (see
  // createOrderObject/submitOrder further down); there is no call to a
  // payment gateway anywhere in this flow. The only working gateway code in
  // the repo talks to Paystack directly (lib/paystack/, user_controller.dart)
  // and isn't even wired into checkout. Needs real end-to-end Yoco logic:
  // initialize a charge/payment link, redirect/collect payment, verify the
  // result, then update order + wallet/payment status accordingly.
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
  String _deliveryNote = 'Any additional notes? Add them here!';
  String get deliveryNote => _deliveryNote;

  TextEditingController deliveryNotesController = TextEditingController();

  // Order summary (dynamic)
  int get serviceFee => 35; // Fixed service fee
  int get optionalTip => selectedTipAmount;

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

  void updateDeliveryNote(String note) {
    _deliveryNote = note;
    notifyListeners();
  }

  // Order Processing
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
      return null;
    }
  }

  List<String> _getServiceTypes(List<dynamic> items) {
    final types = <String>{};
    for (final item in items) {
      try {
        if (item['type'] != null) {
          types.add(item['type'].toString());
        }
      } catch (e) {}
    }
    return types.toList();
  }

  bool get isFormValid {
    final orderAmount = orderSubtotal + optionalTip - _promoDiscount;

    if (_isWalletApplied) {
      if (_walletDiscount >= orderAmount) {
        // Wallet covers entire amount - no payment method needed
        return true;
      } else {
        // Wallet covers partial amount - payment method required for remainder
        return _selectedPaymentMethod.isNotEmpty;
      }
    } else {
      // No wallet used - payment method required
      return _selectedPaymentMethod.isNotEmpty;
    }
  }

  String get orderDescription {
    final orderAmount = orderSubtotal + optionalTip - _promoDiscount;

    if (_isWalletApplied) {
      if (_walletDiscount >= orderAmount) {
        return 'Paid with wallet - R${_walletDiscount},00';
      } else {
        final remaining = orderAmount - _walletDiscount;
        return 'Pay R$remaining,00 (Wallet: R${_walletDiscount},00)';
      }
    } else {
      return 'Proceed with payment - R$orderTotal,00';
    }
  }

  bool get isWalletCoveringFullAmount {
    final orderAmount = orderSubtotal + optionalTip - _promoDiscount;
    return _isWalletApplied && _walletDiscount >= orderAmount;
  }

  bool get isWalletCoveringPartialAmount {
    final orderAmount = orderSubtotal + optionalTip - _promoDiscount;
    return _isWalletApplied &&
        _walletDiscount > 0 &&
        _walletDiscount < orderAmount;
  }

  Future<void> sendOrderNotification(Map<String, dynamic> order) async {
    try {
      final notificationService = NotificationService();

      // Ensure notification service is initialized
      await notificationService.initialize();

      // Check if notifications are enabled
      final areEnabled = await notificationService.areNotificationsEnabled();
      if (!areEnabled) {
        final granted = await notificationService.requestPermission();
        if (!granted) {
          return;
        }
      }

      // Send the notification with enhanced data
      await notificationService.showOrderNotification(
        orderId: order['orderId'],
        title: 'Order Received! 🎉',
        body:
            'Your order ${order['orderId']} has been received and is being prepared.',
        additionalData: {
          'orderId': order['orderId'],
          'totalAmount': order['totalAmount'],
          'serviceTypes': order['serviceTypes'],
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Don't rethrow - we don't want notification failures to break order creation
    }
  }

  String _enteredPromoCode = '';
  String get enteredPromoCode => _enteredPromoCode;
  bool _isPromoCodeValid = false;
  bool get isPromoCodeValid => _isPromoCodeValid;
  int _promoDiscount = 0;
  int get promoDiscount => _promoDiscount;
  bool _isCheckingPromoCode = false;
  bool get isCheckingPromoCode => _isCheckingPromoCode;
  // 'legacy' (flat R50 self-referral, unchanged) or 'driver_customer_referral'
  String? _promoCodeType;

  Future<void> validatePromoCode(String code) async {
    if (code.isEmpty) return;

    _isCheckingPromoCode = true;
    notifyListeners();

    try {
      final minOrderSubtotal =
          ((_referralConfig['minOrderSubtotal'] ?? 500) as num).toInt();

      // Check if order meets minimum amount
      if (orderSubtotal < minOrderSubtotal) {
        _isCheckingPromoCode = false;
        notifyListeners();
        throw Exception(
            'Minimum order amount of R$minOrderSubtotal required for promo codes');
      }

      // Check if promo code exists in Firestore
      final promoDoc =
          await _firestore.collection('promo_codes').doc(code).get();

      if (!promoDoc.exists) {
        throw Exception('Invalid promo code');
      }

      final promoData = promoDoc.data()!;
      final ownerUserId = promoData['ownerUserId'];
      final currentUser = _auth.currentUser;

      // Check if user is trying to use their own code
      if (currentUser != null && ownerUserId == currentUser.uid) {
        throw Exception('Cannot use your own promo code');
      }

      final type = promoData['type'] as String?;

      if (type == 'driver_customer_referral') {
        if (currentUser == null) throw Exception('User not authenticated');

        final userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        final userData = userDoc.data() ?? {};

        if (userData['referredByDriverId'] != null) {
          throw Exception(
              'A driver referral code has already been applied to your account');
        }
        if (userData['referralFirstOrderCompleted'] == true) {
          throw Exception('This code is only valid on your first order');
        }

        final maxDiscount =
            ((_referralConfig['maxDiscountAmount'] ?? 250) as num).toInt();
        final computedDiscount = (orderSubtotal * 0.5).round();

        _enteredPromoCode = code;
        _isPromoCodeValid = true;
        _promoCodeType = 'driver_customer_referral';
        _promoDiscount =
            computedDiscount > maxDiscount ? maxDiscount : computedDiscount;
      } else {
        // Legacy flat-R50 self-referral codes — unchanged behavior
        _enteredPromoCode = code;
        _isPromoCodeValid = true;
        _promoCodeType = 'legacy';
        _promoDiscount = 50; // R50 discount
      }
    } catch (e) {
      _enteredPromoCode = '';
      _isPromoCodeValid = false;
      _promoCodeType = null;
      _promoDiscount = 0;
      rethrow;
    } finally {
      _isCheckingPromoCode = false;
      notifyListeners();
    }
  }

  void showPromoCodeDialog(BuildContext context) {
    // Check order amount first
    if (orderSubtotal < 500) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _buildPromoCodeInputDialog(context),
    );
  }

  Widget _buildPromoCodeInputDialog(BuildContext context) {
    final textController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              EdgeInsets.symmetric(horizontal: Dimensions.width20 * 1.1),
          child: Container(
            height: Dimensions.screenHeight / 2.5,
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
                horizontal: Dimensions.width30 * 1.2,
                vertical: Dimensions.height20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HeadingStyleText(
                    text: 'Enter Promo Code',
                    weight: FontWeight.w600,
                    size: Dimensions.font26 / 1.2,
                  ),
                  SizedBox(height: Dimensions.height10),
                  HeadingStyleText(
                    text:
                        'Enter a promo or driver referral code to save on your order',
                    size: Dimensions.font20 / 1.3,
                    family: 'Poppins',
                    weight: FontWeight.w300,
                    align: TextAlign.center,
                  ),
                  SizedBox(height: Dimensions.height20),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: Dimensions.width15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        setState(() {}); // This triggers UI rebuild
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter code here',
                        hintStyle: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 1.1,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  if (_isCheckingPromoCode)
                    CircularProgressIndicator()
                  else
                    SaveButton(
                      isActive: textController.text.trim().isNotEmpty,
                      description: 'Apply Code',
                      isAuthScreen: false,
                      onTap: () async {
                        final code = textController.text.trim();
                        if (code.isNotEmpty) {
                          try {
                            await validatePromoCode(code);
                            Navigator.of(context).pop();
                            // Show success snackbar
                            GenericSnackBar().showCustomSnackBar(
                              null,
                              context,
                              'Promo code applied! R$_promoDiscount discount added.',
                              true, // isWiderSnack
                            );
                          } catch (e) {
                            // Show error snackbar
                            Get.snackbar(
                              'Error',
                              e.toString(),
                              borderRadius: Dimensions.radius15 * 1.3,
                              borderWidth: 2,
                              borderColor: Colors.red,
                              backgroundColor: Colors.white.withOpacity(0.5),
                              colorText: Colors.black,
                            );
                          }
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _rewardPromoCodeOwner(String promoCode) async {
    try {
      final promoDoc =
          await _firestore.collection('promo_codes').doc(promoCode).get();
      if (promoDoc.exists) {
        final promoData = promoDoc.data()!;
        final ownerUserId = promoData['ownerUserId'];

        // Update promo code usage stats
        await _firestore.collection('promo_codes').doc(promoCode).update({
          'timesUsed': FieldValue.increment(1),
          'lastUsedAt': FieldValue.serverTimestamp(),
          'totalRewardsGiven': FieldValue.increment(50),
          'recentUsers': FieldValue.arrayUnion([_auth.currentUser?.uid]),
        });

        // Update owner's wallet
        await _firestore.collection('users').doc(ownerUserId).update({
          'wallet': FieldValue.increment(50),
          'lastPromoReward': FieldValue.serverTimestamp(),
          'totalPromoRewards': FieldValue.increment(50),
        });
      }
    } catch (e) {}
  }

  /// Records a driver-customer-referral code's qualifying first order: flags
  /// the customer's account permanently (so future orders auto-earn the
  /// driver a recurring commission, see [_recordDriverReferralRecurringCommission])
  /// and writes a flat 'owed' entry to the driver_payouts ledger. Never
  /// touches users/{driverId}.wallet — a driver-only account has no
  /// users/{uid} doc, unlike the legacy self-referral flow.
  Future<void> _recordDriverReferralFirstOrder(
      String promoCode, String customerUserId, String orderId) async {
    try {
      final promoDoc =
          await _firestore.collection('promo_codes').doc(promoCode).get();
      if (!promoDoc.exists) return;

      final driverId = promoDoc.data()!['ownerUserId'];
      final flatReward =
          ((_referralConfig['firstOrderFlatReward'] ?? 80) as num).toInt();

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(customerUserId);
        final userSnap = await transaction.get(userRef);
        final userData = userSnap.data() ?? {};

        // Guard against a concurrent duplicate submission double-paying.
        if (userData['referralFirstOrderCompleted'] == true) return;

        transaction.update(userRef, {
          'referredByDriverId': driverId,
          'referredByDriverCode': promoCode,
          'referralFirstOrderCompleted': true,
          'referralFirstOrderId': orderId,
          'referredAt': FieldValue.serverTimestamp(),
        });

        final payoutRef = _firestore.collection('driver_payouts').doc();
        transaction.set(payoutRef, {
          'driverId': driverId,
          'customerId': customerUserId,
          'orderId': orderId,
          'code': promoCode,
          'type': 'first_order_flat',
          'amount': flatReward,
          'currency': 'ZAR',
          'status': 'owed',
          'paidAt': null,
          'paidNote': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      await _firestore.collection('promo_codes').doc(promoCode).update({
        'timesUsed': FieldValue.increment(1),
        'lastUsedAt': FieldValue.serverTimestamp(),
        'totalRewardsGiven': FieldValue.increment(flatReward),
        'recentUsers': FieldValue.arrayUnion([customerUserId]),
      });
    } catch (e) {}
  }

  /// Automatic ongoing commission for a driver on a previously-referred
  /// customer's later orders. No discount to the customer, no promo dialog
  /// interaction required — driven purely by the flags set in
  /// [_recordDriverReferralFirstOrder].
  Future<void> _recordDriverReferralRecurringCommission(
      String customerUserId, String orderId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(customerUserId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final driverId = userData['referredByDriverId'];
      final firstOrderCompleted =
          userData['referralFirstOrderCompleted'] == true;

      if (driverId == null || !firstOrderCompleted) return;

      final commissionPercent =
          ((_referralConfig['recurringCommissionPercent'] ?? 5) as num) / 100;
      final commissionAmount = (orderSubtotal * commissionPercent).round();
      if (commissionAmount <= 0) return;

      await _firestore.collection('driver_payouts').add({
        'driverId': driverId,
        'customerId': customerUserId,
        'orderId': orderId,
        'code': userData['referredByDriverCode'],
        'type': 'recurring_commission',
        'amount': commissionAmount,
        'currency': 'ZAR',
        'status': 'owed',
        'paidAt': null,
        'paidNote': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    deliveryNotesController.dispose();
    super.dispose();
  }
}
