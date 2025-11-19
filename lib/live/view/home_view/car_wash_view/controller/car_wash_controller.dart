// lib/controllers/car_wash_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../../../controllers/new_cart_controller.dart';
import '../../../../../models/new_specialty_model.dart';
import '../view_widgets/show_wash_type_details.dart';

class CarWashController extends GetxController {
  final NewCartController _cartController = Get.find<NewCartController>();

  int _selectVehicleIndex = 0;

  int get selectVehicleIndex => _selectVehicleIndex;

  int _washTypeIndex = 0;

  int get washTypeIndex => _washTypeIndex;

  String _washType = '';

  String get washType => _washType;

  String _description = '';

  String get description => _description;

  // Define price selection matrix
  final List<List<int>> _priceSelection = [
    [150, 150, 180, 220, 260, 280, 350],
    [170, 170, 190, 230, 280, 300, 380],
    [190, 190, 290, 360, 400, 450, 500],
  ];

  // Define wash types
  final List<Map<String, dynamic>> washTypes = [
    {
      'washType': 'Standard Interior Wash',
      'description': 'Inside wash only, includes dashboard clean.',
      'included': [
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': 0xFFEDE7F6 // Colors.deepPurpleAccent.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': 0xFFE8F5E8 // Colors.green.shade100
        },
      ],
      'excluded': []
    },
    {
      'washType': 'Standard Exterior Wash',
      'description': 'Outside wash only, includes tyre shine.',
      'included': [
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': 0xFFFFF3E0 // Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Tyre Polish',
          'image': 'assets/image/tyre-shine.png',
          'color': 0xFFECEFF1 // Colors.blueGrey.withOpacity(0.2)
        },
      ],
      'excluded': []
    },
    {
      'washType': 'Standard Exterior Wash and Polish',
      'description': 'Outside wash only, includes tyre shine and body polish.',
      'included': [
        {
          'text': 'Body Polish',
          'image': 'assets/image/body-polish.png',
          'color': 0xFFE8F5E8 // Colors.green.shade100
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': 0xFFFFF3E0 // Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Tyre Polish',
          'image': 'assets/image/tyre-shine.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
      ],
      'excluded': []
    },
    {
      'washType': 'Standard Full Wash',
      'description': 'Full car wash including vacuuming and tyre shine.',
      'included': [
        {
          'text': 'Tyre Shine',
          'image': 'assets/image/tyre-shine.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': 0xFFFFF3E0 // Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': 0xFFECEFF1 // Colors.blueGrey.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': 0xFFE8F5E8 // Colors.green.shade100
        },
      ],
      'excluded': []
    },
    {
      'washType': 'Standard Wash and Full Body Polish',
      'description':
          'Full car wash including vacuuming, tyre shine, and body polish.',
      'included': [
        {
          'text': 'Body Polish',
          'image': 'assets/image/body-polish.png',
          'color': 0xFFE8F5E8 // Colors.green.shade100
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': 0xFFFFF3E0 // Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': 0xFFECEFF1 // Colors.blueGrey.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': 0xFFE8F5E8 // Colors.green.shade100
        },
        {
          'text': 'Tyre Shine',
          'image': 'assets/image/tyre-shine.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
      ],
      'excluded': []
    },
    {
      'washType': 'Premium Full Wash',
      'description':
          'Full car wash including vacuuming, tyre shine, and premium perfumes.',
      'included': [
        {
          'text': 'Premium Perfumes',
          'image': 'assets/image/perfume.png',
          'color': 0xFFEFEBE9 // Colors.brown.shade100
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': 0xFFFFF3E0 // Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': 0xFFECEFF1 // Colors.blueGrey.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': 0xFFE8F5E8 // Colors.green.shade100
        },
        {
          'text': 'Tyre Shine',
          'image': 'assets/image/tyre-shine.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
      ],
      'excluded': []
    },
    {
      'washType': 'Premium Full Wash and Full Body Polish',
      'description':
          'Full car wash including vacuuming, tyre shine, premium perfumes, and body polish.',
      'included': [
        {
          'text': 'Body Polish',
          'image': 'assets/image/body-polish.png',
          'color': 0xFFE8F5E8 // Colors.green.shade100
        },
        {
          'text': 'Premium Perfumes',
          'image': 'assets/image/perfume.png',
          'color': 0xFFEFEBE9 // Colors.brown.shade100
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': 0xFFFFF3E0 // Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': 0xFFECEFF1 // Colors.blueGrey.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': 0xFFE8F5E8 // Colors.green.shade100
        },
        {
          'text': 'Tyre Shine',
          'image': 'assets/image/tyre-shine.png',
          'color': 0xFFFFEBEE // Colors.redAccent.withOpacity(0.2)
        },
      ],
      'excluded': []
    },
  ];

  // Add this method to your CarWashController class
  void removeFromCarWashCart(String itemId) {
    // Convert string itemId to int if needed
    final id = int.tryParse(itemId) ?? 0;
    removeCarWashItem(id);
  }

  // Mock car wash specialties - replace with your actual data source
  final List<NewSpecialtyModel> carWashSpecialties = [
    NewSpecialtyModel(
      id: 401,
      name: 'Small Car',
      introduction: 'Hatchback, Sedan, Compact',
      img: 'assets/image/small-car.png',
      price: [150],
    ),
    NewSpecialtyModel(
      id: 402,
      name: 'Medium SUV',
      introduction: 'SUV, Crossover, Family Vehicle',
      img: 'assets/image/medium-car.png',
      price: [170],
    ),
    NewSpecialtyModel(
      id: 403,
      name: 'Large Vehicle',
      introduction: 'Truck, Van, Luxury Vehicle',
      img: 'assets/image/large-car.png',
      price: [190],
    ),
  ];

  // Cart integration for car wash items
  final RxList<Map<String, dynamic>> _carWashCartItems =
      <Map<String, dynamic>>[].obs;

  // // Override getters to always return synced data
  // List<Map<String, dynamic>> get carWashCartItems {
  //   syncWithMainCart(); // Sync before returning data
  //   return _carWashCartItems;
  // }
  //
  // int get totalCarWashItems {
  //   syncWithMainCart(); // Sync before calculating
  //   return _carWashCartItems.fold(
  //       0, (int sum, item) => sum + (item['quantity'] as int? ?? 0));
  // }
  //
  // int get totalCarWashAmount {
  //   syncWithMainCart(); // Sync before calculating
  //   return _carWashCartItems.fold(0, (int sum, item) {
  //     final price = item['price'] as int? ?? 0;
  //     final quantity = item['quantity'] as int? ?? 0;
  //     return sum + (price * quantity);
  //   });
  // }

  void selectVehicleType(int index) {
    _selectVehicleIndex = index;
    update();
  }

  Future<void> selectWashType(int index) async {
    _washTypeIndex = index;
    _washType = washTypes[_washTypeIndex]['washType'];
    _description = washTypes[_washTypeIndex]['description'];
    update();
  }

  int calculateCharges() {
    return _priceSelection[_selectVehicleIndex][_washTypeIndex];
  }

  // Enhanced cart methods
  void addCarWashToCart() {
    final vehicle = carWashSpecialties[_selectVehicleIndex];
    final washTypeData = washTypes[_washTypeIndex];
    final price = calculateCharges();

    // Create unique car wash cart item
    final carWashItem = {
      'id': _generateCarWashId(vehicle.id!, _washTypeIndex),
      'name': '${vehicle.name} - ${washTypeData['washType']}',
      'price': price,
      'vehicleType': vehicle.name,
      'washType': washTypeData['washType'],
      'description': washTypeData['description'],
      'included': washTypeData['included'],
      'quantity': 1,
      'image': vehicle.img,
      'type': 'car_wash',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Check if item already exists in cart
    final existingIndex =
        _carWashCartItems.indexWhere((item) => item['id'] == carWashItem['id']);

    if (existingIndex >= 0) {
      // Update quantity
      _carWashCartItems[existingIndex]['quantity'] =
          (_carWashCartItems[existingIndex]['quantity'] as int) + 1;
    } else {
      // Add new item
      _carWashCartItems.add(carWashItem);
    }

    // Also add to main cart controller
    _addToMainCart(carWashItem);

    update();
    _saveCarWashCart();
  }

  void updateCarWashQuantity(int itemId, int quantity) {
    final itemIndex =
        _carWashCartItems.indexWhere((item) => item['id'] == itemId);

    if (itemIndex >= 0) {
      if (quantity <= 0) {
        final item = _carWashCartItems[itemIndex]; // Get the item first
        _carWashCartItems.removeAt(itemIndex);
        _removeFromMainCart(item); // Pass the item Map
      } else {
        _carWashCartItems[itemIndex]['quantity'] = quantity;
        _updateMainCart(itemId, quantity);
      }

      update();
      _saveCarWashCart();
    }
  }

  void removeCarWashItem(int itemId) {
    final item = _carWashCartItems.firstWhere((item) => item['id'] == itemId);

    // Remove from main cart first with the item data
    _removeFromMainCart(item);

    // Then remove from local list
    _carWashCartItems.removeWhere((item) => item['id'] == itemId);

    update();
    _saveCarWashCart();
  }

  void _removeFromMainCart(Map<String, dynamic> item) {
    final specialty = _createCarWashSpecialtyModel(item);
    final quantity = _cartController.getQuantity(specialty);

    if (quantity > 0) {
      _cartController.addItem(specialty, -quantity);
    }
  }

  void clearCarWashCart() {
    // Remove all car wash items from main cart
    for (final item in _carWashCartItems) {
      _removeFromMainCart(item); // Pass the item Map, not item['id']
    }

    _carWashCartItems.clear();
    update();
    _saveCarWashCart();
  }

  // Integration with main cart controller
  void _addToMainCart(Map<String, dynamic> carWashItem) {
    final specialty = _createCarWashSpecialtyModel(carWashItem);
    _cartController.addItem(specialty, 1);
  }

  void _updateMainCart(int itemId, int quantity) {
    final item = _carWashCartItems.firstWhere((item) => item['id'] == itemId);
    final specialty = _createCarWashSpecialtyModel(item);

    // Calculate difference and update main cart
    final currentQuantity = _cartController.getQuantity(specialty);
    final difference = quantity - currentQuantity;

    if (difference != 0) {
      _cartController.addItem(specialty, difference);
    }
  }

  // Persistence
  void _saveCarWashCart() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('car_wash_cart', json.encode(_carWashCartItems));
  }

  void loadCarWashCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('car_wash_cart');

    if (cartData != null) {
      try {
        final List<dynamic> decoded = json.decode(cartData);
        _carWashCartItems.assignAll(decoded.cast<Map<String, dynamic>>());
        update();
      } catch (e) {

      }
    }
  }

  /// Included vehicles for display in the UI
  final List<Map<String, dynamic>> _includedVehicles = [];

  List<Map<String, dynamic>> get includedVehicles => _includedVehicles;

  /// Add a car to the included vehicles list
  void addCar(String vehicleType, String imageString) {
    final vehicle = carWashSpecialties[_selectVehicleIndex];
    final washTypeData = washTypes[_washTypeIndex];
    final price = calculateCharges();

    var existingItem = _includedVehicles.firstWhereOrNull((e) =>
        e['vehicleType'] == vehicleType &&
        e['washType'] == washTypeData['washType']);

    if (existingItem != null) {
      existingItem['selectionQuantity'] =
          (existingItem['selectionQuantity'] as int) + 1;
    } else {
      _includedVehicles.add({
        'selectionQuantity': 1,
        'bill': price,
        'vehicleType': vehicleType,
        'imageString': imageString,
        'selectedWash': washTypeData,
        'vehicleId': vehicle.id,
        'washTypeIndex': _washTypeIndex,
      });
    }

    update();
  }

  /// Remove item from included vehicles
  void removeItem(dynamic specialty) {
    // Find and remove the vehicle from included vehicles
    final vehicleName = specialty.name;
    final itemIndex = _includedVehicles
        .indexWhere((item) => item['vehicleType'] == vehicleName);

    if (itemIndex >= 0) {
      final currentQuantity =
          _includedVehicles[itemIndex]['selectionQuantity'] as int;
      if (currentQuantity > 1) {
        _includedVehicles[itemIndex]['selectionQuantity'] = currentQuantity - 1;
      } else {
        _includedVehicles.removeAt(itemIndex);
      }
      update(); // This triggers UI refresh
    }
  }

  /// Update quantity displayed in the UI
  int updateQuantityDisplayed() {
    final vehicle = carWashSpecialties[_selectVehicleIndex];
    final item = _includedVehicles
        .firstWhereOrNull((e) => e['vehicleType'] == vehicle.name);

    return item != null ? (item['selectionQuantity'] as int) : 0;
  }

  /// Clear all included vehicles
  void clearIncludedVehicles() {
    _includedVehicles.clear();
    update();
  }

  /// Get total quantity of all included vehicles
  int get totalIncludedVehicles {
    return _includedVehicles.fold(
        0, (int sum, item) => sum + (item['selectionQuantity'] as int? ?? 0));
  }

  /// Check if a specific vehicle is included
  bool isVehicleIncluded(String vehicleType) {
    return _includedVehicles.any((item) => item['vehicleType'] == vehicleType);
  }

  /// Get quantity for a specific vehicle
  int getVehicleQuantity(String vehicleType) {
    final item = _includedVehicles
        .firstWhereOrNull((item) => item['vehicleType'] == vehicleType);
    return item != null ? (item['selectionQuantity'] as int) : 0;
  }

  // Helper methods
  int _generateCarWashId(int vehicleId, int washTypeIndex) {
    return (vehicleId * 1000) + washTypeIndex;
  }

  void showDetails(BuildContext context) {
    showModalBottomSheet(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return ShowWashTypeDetails(
          headerText: _washType,
          price: calculateCharges().toString(),
          description: _description,
          action: 'Add to Cart',
          isMiniaturized: false,
          isCartView: false,
          onTap: () {
            addCarWashToCart();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // Remove update() calls from getters and sync method
  List<Map<String, dynamic>> get carWashCartItems {
    syncWithMainCart(); // Sync before returning data
    return _carWashCartItems;
  }

  int get totalCarWashItems {
    syncWithMainCart(); // Sync before calculating
    return _carWashCartItems.fold(
        0, (int sum, item) => sum + (item['quantity'] as int? ?? 0));
  }

// Replace the syncWithMainCart method with this corrected version:
  void syncWithMainCart() {
    final mainCartItems = _cartController.getItems;

    // Create a list of car wash item IDs from main cart
    final carWashItemIdsInMainCart = mainCartItems
        .where((item) => item.type == 'Car Wash')
        .map((item) => item.id)
        .toSet();

    // Remove items from carWashCartItems that are no longer in main cart
    _carWashCartItems
        .removeWhere((item) => !carWashItemIdsInMainCart.contains(item['id']));

    // Update quantities to match main cart and ensure all data is present
    for (final mainCartItem
        in mainCartItems.where((item) => item.type == 'Car Wash')) {
      final carWashItemIndex =
          _carWashCartItems.indexWhere((item) => item['id'] == mainCartItem.id);

      if (carWashItemIndex >= 0) {
        // Update quantity and ensure all fields are present
        _carWashCartItems[carWashItemIndex]['quantity'] = mainCartItem.quantity;
        _carWashCartItems[carWashItemIndex]['name'] = mainCartItem.name;
        // Fix: Handle price properly - it might be a List<int> or single int
        final price = mainCartItem.price is List
            ? (mainCartItem.price as List).first
            : mainCartItem.price;
        _carWashCartItems[carWashItemIndex]['price'] = price ?? 0;
      } else {
        // Add missing item back (shouldn't happen but for safety)
        final vehicleId = mainCartItem.id! ~/ 1000;
        final washTypeIndex = mainCartItem.id! % 1000;
        final vehicle = carWashSpecialties.firstWhere((v) => v.id == vehicleId);
        final washType = washTypes[washTypeIndex];

        // Fix: Handle price properly
        final price = mainCartItem.price is List
            ? (mainCartItem.price as List).first
            : mainCartItem.price;

        _carWashCartItems.add({
          'id': mainCartItem.id,
          'name': mainCartItem.name,
          'price': price ?? 0,
          'vehicleType': vehicle.name,
          'washType': washType['washType'],
          'description': washType['description'],
          'quantity': mainCartItem.quantity,
          'image': vehicle.img,
          'type': 'car_wash',
        });
      }
    }

    _saveCarWashCart(); // Ensure persistence
  }

// Also update the _createCarWashSpecialtyModel method to handle price properly:
  dynamic _createCarWashSpecialtyModel(Map<String, dynamic> item) {
    // Fix: Handle price properly - ensure it's a List<int>
    final price = item['price'] is int ? [item['price'] as int] : [0];

    return NewSpecialtyModel(
      id: item['id'] as int,
      name: item['name'] as String,
      price: price,
      img: item['image'] as String,
      type: 'Car Wash',
      introduction: item['description'] as String,
    );
  }

// Update the getter for cart details to ensure proper data:
  List<Map<String, dynamic>> get carWashCartDetails {
    syncWithMainCart();

    // Ensure all items have the required fields
    return _carWashCartItems.map((item) {
      return {
        'id': item['id'] ?? 0,
        'name': item['name'] ?? 'Car Wash Service',
        'price': item['price'] ?? 0,
        'vehicleType': item['vehicleType'] ?? 'Vehicle',
        'washType': item['washType'] ?? 'Wash Type',
        'description': item['description'] ?? '',
        'quantity': item['quantity'] ?? 0,
        'image': item['image'] ?? 'assets/image/car_placeholder.png',
        'type': item['type'] ?? 'car_wash',
      };
    }).toList();
  }

// Update the totalCarWashAmount getter to handle price properly:
  int get totalCarWashAmount {
    syncWithMainCart();
    return _carWashCartItems.fold(0, (int sum, item) {
      final price = item['price'] is int ? item['price'] as int : 0;
      final quantity = item['quantity'] as int? ?? 0;
      return sum + (price * quantity);
    });
  }

  int get carWashItemsCount {
    syncWithMainCart();
    return totalCarWashItems;
  }

  @override
  void onInit() {
    super.onInit();
    loadCarWashCart();
    // Use WidgetsBinding to sync after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncWithMainCart();
    });
  }
}
