import 'package:get/get.dart';
import 'package:izinto/helpers/data/repository/cart_repo.dart';
import 'package:izinto/models/new_cart_model.dart';

import '../live/utilities/price_helper.dart';
import '../live/view/checkout_view/view_widgets/call_checkout.dart';

class NewCartController extends GetxController {
  final CartRepo cartRepo;
  NewCartController({required this.cartRepo});

  Map<int, NewCartModel> _items = {};
  Map<int, NewCartModel> get items => _items;

  List<NewCartModel> storageItems = [];

  void addItem(dynamic specialty, int quantity) {
    // ✅ This now works because each size variant has a unique ID
    var totalQuantity = 0;
    final specialtyId = specialty.id!; // This is now unique per size

    if (_items.containsKey(specialtyId)) {
      _items.update(specialtyId, (value) {
        totalQuantity = value.quantity! + quantity;

        return NewCartModel(
          id: value.id,
          name: value.name,
          price: PriceHelper.getPrice(specialty),
          time: DateTime.now().toString(),
          img: PriceHelper.getImage(specialty),
          type: specialty.type,
          material: specialty.material,
          quantity: value.quantity! + quantity,
          isExist: true,
          provider: specialty.provider,
          specialty: specialty,
        );
      });

      if (totalQuantity <= 0) {
        _items.remove(specialtyId);
      }
    } else {
      if (quantity > 0) {
        _items.putIfAbsent(specialtyId, () {
          return NewCartModel(
            id: specialty.id,
            name: specialty.name,
            price: PriceHelper.getPrice(specialty),
            time: DateTime.now().toString(),
            img: PriceHelper.getImage(specialty),
            type: specialty.type,
            material: specialty.material,
            quantity: quantity,
            isExist: true,
            provider: specialty.provider,
            specialty: specialty,
          );
        });
      } else {
        Get.snackbar('Item count 0', 'Please select items to add to cart');
      }
    }
    cartRepo.addToNewCartList(getItems);
    update();
  }

  // Add to NewCartController class
  void removeLaundryItemsTemporarily() {
    final itemsToRemove = <int>[];

    _items.forEach((key, cartItem) {
      final provider = cartItem.provider?.toString().toLowerCase() ?? '';
      if (provider.contains('easy laundry') || provider.contains('laundry')) {
        itemsToRemove.add(key);
      }
    });

    for (final key in itemsToRemove) {
      _items.remove(key);
    }

    addToCartList();
    update();
  }

// Helper to check if cart has laundry items below threshold
  LaundryValidationResult validateLaundryItems() {
    int laundryTotal = 0;
    bool hasLaundryItems = false;
    List<NewCartModel> laundryItems = [];

    _items.forEach((key, cartItem) {
      final provider = cartItem.provider?.toString().toLowerCase() ?? '';
      if (provider.contains('easy laundry') || provider.contains('laundry')) {
        hasLaundryItems = true;
        laundryItems.add(cartItem);
        laundryTotal += (cartItem.price ?? 0) * (cartItem.quantity ?? 0);
      }
    });

    return LaundryValidationResult(
      hasLaundryItems: hasLaundryItems,
      hasLowLaundryItems: hasLaundryItems && laundryTotal < 150,
      laundryTotal: laundryTotal,
      laundryItems: laundryItems,
    );
  }

  bool existInCart(dynamic specialty) {
    if (specialty?.id == null) return false;
    return _items.containsKey(specialty.id);
  }

  int getQuantity(dynamic specialty) {
    if (specialty?.id == null) return 0;
    return _items[specialty.id]?.quantity ?? 0;
  }

  // ✅ Helper to get total quantity for a base product (all sizes)
  int getBaseProductQuantity(int? originalId) {
    if (originalId == null) return 0;

    var total = 0;
    _items.forEach((key, cartItem) {
      final specialty = cartItem.specialty;
      if (specialty is Map && specialty['originalId'] == originalId) {
        total += cartItem.quantity ?? 0;
      }
    });
    return total;
  }

  // ✅ Helper to get all size variants of a base product
  List<NewCartModel> getSizeVariants(int? originalId) {
    if (originalId == null) return [];

    return _items.values.where((cartItem) {
      final specialty = cartItem.specialty;
      return specialty is Map && specialty['originalId'] == originalId;
    }).toList();
  }

  int get totalItems {
    var totalQuantity = 0;
    _items.forEach((key, value) {
      totalQuantity += value.quantity!;
    });
    return totalQuantity;
  }

  List<NewCartModel> get getItems {
    return _items.entries.map((e) => e.value).toList();
  }

  int get totalAmount {
    var total = 0;
    _items.forEach((key, value) {
      total += value.quantity! * value.price!;
    });
    return total;
  }

  Future<List<NewCartModel>> getCartData() async {
    setCart = await cartRepo.getNewCartList();
    return storageItems;
  }

  set setCart(List<NewCartModel> items) {
    storageItems = items;
    for (int i = 0; i < storageItems.length; i++) {
      _items.putIfAbsent(storageItems[i].id!, () => storageItems[i]);
    }
  }

  // In NewCartController - Update the clear method
  void clear() {
    _items = {};
    storageItems = [];

    // Clear shared preferences
    cartRepo.clearCart();

    update();
  }

// Also add a method to check if cart is empty (for debugging)
  bool get isCartEmpty {
    return _items.isEmpty && storageItems.isEmpty;
  }

// Update the addToCartList to ensure it's working
  void addToCartList() {
    try {
      cartRepo.addToNewCartList(getItems);
      update();
    } catch (e) {}
  }
}
