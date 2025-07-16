import 'package:get/get.dart';
import 'package:izinto/helpers/data/repository/popular_specialty_repo.dart';

import '../models/popular_specialty_model.dart';

class PopularSpecialtyController extends GetxController {
  final PopularSpecialtyRepo popularSpecialtyRepo;
  PopularSpecialtyController({required this.popularSpecialtyRepo});
  List<dynamic> _popularSpecialtyList = [];
  List<dynamic> get popularSpecialtyList => _popularSpecialtyList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getPopularSpecialtyList() async {
    Response response = await popularSpecialtyRepo.getPopularSpecialtyList();
    if (response.statusCode == 200) {
      _popularSpecialtyList = [];
      _popularSpecialtyList
          .addAll(Specialty.fromJson(response.body).specialties);

      _isLoaded = true;
      update();
    } else {
      print('this is not working ${response.statusCode}');
    }
  }
}
