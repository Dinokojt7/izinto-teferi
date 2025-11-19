import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:izinto/helpers/data/repository/pet_care_specialty_repo.dart';
import 'package:izinto/models/new_specialty_model.dart';

class PetCareSpecialtyController extends GetxController {
  final PetCareSpecialtyRepo petCareRepo;

  PetCareSpecialtyController({
    required this.petCareRepo,
  });

  final RxList<NewSpecialtyModel> _petCareSpecialtyList =
      <NewSpecialtyModel>[].obs;
  List<NewSpecialtyModel> get petCareSpecialtyList => _petCareSpecialtyList;

  final RxBool _isLoaded = false.obs;
  bool get isLoaded => _isLoaded.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Use delayed initialization to avoid race conditions
    Future.microtask(() => getPetCareSpecialtyList());
  }

  @override
  void onClose() {
    // Don't manually close Rx variables - GetX handles this
    // Just clear the data if needed
    _petCareSpecialtyList.clear();
    super.onClose();
  }

  Future<void> getPetCareSpecialtyList({bool forceRefresh = false}) async {
    if (_isLoading.value || (_isLoaded.value && !forceRefresh)) {
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      Response response = await petCareRepo.getPetCareSpecialtyList();

      if (response.statusCode == 200) {
        _petCareSpecialtyList.clear();
        final specialties = NewSpecialty.fromJson(response.body).specialties;
        _petCareSpecialtyList.addAll(specialties);
        _isLoaded.value = true;

        if (kDebugMode) {
          print(
              'Pet Care specialty list loaded successfully: ${_petCareSpecialtyList.length} items');
        }
      } else {
        _handleError(
            'Failed to load pet care specialties: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Network error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _handleError(String message) {
    _errorMessage.value = message;
    if (kDebugMode) {
      print('PetCareSpecialtyController Error: $message');
    }

    // Auto-retry after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (!_isLoaded.value && !_isLoading.value) {
        getPetCareSpecialtyList();
      }
    });
  }

  // Retry method for manual retry
  void retryLoading() {
    getPetCareSpecialtyList(forceRefresh: true);
  }

  // Clear error method
  void clearError() {
    _errorMessage.value = '';
  }

  // Helper method to ensure list is never null
  List<NewSpecialtyModel> getSafePetCareList() {
    return _petCareSpecialtyList.isEmpty ? [] : _petCareSpecialtyList;
  }

  // Check if list is ready to use
  bool get isListReady => _isLoaded.value && _petCareSpecialtyList.isNotEmpty;
}
