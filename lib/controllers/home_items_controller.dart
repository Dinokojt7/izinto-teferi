import 'package:get/get.dart';
import '../helpers/data/repository/home_items_repo.dart';
import '../models/new_specialty_model.dart'; // CHANGE: Import new model

class HomeItemsController extends GetxController {
  final HomeItemsRepo homeItemsRepo;
  HomeItemsController({required this.homeItemsRepo});

  List<NewSpecialtyModel> _homeItemsList = []; // CHANGE: Use NewSpecialtyModel
  List<NewSpecialtyModel> get homeItemsList => _homeItemsList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getHomeItemsList() async {
    Response response = await homeItemsRepo.getHomeItemsList();
    if (response.statusCode == 200) {
      _homeItemsList = [];
      _homeItemsList.addAll(NewSpecialty.fromJson(response.body)
          .specialties); // CHANGE: Use NewSpecialty
      _isLoaded = true;

      // Debug: Print first item to verify new model works
      if (_homeItemsList.isNotEmpty) {
        final firstItem = _homeItemsList.first;
        print(
            '✅ HomeItems: Loaded ${_homeItemsList.length} items with new model');
        print(
            '✅ First item: ${firstItem.name}, Price: ${firstItem.price}, First Price: ${firstItem.firstPrice}');
      }

      update();
    } else {
      print('home items controller is not working ${response.statusCode}');
    }
  }
}
