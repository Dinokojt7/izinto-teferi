import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:izinto/helpers/data/repository/popular_specialty_repo.dart';
import '../models/popular_specialty_model.dart';

class PopularSpecialtyController extends GetxController {
  final PopularSpecialtyRepo popularSpecialtyRepo;
  PopularSpecialtyController({required this.popularSpecialtyRepo});

  // Use Rx for reactive state management
  final RxList<dynamic> _popularSpecialtyList = <dynamic>[].obs;
  List<dynamic> get popularSpecialtyList => _popularSpecialtyList;

  final RxBool _isLoaded = false.obs;
  bool get isLoaded => _isLoaded.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    getPopularSpecialtyList();
  }

  Future<void> getPopularSpecialtyList({bool forceRefresh = false}) async {
    if (_isLoading.value || (_isLoaded.value && !forceRefresh)) {
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      Response response = await popularSpecialtyRepo.getPopularSpecialtyList();

      if (response.statusCode == 200) {
        _popularSpecialtyList.clear();
        _popularSpecialtyList
            .addAll(Specialty.fromJson(response.body).specialties);
        _isLoaded.value = true;

        if (kDebugMode) {
          print(
              '✅ PopularSpecialtyController: Loaded ${_popularSpecialtyList.length} items');
          if (_popularSpecialtyList.isNotEmpty) {
            final firstItem = _popularSpecialtyList.first;
            print(
                '✅ First popular item: ${firstItem.name}, Type: ${firstItem.runtimeType}');
          }
        }
      } else {
        _handleError(
            'Failed to load popular specialties: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Network error: $e');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  void _handleError(String message) {
    _errorMessage.value = message;
    if (kDebugMode) {
      print('PopularSpecialtyController Error: $message');
    }

    // Auto-retry after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (!_isLoaded.value && !_isLoading.value) {
        getPopularSpecialtyList();
      }
    });
  }

  // Retry method for manual retry
  void retryLoading() {
    getPopularSpecialtyList(forceRefresh: true);
  }

  // Clear error method
  void clearError() {
    _errorMessage.value = '';
  }

  // Helper to safely access item properties regardless of model type
  String getItemName(dynamic item) {
    try {
      if (item == null) return 'Unknown';

      // Try to access name property using different approaches
      if (item is SpecialtyModel) return item.name ?? 'Unknown';
      if (item is Map) return item['name']?.toString() ?? 'Unknown';

      // Fallback: try to access name via reflection
      final name = _getPropertySafely(item, 'name');
      return name?.toString() ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  dynamic _getPropertySafely(dynamic item, String property) {
    try {
      // Try direct access
      if (item is Map) return item[property];

      // Try using reflection-like approach
      final dynamic value = _getDynamicProperty(item, property);
      return value;
    } catch (e) {
      return null;
    }
  }

  dynamic _getDynamicProperty(dynamic item, String property) {
    try {
      // This is a safe way to try to access properties on dynamic objects
      if (item == null) return null;

      // Convert to map if possible
      if (item is Map) return item[property];

      // Try to access via toJson if available
      if (item.toJson != null) {
        final Map<String, dynamic> json = item.toJson();
        return json[property];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper to get item by ID
  dynamic getItemById(int id) {
    try {
      return _popularSpecialtyList.firstWhere((item) {
        final itemId = _getPropertySafely(item, 'id');
        return itemId == id;
      });
    } catch (e) {
      return null;
    }
  }
}
