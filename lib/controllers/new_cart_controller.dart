import 'package:get/get.dart';
import 'package:izinto/helpers/data/repository/cart_repo.dart';
import 'package:izinto/models/new_cart_model.dart';
import 'package:izinto/models/popular_specialty_model.dart';
import 'package:izinto/models/new_specialty_model.dart';

import '../live/utilities/price_helper.dart';

class NewCartController extends GetxController {
  final CartRepo cartRepo;
  NewCartController({required this.cartRepo});

  Map<int, NewCartModel> _items = {};
  Map<int, NewCartModel> get items => _items;

  List<NewCartModel> storageItems = [];

  void addItem(dynamic specialty, int quantity) {
    var totalQuantity = 0;
    final specialtyId = specialty.id!;

    if (_items.containsKey(specialtyId)) {
      _items.update(specialtyId, (value) {
        totalQuantity = value.quantity! + quantity;

        return NewCartModel(
          id: value.id,
          name: value.name,
          price: PriceHelper.getPrice(specialty),
          time: DateTime.now().toString(),
          img: PriceHelper.getImage(specialty),
          type: specialty.type,
          material: specialty.material,
          quantity: value.quantity! + quantity,
          isExist: true,
          provider: specialty.provider,
          specialty: specialty,
        );
      });

      if (totalQuantity <= 0) {
        _items.remove(specialtyId);
      }
    } else {
      if (quantity > 0) {
        _items.putIfAbsent(specialtyId, () {
          return NewCartModel(
            id: specialty.id,
            name: specialty.name,
            price: PriceHelper.getPrice(specialty),
            time: DateTime.now().toString(),
            img: PriceHelper.getImage(specialty),
            type: specialty.type,
            material: specialty.material,
            quantity: quantity,
            isExist: true,
            provider: specialty.provider,
            specialty: specialty,
          );
        });
      } else {
        Get.snackbar('Item count 0', 'Please select items to add to cart');
      }
    }
    cartRepo.addToNewCartList(getItems);
    update();
  }

  bool existInCart(dynamic specialty) {
    if (specialty?.id == null) return false;
    return _items.containsKey(specialty.id);
  }

  int getQuantity(dynamic specialty) {
    if (specialty?.id == null) return 0;
    return _items[specialty.id]?.quantity ?? 0;
  }

  int get totalItems {
    var totalQuantity = 0;
    _items.forEach((key, value) {
      totalQuantity += value.quantity!;
    });
    return totalQuantity;
  }

  List<NewCartModel> get getItems {
    return _items.entries.map((e) => e.value).toList();
  }

  int get totalAmount {
    var total = 0;
    _items.forEach((key, value) {
      total += value.quantity! * value.price!;
    });
    return total;
  }

  Future<List<NewCartModel>> getCartData() async {
    setCart = await cartRepo.getNewCartList();
    return storageItems;
  }

  set setCart(List<NewCartModel> items) {
    storageItems = items;
    for (int i = 0; i < storageItems.length; i++) {
      _items.putIfAbsent(storageItems[i].id!, () => storageItems[i]);
    }
  }

  void clear() {
    _items = {};
    update();
  }

  void addToCartList() {
    cartRepo.addToNewCartList(getItems);
    update();
  }
}
