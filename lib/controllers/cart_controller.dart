import 'package:get/get.dart';
import 'package:izinto/models/popular_specialty_model.dart';
import '../helpers/data/repository/cart_repo.dart';
import '../models/cart_model.dart';

class CartController extends GetxController {
  final CartRepo cartRepo;
  CartController({required this.cartRepo});
  Map<int, CartModel> _items = {};

  Map<int, CartModel> get items => _items;

  /*Only for storage and sharedPreferences*/
  List<CartModel> storageItems = [];

  void addItem(SpecialtyModel specialty, int quantity) {
    var totalQuantity = 0;
    if (_items.containsKey(specialty.id!)) {
      _items.update(specialty.id!, (value) {
        totalQuantity = value.quantity! + quantity;

        return CartModel(
          id: value.id,
          name: value.name,
          price: value.price,
          time: DateTime.now().toString(),
          img: value.img,
          type: value.type,
          material: value.material,
          quantity: value.quantity! + quantity,
          isExist: true,
          provider: value.provider,
          specialty: specialty,
        );
      });

      if (totalQuantity <= 0) {
        _items.remove(specialty.id);
      }
    } else {
      if (quantity > 0) {
        _items.putIfAbsent(specialty.id!, () {
          return CartModel(
            id: specialty.id,
            name: specialty.name,
            price: specialty.price,
            time: DateTime.now().toString(),
            img: specialty.img,
            type: specialty.type,
            material: specialty.material,
            quantity: quantity,
            isExist: true,
            provider: specialty.provider,
            specialty: specialty,
          );
        });
      } else {
        Get.snackbar(
          'Item count 0', 'Please select items to add to cart',
          // backgroundColor: AppColors.mainColor, colorText: Colors.white
        );
      }
    }
    cartRepo.addToCartList(getItems);
    update();
  }

  var _products = {}.obs;

  addProduct(SpecialtyModel specialty) {
    if (_products.containsKey(specialty)) {
      _products[specialty] += 1;
    } else {
      _products[specialty] = 1;
    }
  }

  bool existInCart(SpecialtyModel, specialty) {
    if (_items.containsKey(specialty.id)) {
      return true;
    }
    return false;
  }

  int getQuantity(SpecialtyModel specialty) {
    var quantity = 0;
    if (_items.containsKey(specialty.id!)) {
      _items.forEach((key, value) {
        if (key == specialty.id) {
          quantity = value.quantity!;
        }
      });
    }
    return quantity;
  }

  int get totalItems {
    var totalQuantity = 0;
    _items.forEach((key, value) {
      totalQuantity += value.quantity!;
    });
    return totalQuantity;
  }

  List<CartModel> get getItems {
    return _items.entries.map((e) {
      return e.value;
    }).toList();
  }

  int get totalAmount {
    var total = 0;

    _items.forEach((key, value) {
      total += value.quantity! * value.price!;
    });
    return total;
  }

  List<CartModel> getCartData() {
    setCart = cartRepo.getCartList();
    return storageItems;
  }

  set setCart(List<CartModel> items) {
    storageItems = items;
    // print('Length of cart items ' + storageItems.length.toString());
    for (int i = 0; i < storageItems.length; i++) {
      _items.putIfAbsent(storageItems[i].specialty!.id!, () => storageItems[i]);
    }
  }

  void addToHistory() {
    cartRepo.addToCartHistoryList();
    clear();
  }

  void clear() {
    _items = {};
    update();
  }

  List<CartModel> getCartHistoryList() {
    return cartRepo.getCartHistoryList();
  }

  set setItems(Map<int, CartModel> setItems) {
    _items = {};

    _items = setItems;
  }

  void addToCartList() {
    cartRepo.addToCartList(getItems);
    update();
  }

  void clearCartHistory() {
    cartRepo.clearCartHistory();
    update();
  }
}
