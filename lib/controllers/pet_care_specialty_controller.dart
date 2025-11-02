import 'package:get/get.dart';
import 'package:izinto/helpers/data/repository/pet_care_specialty_repo.dart';
import 'package:izinto/models/new_specialty_model.dart';
import 'package:izinto/models/new_cart_model.dart';
import '../helpers/data/repository/cart_repo.dart';
import '../live/utilities/price_helper.dart';

class PetCareSpecialtyController extends GetxController {
  final PetCareSpecialtyRepo petCareRepo;
  final CartRepo cartRepo;
  PetCareSpecialtyController({
    required this.cartRepo,
    required this.petCareRepo,
  });

  Map<int, NewCartModel> _items = {};
  List<NewSpecialtyModel> _petCareSpecialtyList = [];
  List<NewSpecialtyModel> get petCareSpecialtyList => _petCareSpecialtyList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;
  int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  Map<int, NewCartModel> get getItems => _items;

  Future<void> getPetCareSpecialtyList() async {
    Response response = await petCareRepo.getPetCareSpecialtyList();
    if (response.statusCode == 200) {
      _petCareSpecialtyList = [];
      _petCareSpecialtyList
          .addAll(NewSpecialty.fromJson(response.body).specialties);
      _isLoaded = true;
      update();
    } else {
      print('Pet Care not working ${response.statusCode}');
    }
  }

  void addItem(NewSpecialtyModel specialty, int quantity) {
    var totalQuantity = 0;
    if (_items.containsKey(specialty.id!)) {
      _items.update(specialty.id!, (value) {
        totalQuantity = value.quantity! + quantity;

        return NewCartModel(
          id: value.id,
          name: value.name,
          price: PriceHelper.getPrice(specialty),
          time: DateTime.now().toString(),
          img: specialty.img,
          type: specialty.type,
          material: specialty.material,
          quantity: value.quantity! + quantity,
          isExist: true,
          provider: specialty.provider,
          specialty: specialty,
        );
      });

      if (totalQuantity <= 0) {
        _items.remove(specialty.id);
      }
    } else {
      if (quantity > 0) {
        _items.putIfAbsent(specialty.id!, () {
          return NewCartModel(
            id: specialty.id,
            name: specialty.name,
            price: PriceHelper.getPrice(specialty),
            time: DateTime.now().toString(),
            img: specialty.img,
            type: specialty.type,
            material: specialty.material,
            quantity: quantity,
            isExist: true,
            provider: specialty.provider,
            specialty: specialty,
          );
        });
      } else {
        Get.snackbar(
          'Item count 0',
          'Please select items to add to cart',
        );
      }
    }
    cartRepo.addToNewCartList(getItems.values.toList());
    update();
  }

  // ... (include the same helper methods as above: setQuantity, checkQuantity, getQuantity, existInCart)
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
      Get.snackbar(
        'Item count 0',
        'You don\'t have items',
      );
      if (_inCartItems > 0) {
        _quantity = -_inCartItems;
        return _quantity;
      }
      return 0;
    } else if ((_inCartItems + quantity) > 20) {
      Get.snackbar('Item count 20', 'Maximum number of items selected');
      return 20;
    } else {
      return quantity;
    }
  }

  int getQuantity(NewSpecialtyModel specialty) {
    return _items[specialty.id]?.quantity ?? 0;
  }

  bool existInCart(NewSpecialtyModel specialty) {
    return _items.containsKey(specialty.id);
  }
}
