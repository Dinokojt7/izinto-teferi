import 'package:get/get.dart';
import '../helpers/data/repository/home_items_repo.dart';
import '../models/popular_specialty_model.dart';

class HomeItemsController extends GetxController {
  final HomeItemsRepo homeItemsRepo;
  HomeItemsController({required this.homeItemsRepo});
  List<dynamic> _homeItemsRepoList = [];
  List<dynamic> get homeItemsRepoList => _homeItemsRepoList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getHomeItemsList() async {
    Response response = await homeItemsRepo.getHomeItemsList();
    if (response.statusCode == 200) {
      _homeItemsRepoList = [];
      _homeItemsRepoList.addAll(Specialty.fromJson(response.body).specialties);

      _isLoaded = true;
      update();
    } else {
      print('home items controller is not working ${response.statusCode}');
    }
  }
}
