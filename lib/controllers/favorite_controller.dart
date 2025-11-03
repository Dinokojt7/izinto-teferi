// lib/controllers/favorite_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteController extends GetxController {
  final RxMap<int, dynamic> _favorites = <int, dynamic>{}.obs;
  Map<int, dynamic> get favorites => _favorites;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      final Map<String, dynamic> favoritesMap = json.decode(favoritesJson);
      _favorites.addAll(
          favoritesMap.map((key, value) => MapEntry(int.parse(key), value)));
    }
  }

  void _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = json.encode(
        _favorites.map((key, value) => MapEntry(key.toString(), value)));
    prefs.setString('favorites', favoritesJson);
  }

  bool isFavorite(int? itemId) {
    return itemId != null && _favorites.containsKey(itemId);
  }

  void toggleFavorite(dynamic item) {
    if (item.id == null) return;

    if (_favorites.containsKey(item.id)) {
      _favorites.remove(item.id);
    } else {
      _favorites[item.id!] = item;
    }
    _saveFavorites();
    update();
  }

  List<dynamic> getFavoriteItems() {
    return _favorites.values.toList();
  }
}
