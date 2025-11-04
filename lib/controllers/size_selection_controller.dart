// lib/controllers/size_selection_controller.dart
import 'package:get/get.dart';

import '../models/new_specialty_model.dart';

class SizeSelectionController extends GetxController {
  final RxMap<int, String> _selectedSizes = <int, String>{}.obs;

  String getSelectedSize(int? itemId, {List<String>? availableSizes}) {
    if (itemId == null) return '';

    // Check if we have a stored selection
    final selectedSize = _selectedSizes[itemId];
    if (selectedSize != null && selectedSize.isNotEmpty) {
      return selectedSize;
    }

    // Return first available size as default if provided
    if (availableSizes != null && availableSizes.isNotEmpty) {
      return availableSizes.first;
    }

    return '';
  }

  void selectSize(int? itemId, String size) {
    if (itemId == null) return;
    _selectedSizes[itemId] = size;
    update();
  }

  // Helper method to check if item should show size selector
  bool shouldShowSizeSelector(dynamic item) {
    if (item is! NewSpecialtyModel) return false;

    final hasMultipleSizes = item.size != null && item.size!.length > 1;
    final isDeepCleaning =
        item.material?.toLowerCase().contains('deep cleaning') ?? false;
    final isModern8Provider =
        item.provider?.toLowerCase().contains('modern8') ?? false;

    return hasMultipleSizes && (isDeepCleaning || isModern8Provider);
  }
}
