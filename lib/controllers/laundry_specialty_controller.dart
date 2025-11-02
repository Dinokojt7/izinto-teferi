import 'package:get/get.dart';
import 'package:izinto/helpers/data/repository/laundry_specialty_repo.dart';
import 'package:izinto/models/new_specialty_model.dart'; // ADD: Import new model
import 'package:izinto/models/new_cart_model.dart'; // ADD: Import new cart model

import '../helpers/data/repository/cart_repo.dart';
import '../live/utilities/price_helper.dart'; // ADD: Import price helper

class LaundrySpecialtyController extends GetxController {
  final LaundrySpecialtyRepo laundrySpecialtyRepo;
  final CartRepo cartRepo;
  LaundrySpecialtyController(
      {required this.cartRepo, required this.laundrySpecialtyRepo});

  Map<int, NewCartModel> _items = {}; // CHANGE: Use NewCartModel

  List<NewSpecialtyModel> _laundrySpecialtyList =
      []; // CHANGE: Use NewSpecialtyModel
  List<NewSpecialtyModel> get laundrySpecialtyList => _laundrySpecialtyList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;
  int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  Map<int, NewCartModel> get getItems => _items; // CHANGE: Return type

  Future<void> getLaundrySpecialtyList() async {
    Response response = await laundrySpecialtyRepo.getLaundrySpecialtyList();
    if (response.statusCode == 200) {
      _laundrySpecialtyList = [];
      _laundrySpecialtyList.addAll(NewSpecialty.fromJson(response.body)
          .specialties); // CHANGE: Use NewSpecialty
      _isLoaded = true;
      update();
    } else {
      print('laundry not working ${response.statusCode}');
    }
  }

  void addItem(NewSpecialtyModel specialty, int quantity) {
    // CHANGE: Parameter type
    var totalQuantity = 0;
    if (_items.containsKey(specialty.id!)) {
      _items.update(specialty.id!, (value) {
        totalQuantity = value.quantity! + quantity;

        return NewCartModel(
          // CHANGE: Use NewCartModel
          id: value.id,
          name: value.name,
          price: PriceHelper.getPrice(specialty), // CHANGE: Use price helper
          time: DateTime.now().toString(),
          img: specialty.img, // FIXED: Use specialty.img not value.img
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
            // CHANGE: Use NewCartModel
            id: specialty.id,
            name: specialty.name,
            price: PriceHelper.getPrice(specialty), // CHANGE: Use price helper
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
// MAY NEED ADJUSTMENT: Convert map to list
    update();
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

  // ADD: Helper method to get quantity for a specialty
  int getQuantity(NewSpecialtyModel specialty) {
    return _items[specialty.id]?.quantity ?? 0;
  }

  // ADD: Helper method to check if item exists in cart
  bool existInCart(NewSpecialtyModel specialty) {
    return _items.containsKey(specialty.id);
  }
}
