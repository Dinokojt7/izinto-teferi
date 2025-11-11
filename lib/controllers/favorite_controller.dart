// lib/controllers/favorite_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/new_specialty_model.dart';

class FavoriteController extends GetxController {
  final RxMap<String, dynamic> _favorites = <String, dynamic>{}.obs;
  Map<String, dynamic> get favorites => _favorites;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  void _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites');
      if (favoritesJson != null) {
        final Map<String, dynamic> favoritesMap = json.decode(favoritesJson);
        _favorites.addAll(favoritesMap);
      }
    } catch (e) {
      print('Error loading favorites: $e');
      _favorites.clear();
    }
  }

  void _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(_favorites);
      prefs.setString('favorites', favoritesJson);
      update();
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // ✅ Generate unique favorite key with null safety
  String _getFavoriteKey(dynamic item) {
    if (item is NewSpecialtyModel && item.isSizeVariant == true) {
      // For size variants: use originalId + selectedSize with null checks
      final originalId = item.originalId ?? item.id;
      final size = item.selectedSize ?? 'default';
      return '${originalId}_$size';
    } else {
      // For regular items: use id with fallback
      final id = item.id?.toString() ?? 'unknown';
      return id;
    }
  }

  // ✅ Check if item is favorite with enhanced null safety
  bool isFavorite(dynamic item) {
    if (item == null) return false;

    final key = _getFavoriteKey(item);
    return _favorites.containsKey(key);
  }

  // ✅ Check if specific size variant is favorite
  bool isSizeVariantFavorite(int? originalId, String size) {
    if (originalId == null) return false;
    final key = '${originalId}_$size';
    return _favorites.containsKey(key);
  }

  // ✅ Check if any variant of a base product is favorite
  bool isBaseProductFavorite(int? originalId) {
    if (originalId == null) return false;
    return _favorites.keys.any((key) => key.startsWith('${originalId}_'));
  }

  // ✅ Toggle favorite with enhanced error handling
  void toggleFavorite(dynamic item) {
    if (item == null) {
      print('Cannot favorite null item');
      return;
    }

    try {
      final key = _getFavoriteKey(item);

      if (_favorites.containsKey(key)) {
        _favorites.remove(key);
      } else {
        // Safely convert to JSON with error handling
        final jsonData = _safeConvertToJson(item);
        if (jsonData != null) {
          _favorites[key] = jsonData;
        } else {
          print('Failed to convert item to JSON: $item');
          return;
        }
      }
      _saveFavorites();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // ✅ Safe JSON conversion helper
  dynamic _safeConvertToJson(dynamic item) {
    try {
      if (item is NewSpecialtyModel) {
        return item.toJson();
      } else if (item is Map<String, dynamic>) {
        return item;
      } else if (item != null && _hasToJsonMethod(item)) {
        return item.toJson();
      } else {
        return item.toString();
      }
    } catch (e) {
      print('Error in _safeConvertToJson: $e');
      return null;
    }
  }

  // ✅ Check if object has toJson method
  bool _hasToJsonMethod(dynamic item) {
    try {
      return item.toJson != null;
    } catch (e) {
      return false;
    }
  }

  // ✅ Get all favorite items with error handling
  List<dynamic> getFavoriteItems() {
    return _favorites.values
        .map((json) {
          try {
            // Try to parse as NewSpecialtyModel first
            if (json is Map<String, dynamic>) {
              return NewSpecialtyModel.fromJson(json);
            }
            return json;
          } catch (e) {
            print('Error parsing favorite item: $e');
            // Return the raw JSON if parsing fails
            return json;
          }
        })
        .where((item) => item != null)
        .toList();
  }

  // ✅ Get count of favorites
  int get favoritesCount => _favorites.length;

  // ✅ Clear all favorites
  void clearAllFavorites() {
    _favorites.clear();
    _saveFavorites();
  }

  // ✅ Remove specific favorite by key
  void removeFavoriteByKey(String key) {
    _favorites.remove(key);
    _saveFavorites();
  }

  // ✅ Clear favorites with modal confirmation
  void clearFavoritesData(
    BuildContext context,
    String headerText,
    String action,
    bool isClearAll,
    int? index,
    dynamic item,
  ) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return _buildClearFavoritesModal(
          context,
          headerText: headerText,
          action: action,
          isClearAll: isClearAll,
          onConfirm: () {
            if (isClearAll) {
              clearAllFavorites();
            } else if (item != null) {
              final key = _getFavoriteKey(item);
              removeFavoriteByKey(key);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildClearFavoritesModal(
    BuildContext context, {
    required String headerText,
    required String action,
    required bool isClearAll,
    required VoidCallback onConfirm,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),

          // Header text
          Text(
            headerText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: onConfirm,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    action,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
