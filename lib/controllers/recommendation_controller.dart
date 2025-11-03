// lib/controllers/recommendation_controller.dart
import 'dart:async'; // Add this import
import 'package:get/get.dart';
import 'package:izinto/controllers/carpet_care_specialty_controller.dart';
import 'package:izinto/controllers/gas_refill_specialty_controller.dart';
import 'package:izinto/controllers/laundry_specialty_controller.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/controllers/pet_care_specialty_controller.dart';
import 'package:izinto/models/new_specialty_model.dart';

import '../models/new_cart_model.dart';

class RecommendationController extends GetxController {
  final RxList<NewSpecialtyModel> _recommendations = <NewSpecialtyModel>[].obs;
  List<NewSpecialtyModel> get recommendations => _recommendations;

  final _cartController = Get.find<NewCartController>();
  var _lastCartHash = '';
  Timer? _cartPollingTimer; // Add timer reference

  @override
  void onInit() {
    super.onInit();
    _loadInitialRecommendations();
    _startCartPolling();
  }

  @override
  void onClose() {
    _cartPollingTimer?.cancel(); // Clean up timer
    super.onClose();
  }

  void _startCartPolling() {
    // Fixed: Use Timer.periodic instead of Rx.periodic
    _cartPollingTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _refreshRecommendations();
    });
  }

  void _loadInitialRecommendations() {
    _refreshRecommendations();
  }

// In RecommendationController, update the _refreshRecommendations method:
  void _refreshRecommendations() {
    final cartItems = _cartController.getItems;

    if (cartItems.isEmpty) {
      _recommendations.value = _getPopularItems();
      return;
    }

    final strategy = _analyzeCart(cartItems);
    final newRecommendations =
        _getStrategyBasedRecommendations(strategy, _cartController);

    final cartItemIds = cartItems.map((e) => e.id).toSet();
    var filteredRecommendations = newRecommendations
        .where((item) => !cartItemIds.contains(item.id))
        .toList();

    // ✅ Ensure we always have at least 6 items
    if (filteredRecommendations.length < 6) {
      final additionalItems = _getFallbackItems(cartItemIds);
      filteredRecommendations.addAll(additionalItems);

      // Remove duplicates and ensure we have exactly 6 items
      final seenIds = <int>{};
      filteredRecommendations = filteredRecommendations
          .where((item) => seenIds.add(item.id!))
          .take(6)
          .toList();
    }

    _recommendations.value = filteredRecommendations;
  }

// Add this fallback method to get additional items when needed
  List<NewSpecialtyModel> _getFallbackItems(Set<int?> cartItemIds) {
    final fallbackItems = <NewSpecialtyModel>[];

    // Get items from all categories that aren't in cart
    final allCategories = [
      Get.find<LaundrySpecialtyController>().laundrySpecialtyList,
      Get.find<GasRefillSpecialtyController>().gasRefillSpecialtyList,
      Get.find<CarpetCareSpecialtyController>().carpetCareSpecialtyList,
      Get.find<PetCareSpecialtyController>().petCareSpecialtyList,
    ];

    for (var category in allCategories) {
      final availableItems =
          category.where((item) => !cartItemIds.contains(item.id)).toList();
      fallbackItems.addAll(availableItems);
    }

    return fallbackItems..shuffle();
  }

// Also update _getStrategyBasedRecommendations to return more items initially
  List<NewSpecialtyModel> _getStrategyBasedRecommendations(
      RecommendationStrategy strategy, NewCartController cartController) {
    final cartItemIds = cartController.getItems.map((e) => e.id).toSet();
    final allItems = <NewSpecialtyModel>[];

    switch (strategy) {
      case RecommendationStrategy.laundryFocused:
        final laundryItems = Get.find<LaundrySpecialtyController>()
            .laundrySpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .toList();
        final homeCareItems = Get.find<CarpetCareSpecialtyController>()
            .carpetCareSpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .toList();

        // ✅ Get more items initially (8 instead of 6)
        allItems.addAll(laundryItems.take(6)); // Increased from 4
        allItems.addAll(homeCareItems.take(2)); // Increased from 2
        break;

      case RecommendationStrategy.petFocused:
        final petItems = Get.find<PetCareSpecialtyController>()
            .petCareSpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .toList();
        final homeCareItems = Get.find<CarpetCareSpecialtyController>()
            .carpetCareSpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .toList();

        allItems.addAll(petItems.take(5)); // Increased from 4
        allItems.addAll(homeCareItems.take(3)); // Increased from 2
        break;

      case RecommendationStrategy.homeCareFocused:
        final homeCareItems = Get.find<CarpetCareSpecialtyController>()
            .carpetCareSpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .toList();
        final laundryItems = Get.find<LaundrySpecialtyController>()
            .laundrySpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .toList();

        allItems.addAll(homeCareItems.take(5)); // Increased from 4
        allItems.addAll(laundryItems.take(3)); // Increased from 2
        break;

      case RecommendationStrategy.gasFocused:
        final gasItems = Get.find<GasRefillSpecialtyController>()
            .gasRefillSpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .toList();
        final homeCareItems = Get.find<CarpetCareSpecialtyController>()
            .carpetCareSpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .toList();
        final laundryItems = Get.find<LaundrySpecialtyController>()
            .laundrySpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .toList();

        allItems.addAll(gasItems.take(4)); // Increased from 3
        allItems.addAll(homeCareItems.take(3)); // Increased from 2
        allItems.addAll(laundryItems.take(2)); // Increased from 1
        break;

      case RecommendationStrategy.mixed:
        allItems.addAll(Get.find<LaundrySpecialtyController>()
            .laundrySpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .take(3)); // Increased from 2
        allItems.addAll(Get.find<GasRefillSpecialtyController>()
            .gasRefillSpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .take(2)); // Increased from 1
        allItems.addAll(Get.find<CarpetCareSpecialtyController>()
            .carpetCareSpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .take(3)); // Increased from 2
        allItems.addAll(Get.find<PetCareSpecialtyController>()
            .petCareSpecialtyList
            .where((item) => !cartItemIds.contains(item.id))
            .take(2)); // Increased from 1
        break;

      case RecommendationStrategy.popular:
        allItems.addAll(_getPopularItems());
        break;
    }

    return allItems..shuffle();
  }

// Update _getPopularItems to return more items
  List<NewSpecialtyModel> _getPopularItems() {
    final allItems = <NewSpecialtyModel>[];

    // Get more popular items from each category
    allItems.addAll(
        Get.find<LaundrySpecialtyController>().laundrySpecialtyList.take(3));
    allItems.addAll(Get.find<GasRefillSpecialtyController>()
        .gasRefillSpecialtyList
        .take(2));
    allItems.addAll(Get.find<CarpetCareSpecialtyController>()
        .carpetCareSpecialtyList
        .take(3));
    allItems.addAll(
        Get.find<PetCareSpecialtyController>().petCareSpecialtyList.take(2));

    return allItems..shuffle();
  }

  List<NewSpecialtyModel> getRecommendedItems() {
    return _recommendations;
  }

  RecommendationStrategy _analyzeCart(List<NewCartModel> cartItems) {
    Map<String, int> categoryWeights = {
      'laundry': 0,
      'homecare': 0,
      'pet': 0,
      'gas': 0,
    };

    for (var item in cartItems) {
      final specialty = item.specialty;
      if (specialty is Map) {
        final type = specialty['type']?.toString().toLowerCase() ?? '';
        final name = specialty['name']?.toString().toLowerCase() ?? '';
        final quantity = item.quantity ?? 1;

        if (type.contains('laundry') ||
            name.contains('laundry') ||
            type.contains('wash') ||
            name.contains('wash')) {
          categoryWeights['laundry'] =
              categoryWeights['laundry']! + (quantity * 2);
        } else if (type.contains('carpet') ||
            name.contains('carpet') ||
            type.contains('curtain') ||
            name.contains('curtain') ||
            type.contains('leather') ||
            name.contains('leather care')) {
          categoryWeights['homecare'] =
              categoryWeights['homecare']! + (quantity * 2);
        } else if (type.contains('pet') || name.contains('pet')) {
          categoryWeights['pet'] = categoryWeights['pet']! + (quantity * 3);
        } else if (type.contains('gas') || name.contains('gas')) {
          categoryWeights['gas'] = categoryWeights['gas']! + (quantity * 2);
        }
      }
    }

    final dominantEntry =
        categoryWeights.entries.reduce((a, b) => a.value > b.value ? a : b);

    if (dominantEntry.value == 0) return RecommendationStrategy.popular;
    if (dominantEntry.value < 2) return RecommendationStrategy.mixed;

    switch (dominantEntry.key) {
      case 'laundry':
        return RecommendationStrategy.laundryFocused;
      case 'homecare':
        return RecommendationStrategy.homeCareFocused;
      case 'pet':
        return RecommendationStrategy.petFocused;
      case 'gas':
        return RecommendationStrategy.gasFocused;
      default:
        return RecommendationStrategy.mixed;
    }
  }

  void onItemAddedToCart() {
    _refreshRecommendations();
  }
}

enum RecommendationStrategy {
  popular,
  laundryFocused,
  homeCareFocused,
  petFocused,
  gasFocused,
  mixed
}
