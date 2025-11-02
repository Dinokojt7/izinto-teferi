import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/cart_model.dart';
import '../../../models/new_cart_model.dart';
import '../../../utils/app_constants.dart';

class CartRepo {
  final SharedPreferences sharedPreferences;
  CartRepo({required this.sharedPreferences});

  List<String> cart = [];
  List<String> cartHistory = [];

  // ORIGINAL METHOD: For old CartModel
  void addToCartList(List<CartModel> cartList) {
    sharedPreferences.remove(AppConstants.CART_LIST);
    sharedPreferences.remove(AppConstants.CART_HISTORY_LIST);
    var time = DateTime.now().toString();
    cart = [];

    cartList.forEach((element) {
      element.time = time;
      return cart.add(jsonEncode(element));
    });

    sharedPreferences.setStringList(AppConstants.CART_LIST, cart);
  }

  // NEW METHOD: For NewCartModel
  void addToNewCartList(List<NewCartModel> cartList) {
    sharedPreferences.remove(AppConstants.NEW_CART_LIST);
    var time = DateTime.now().toString();
    final newCart = <String>[];

    cartList.forEach((element) {
      // If time is not set, set it
      if (element.time == null) {
        element.time = time;
      }
      return newCart.add(jsonEncode(element.toJson()));
    });

    sharedPreferences.setStringList(AppConstants.NEW_CART_LIST, newCart);
  }

  // ORIGINAL: Get old cart list
  List<CartModel> getCartList() {
    List<String> carts = [];
    if (sharedPreferences.containsKey(AppConstants.CART_LIST)) {
      carts = sharedPreferences.getStringList(AppConstants.CART_LIST)!;
    }
    List<CartModel> cartList = [];

    carts.forEach(
        (element) => cartList.add(CartModel.fromJson(jsonDecode(element))));

    return cartList;
  }

  // NEW: Get new cart list
  List<NewCartModel> getNewCartList() {
    List<String> carts = [];
    if (sharedPreferences.containsKey(AppConstants.NEW_CART_LIST)) {
      carts = sharedPreferences.getStringList(AppConstants.NEW_CART_LIST)!;
    }
    List<NewCartModel> cartList = [];

    carts.forEach(
        (element) => cartList.add(NewCartModel.fromJson(jsonDecode(element))));

    return cartList;
  }

  // UNIVERSAL METHOD: Handles both old and new models dynamically
  void addToCartListUniversal(List<dynamic> cartList) {
    if (cartList.isEmpty) return;

    if (cartList.first is NewCartModel) {
      addToNewCartList(cartList.cast<NewCartModel>());
    } else if (cartList.first is CartModel) {
      addToCartList(cartList.cast<CartModel>());
    }
  }

  List<CartModel> getCartHistoryList() {
    if (sharedPreferences.containsKey(AppConstants.CART_HISTORY_LIST)) {
      cartHistory =
          sharedPreferences.getStringList(AppConstants.CART_HISTORY_LIST)!;
    }

    List<CartModel> cartListHistory = [];
    cartHistory.forEach((element) =>
        cartListHistory.add(CartModel.fromJson(jsonDecode(element))));
    return cartListHistory;
  }

  void addToCartHistoryList() {
    if (sharedPreferences.containsKey(AppConstants.CART_HISTORY_LIST)) {
      cartHistory =
          sharedPreferences.getStringList(AppConstants.CART_HISTORY_LIST)!;
    }
    for (int i = 0; i < cart.length; i++) {
      cartHistory.add(cart[i]);
    }
    removeCart();
    sharedPreferences.setStringList(
        AppConstants.CART_HISTORY_LIST, cartHistory);
  }

  void removeCart() {
    cart = [];
    sharedPreferences.remove(AppConstants.CART_LIST);
  }

  void removeNewCart() {
    sharedPreferences.remove(AppConstants.NEW_CART_LIST);
  }

  void clearCartHistory() {
    removeCart();
    removeNewCart();
    cartHistory = [];
    sharedPreferences.remove(AppConstants.CART_HISTORY_LIST);
  }

  // Migration function
  Future<void> migrateOldCartToNew() async {
    final oldCart = getCartList();
    if (oldCart.isEmpty) return;

    final newCart = <NewCartModel>[];

    for (var oldItem in oldCart) {
      final newItem = NewCartModel(
        id: oldItem.id,
        name: oldItem.name,
        price: oldItem.price,
        time: oldItem.time,
        img: oldItem.img,
        type: oldItem.type,
        material: oldItem.material,
        quantity: oldItem.quantity,
        isExist: oldItem.isExist,
        provider: oldItem.provider,
        specialty: oldItem.specialty,
      );
      newCart.add(newItem);
    }

    addToNewCartList(newCart);
    print('✅ Migrated ${newCart.length} items from old cart to new cart');
  }
}
