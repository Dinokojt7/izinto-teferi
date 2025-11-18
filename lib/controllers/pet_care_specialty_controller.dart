import 'package:flutter/foundation.dart';
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

  // Use Rx for reactive state management
  final RxList<NewSpecialtyModel> _petCareSpecialtyList =
      <NewSpecialtyModel>[].obs;
  List<NewSpecialtyModel> get petCareSpecialtyList => _petCareSpecialtyList;

  final RxBool _isLoaded = false.obs;
  bool get isLoaded => _isLoaded.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  Map<int, NewCartModel> _items = {};
  Map<int, NewCartModel> get getItems => _items;

  int _quantity = 0;
  int get quantity => _quantity;
  int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  @override
  void onInit() {
    super.onInit();
    getPetCareSpecialtyList();
  }

  Future<void> getPetCareSpecialtyList({bool forceRefresh = false}) async {
    if (_isLoading.value || (_isLoaded.value && !forceRefresh)) {
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      Response response = await petCareRepo.getPetCareSpecialtyList();

      if (response.statusCode == 200) {
        _petCareSpecialtyList.clear();
        _petCareSpecialtyList
            .addAll(NewSpecialty.fromJson(response.body).specialties);
        _isLoaded.value = true;

        if (kDebugMode) {
          print(
              'Pet Care specialty list loaded successfully: ${_petCareSpecialtyList.length} items');
        }
      } else {
        _handleError(
            'Failed to load pet care specialties: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Network error: $e');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  void _handleError(String message) {
    _errorMessage.value = message;
    if (kDebugMode) {
      print('PetCareSpecialtyController Error: $message');
    }

    // Auto-retry after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (!_isLoaded.value && !_isLoading.value) {
        getPetCareSpecialtyList();
      }
    });
  }

  void addItem(NewSpecialtyModel specialty, int quantity) {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('Error adding pet care item to cart: $e');
      }
      Get.snackbar('Error', 'Failed to add item to cart');
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

  // Retry method for manual retry
  void retryLoading() {
    getPetCareSpecialtyList(forceRefresh: true);
  }

  // Clear error method
  void clearError() {
    _errorMessage.value = '';
  }
}
