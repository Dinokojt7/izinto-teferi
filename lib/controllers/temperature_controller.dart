// lib/controllers/temperature_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemperatureController extends GetxController {
  final RxSet<int> _heatedItems = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHeatedItems();
  }

  void _loadHeatedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final heatedItemsJson = prefs.getStringList('heated_items');
    if (heatedItemsJson != null) {
      _heatedItems.addAll(heatedItemsJson.map((e) => int.parse(e)));
    }
  }

  void _saveHeatedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final heatedItemsJson = _heatedItems.map((e) => e.toString()).toList();
    prefs.setStringList('heated_items', heatedItemsJson);
  }

  bool isItemHeated(int? itemId) {
    return itemId != null && _heatedItems.contains(itemId);
  }

  void toggleTemperature(int? itemId) {
    if (itemId == null) return;

    if (_heatedItems.contains(itemId)) {
      _heatedItems.remove(itemId);
    } else {
      _heatedItems.add(itemId);
    }
    _saveHeatedItems();
    update();
  }
}
