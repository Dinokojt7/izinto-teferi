import 'package:get/get.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/helpers/data/repository/recommended_specialty_repo.dart';
import 'package:izinto/models/new_specialty_model.dart';

class NewRecommendedSpecialtyController extends GetxController {
  final RecommendedSpecialtyRepo recommendedSpecialtyRepo;
  NewRecommendedSpecialtyController({required this.recommendedSpecialtyRepo});

  List<NewSpecialtyModel> _recommendedSpecialtyList = [];
  List<NewSpecialtyModel> get recommendedSpecialtyList =>
      _recommendedSpecialtyList;

  late NewCartController _cart;
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;
  int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  Future<void> getRecommendedSpecialtyList() async {
    Response response =
        await recommendedSpecialtyRepo.getRecommendedSpecialtyList();
    if (response.statusCode == 200) {
      _recommendedSpecialtyList = [];
      _recommendedSpecialtyList
          .addAll(NewSpecialty.fromJson(response.body).specialties);
      _isLoaded = true;
      update();
    } else {
      print(
          'New recommended specialty controller error: ${response.statusCode}');
    }
  }

  void setQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = checkQuantity(_quantity + 1);
    } else {
      _quantity = checkQuantity(_quantity - 1);
    }
    update();
  }

  int checkQuantity(int quantity) {
    if ((_inCartItems + quantity) < 0) {
      if (_inCartItems > 0) {
        _quantity = -_inCartItems;
        return _quantity;
      }
      return 0;
    } else if ((_inCartItems + quantity) > 50) {
      Get.snackbar('Item count 50', 'Maximum number of items selected');
      return 0;
    } else {
      return quantity;
    }
  }

  void initSpecialty(NewSpecialtyModel specialty, NewCartController cart) {
    _quantity = 0;
    _inCartItems = 0;
    _cart = cart;
    if (_cart.existInCart(specialty)) {
      _inCartItems = _cart.getQuantity(specialty);
    }
  }

  void addItem(NewSpecialtyModel specialty) {
    _cart.addItem(specialty, _quantity);
    _quantity = 0;
    _inCartItems = _cart.getQuantity(specialty);
    update();
  }

  int get totalItems {
    return _cart.totalItems;
  }
}
