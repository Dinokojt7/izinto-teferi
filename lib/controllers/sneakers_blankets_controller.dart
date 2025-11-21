import 'package:get/get.dart';

import '../helpers/data/repository/sneakers_blankets_repo.dart';
import '../models/popular_specialty_model.dart';

class SneakersBlanketsController extends GetxController {
  final SneakersBlanketsRepo sneakersAndBlanketsRepo;
  SneakersBlanketsController({required this.sneakersAndBlanketsRepo});
  List<dynamic> _sneakersAndBlanketsList = [];
  List<dynamic> get sneakersAndBlanketsList => _sneakersAndBlanketsList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getSneakersAndBlanketsList() async {
    Response response =
        await sneakersAndBlanketsRepo.getSneakersAndBlanketsList();
    if (response.statusCode == 200) {
      _sneakersAndBlanketsList = [];
      _sneakersAndBlanketsList
          .addAll(Specialty.fromJson(response.body).specialties);

      _isLoaded = true;
      update();
    } else {}
  }
}
