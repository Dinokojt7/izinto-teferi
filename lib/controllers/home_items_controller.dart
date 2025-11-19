import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../helpers/data/repository/home_items_repo.dart';
import '../models/new_specialty_model.dart';

class HomeItemsController extends GetxController {
  final HomeItemsRepo homeItemsRepo;
  HomeItemsController({required this.homeItemsRepo});

  // Use Rx for reactive state management
  final RxList<NewSpecialtyModel> _homeItemsList = <NewSpecialtyModel>[].obs;
  List<NewSpecialtyModel> get homeItemsList => _homeItemsList;

  final RxBool _isLoaded = false.obs;
  bool get isLoaded => _isLoaded.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    getHomeItemsList();
  }

  Future<void> getHomeItemsList({bool forceRefresh = false}) async {
    if (_isLoading.value || (_isLoaded.value && !forceRefresh)) {
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      Response response = await homeItemsRepo.getHomeItemsList();

      if (response.statusCode == 200) {
        _homeItemsList.clear();
        _homeItemsList.addAll(NewSpecialty.fromJson(response.body).specialties);
        _isLoaded.value = true;
        _errorMessage.value = '';

        // Debug information
        if (kDebugMode) {
          print(
              '✅ HomeItems: Loaded ${_homeItemsList.length} items with new model');
          if (_homeItemsList.isNotEmpty) {
            final firstItem = _homeItemsList.first;
            print(
                '✅ First item: ${firstItem.name}, Price: ${firstItem.price}, First Price: ${firstItem.firstPrice}');
          }
        }
      } else {
        _handleError('Failed to load home items: ${response.statusCode}');
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
        getHomeItemsList();
      }
    });
  }

  // Retry method for manual retry
  void retryLoading() {
    getHomeItemsList(forceRefresh: true);
  }

  // Clear error method
  void clearError() {
    _errorMessage.value = '';
  }

  // Helper to get item by ID
  NewSpecialtyModel? getItemById(int id) {
    try {
      return _homeItemsList.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}
