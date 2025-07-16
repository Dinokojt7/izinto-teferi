import 'package:get/get.dart';
import '../helpers/data/repository/tabs_header_repo.dart';
import '../models/cart_model.dart';
import '../models/popular_specialty_model.dart';
import 'cart_controller.dart';
import '../helpers/data/repository/cart_repo.dart';

class TabsHeaderController extends GetxController {
  final TabsHeaderRepo tabsHeaderRepo;
  TabsHeaderController({required this.tabsHeaderRepo});
  List<dynamic> _tabsHeaderList = [];
  List<dynamic> get tabsHeaderList => _tabsHeaderList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getTabsHeaderList() async {
    Response response = await tabsHeaderRepo.getTabsHeaderList();
    if (response.statusCode == 200) {
      _tabsHeaderList = [];
      _tabsHeaderList.addAll(Specialty.fromJson(response.body).specialties);
      _isLoaded = true;
      update();
    } else {
      print('tabs header is ${response.statusCode}');
    }
  }
}
