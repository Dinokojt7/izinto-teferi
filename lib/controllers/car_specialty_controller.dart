import 'package:get/get.dart';
import '../helpers/data/repository/car_specialty_repo.dart';
import '../models/popular_specialty_model.dart';

class CarSpecialtyController extends GetxController {
  final CarSpecialtyRepo carSpecialtyRepo;
  CarSpecialtyController({required this.carSpecialtyRepo});
  List<dynamic> _carSpecialtyList = [];
  List<dynamic> get carSpecialtyList => _carSpecialtyList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getCarSpecialtyList() async {
    Response response = await carSpecialtyRepo.getCarSpecialtyList();
    if (response.statusCode == 200) {
      _carSpecialtyList = [];
      _carSpecialtyList.addAll(Specialty.fromJson(response.body).specialties);

      _isLoaded = true;
      update();
    } else {
      print('this is not working ${response.statusCode}');
    }
  }
}
