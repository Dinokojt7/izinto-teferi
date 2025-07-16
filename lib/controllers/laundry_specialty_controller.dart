import 'package:get/get.dart';
import 'package:izinto/helpers/data/repository/laundry_specialty_repo.dart';

import '../models/cart_model.dart';
import '../models/popular_specialty_model.dart';
import 'cart_controller.dart';
import '../helpers/data/repository/cart_repo.dart';

class LaundrySpecialtyController extends GetxController {
  final LaundrySpecialtyRepo laundrySpecialtyRepo;
  final CartRepo cartRepo;
  LaundrySpecialtyController(
      {required this.cartRepo, required this.laundrySpecialtyRepo});

  Map<int, CartModel> _items = {};

  List<dynamic> _laundrySpecialtyList = [];
  List<dynamic> get laundrySpecialtyList => _laundrySpecialtyList;
  late CartController _cart;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;
  int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  get getItems => _items;

  Future<void> getLaundrySpecialtyList() async {
    Response response = await laundrySpecialtyRepo.getLaundrySpecialtyList();
    if (response.statusCode == 200) {
      _laundrySpecialtyList = [];
      _laundrySpecialtyList
          .addAll(Specialty.fromJson(response.body).specialties);
      _isLoaded = true;
      update();
    } else {
      print('laundry not working ${response.statusCode}');
    }
  }

  void addItem(SpecialtyModel specialty, int quantity) {
    var totalQuantity = 0;
    if (_items.containsKey(specialty.id!)) {
      _items.update(specialty.id!, (value) {
        totalQuantity = value.quantity! + quantity;

        return CartModel(
          id: value.id,
          name: value.name,
          price: value.price,
          time: DateTime.now().toString(),
          img: value.img,
          type: value.type,
          material: value.material,
          quantity: value.quantity! + quantity,
          isExist: true,
          provider: value.provider,
          specialty: specialty,
        );
      });

      if (totalQuantity <= 0) {
        _items.remove(specialty.id);
      }
    } else {
      if (quantity > 0) {
        _items.putIfAbsent(specialty.id!, () {
          return CartModel(
            id: specialty.id,
            name: specialty.name,
            price: specialty.price,
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
          'Item count 0', 'Please select items to add to cart',
          // backgroundColor: AppColors.mainColor, colorText: Colors.white
        );
      }
    }
    cartRepo.addToCartList(getItems);
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
}
