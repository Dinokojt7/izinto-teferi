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

  void addToCartList(List<CartModel> cartList) {
    sharedPreferences.remove(AppConstants.CART_LIST);
    sharedPreferences.remove(AppConstants.CART_HISTORY_LIST);
    var time = DateTime.now().toString();
    cart = [];
    /*
      convert objects to string because shared preferences only accepts string
     */

    cartList.forEach((element) {
      element.time = time;
      return cart.add(jsonEncode(element));
    });

    sharedPreferences.setStringList(AppConstants.CART_LIST, cart);
    // print(sharedPreferences.getStringList(AppConstants.CART_LIST));
    // getCartList();
  }

  List<CartModel> getCartList() {
    List<String> carts = [];
    if (sharedPreferences.containsKey(AppConstants.CART_LIST)) {
      carts = sharedPreferences.getStringList(AppConstants.CART_LIST)!;
      // print('inside getCartList ' + carts.toString());
    }
    List<CartModel> cartList = [];

    carts.forEach(
        (element) => cartList.add(CartModel.fromJson(jsonDecode(element))));

    return cartList;
  }

  List<CartModel> getCartHistoryList() {
    if (sharedPreferences.containsKey(AppConstants.CART_HISTORY_LIST)) {
      // cartHistory = [];
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
      print('history list ' + cart[i]);
      cartHistory.add(cart[i]);
    }
    removeCart();
    sharedPreferences.setStringList(
        AppConstants.CART_HISTORY_LIST, cartHistory);
    print('The length of history list is ' +
        getCartHistoryList().length.toString());
    for (int j = 0; j < getCartHistoryList().length; j++) {
      print('The time for the order is ' +
          getCartHistoryList()[j].time.toString());
    }
  }

  void removeCart() {
    cart = [];
    sharedPreferences.remove(AppConstants.CART_LIST);
  }

  void clearCartHistory() {
    removeCart();
    cartHistory = [];
    sharedPreferences.remove(AppConstants.CART_HISTORY_LIST);
  }

  // Add to existing CartRepo class
  Future<void> addToNewCartList(List<NewCartModel> cartList) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJsonList =
        cartList.map((item) => json.encode(item.toJson())).toList();
    prefs.setStringList(AppConstants.NEW_CART_LIST, cartJsonList);
  }

  Future<List<NewCartModel>> getNewCartList() async {
    final prefs = await SharedPreferences.getInstance();
    final cartList = prefs.getStringList(AppConstants.NEW_CART_LIST) ?? [];
    return cartList
        .map((item) => NewCartModel.fromJson(json.decode(item)))
        .toList();
  }

// Migration function
  Future<void> migrateOldCartToNew() async {
    final prefs = await SharedPreferences.getInstance();
    final useNewModels = prefs.getBool(AppConstants.USE_NEW_MODELS) ?? false;

    if (!useNewModels) return; // Only migrate once

    final oldCart = await getCartList();
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

    await addToNewCartList(newCart);
    // Optionally clear old cart
    // await prefs.remove(AppConstants.CART_LIST);
  }
}
