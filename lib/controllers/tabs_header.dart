import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../helpers/data/repository/tabs_header_repo.dart';
import '../models/popular_specialty_model.dart';

class TabsHeaderController extends GetxController {
  final TabsHeaderRepo tabsHeaderRepo;
  TabsHeaderController({required this.tabsHeaderRepo});

  // Use Rx for reactive state management
  final RxList<dynamic> _tabsHeaderList = <dynamic>[].obs;
  List<dynamic> get tabsHeaderList => _tabsHeaderList;

  final RxBool _isLoaded = false.obs;
  bool get isLoaded => _isLoaded.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    getTabsHeaderList();
  }

  Future<void> getTabsHeaderList({bool forceRefresh = false}) async {
    if (_isLoading.value || (_isLoaded.value && !forceRefresh)) {
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      Response response = await tabsHeaderRepo.getTabsHeaderList();

      if (response.statusCode == 200) {
        _tabsHeaderList.clear();
        _tabsHeaderList.addAll(Specialty.fromJson(response.body).specialties);
        _isLoaded.value = true;
        _errorMessage.value = '';

        if (kDebugMode) {
          print(
              '✅ TabsHeaderController: Loaded ${_tabsHeaderList.length} tabs');
          if (_tabsHeaderList.isNotEmpty) {
            final firstTab = _tabsHeaderList.first;

          }
        }
      } else {
        _handleError(
            'Failed to load tabs header: ${response.statusCode} ${response.statusText}');
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

    }

    // Auto-retry after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (!_isLoaded.value && !_isLoading.value) {
        getTabsHeaderList();
      }
    });
  }

  // Retry method for manual retry
  void retryLoading() {
    getTabsHeaderList(forceRefresh: true);
  }

  // Clear error method
  void clearError() {
    _errorMessage.value = '';
  }

  // Helper to safely access item properties regardless of model type
  String _getItemName(dynamic item) {
    try {
      if (item == null) return 'Unknown';

      // Handle different model types safely
      if (item is SpecialtyModel) return item.name ?? 'Unknown';
      if (item is Map) return item['name']?.toString() ?? 'Unknown';

      // Try to access name property dynamically
      if (item.name != null) return item.name.toString();

      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Public method to get item name safely
  String getItemName(dynamic item) {
    return _getItemName(item);
  }

  // Helper to get item by ID
  dynamic getItemById(int id) {
    try {
      return _tabsHeaderList.firstWhere((item) {
        final itemId = _getPropertySafely(item, 'id');
        return itemId == id;
      });
    } catch (e) {
      return null;
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

  // Check if we have valid tabs data
  bool get hasTabs => _tabsHeaderList.isNotEmpty;

  // Get tab names for debugging
  List<String> get tabNames {
    return _tabsHeaderList.map((item) => _getItemName(item)).toList();
  }
}
