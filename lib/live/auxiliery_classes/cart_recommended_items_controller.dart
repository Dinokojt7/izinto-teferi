import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/recommendation_controller.dart';
import 'package:izinto/models/new_specialty_model.dart';

class CartRecommendedItemsController extends ChangeNotifier {
  final RecommendationController _recommendationController = Get.find();

  List<NewSpecialtyModel> get recommended =>
      _recommendationController.recommendations;

  List<Map<String, dynamic>> getRecommendedForUI() {
    return recommended.map((item) {
      return {
        'img': item.img ?? 'assets/image/placeholder.png',
        'price': item.firstPrice,
        'introduction': item.introduction ?? '',
        'type': item.type ?? '',
        'name': item.name ?? '',
        'specialty': item,
      };
    }).toList();
  }

  // Add this method to update recommendations
  void updateRecommendations(List<NewSpecialtyModel> items) {
    // This is now handled by the reactive RecommendationController
    notifyListeners();
  }

  // Call this when item is added from recommendations
  void onRecommendedItemAdded() {
    _recommendationController.onItemAddedToCart();
    notifyListeners();
  }
}
