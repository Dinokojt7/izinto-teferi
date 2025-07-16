import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/controllers/cart_controller.dart';
import 'package:izinto/models/popular_specialty_model.dart';

import '../../../../../controllers/car_specialty_controller.dart';
import '../../../../../models/cart_model.dart';
import '../../../../utilities/generic_snackbar.dart';
import '../view_widgets/show_wash_type_details.dart';

class CarWashController extends ChangeNotifier {
  final _cartController = Get.find<CartController>();
  int _selectVehicleIndex = 0;
  int get selectVehicleIndex => _selectVehicleIndex;
  int _selectedVehicleId = 0;
  int get selectedVehicleId => _selectedVehicleId;
  String _selectionPrice = '';
  String get selectionPrice => _selectionPrice;
  int _washTypeIndex = 0;
  int get washTypeIndex => _washTypeIndex;
  int _totalCharges = 0;
  int get totalCharges => _totalCharges;

  String _washType = '';
  String get washType => _washType;
  String _description = '';
  String get description => _description;
  String _selectedPrice = '';
  String get selectedPrice => _selectedPrice;
  final List carWashSpecialties =
      Get.find<CarSpecialtyController>().carSpecialtyList;

  final List<Map<String, dynamic>> washTypes = [
    {
      'washType': 'Standard Interior Wash',
      'description': 'Inside wash only, includes dashboard clean.',
      'included': [
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': Colors.deepPurpleAccent.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': Colors.green.shade100
        },
      ],
      'excluded': []
    }, //example of Standard Interior wash details
    {
      'washType': 'Standard Exterior Wash',
      'description': 'Outside wash only, includes tyre shine.',
      'included': [
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Tyre Polish',
          'image': 'assets/image/tyre-shine.png',
          'color': Colors.blueGrey.withOpacity(0.2)
        },
      ],
      'excluded': []
    }, //example of Standard Exterior Wash details
    {
      'washType': 'Standard Exterior Wash and Polish',
      'description': 'Outside wash only, includes tyre shine and body polish.',
      'included': [
        {
          'text': 'Body Polish',
          'image': 'assets/image/body-polish.png',
          'color': Colors.green.shade100
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Tyre Polish',
          'image': 'assets/image/tyre-shine.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
      ],
      'excluded': []
    }, //example of Standard Exterior and Wash Polish details
    {
      'washType': 'Standard Full Wash',
      'description': 'Full car wash including vacuuming and tyre shine.',
      'included': [
        {
          'text': 'Tyre Shine',
          'image': 'assets/image/tyre-shine.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': Colors.blueGrey.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': Colors.green.shade100
        },
      ],
      'excluded': []
    }, //example of Standard Full Wash details
    {
      'washType': 'Standard Wash and Full Body Polish',
      'description':
          'Full car wash including vacuuming, tyre shine, and body polish.',
      'included': [
        {
          'text': 'Body Polish',
          'image': 'assets/image/body-polish.png',
          'color': Colors.green.shade100
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': Colors.blueGrey.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': Colors.green.shade100
        },
        {
          'text': 'Tyre Shine',
          'image': 'assets/image/tyre-shine.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
      ],
      'excluded': []
    }, //example of Standard Wash and Full Body Polish details
    {
      'washType': 'Premium Full Wash',
      'description':
          'Full car wash including vacuuming, tyre shine, and premium perfumes.',
      'included': [
        {
          'text': 'Premium Perfumes',
          'image': 'assets/image/perfume.png',
          'color': Colors.brown.shade100
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': Colors.blueGrey.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': Colors.green.shade100
        },
        {
          'text': 'Tyre Shine',
          'image': 'assets/image/tyre-shine.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
      ],
      'excluded': []
    }, //example of Premium Full Wash details
    {
      'washType': 'Premium Full Wash and Full Body Polish',
      'description':
          'Full car wash including vacuuming, tyre shine, premium perfumes, and body polish.',
      'included': [
        {
          'text': 'Body Polish',
          'image': 'assets/image/body-polish.png',
          'color': Colors.green.shade100
        },
        {
          'text': 'Premium Perfumes',
          'image': 'assets/image/perfume.png',
          'color': Colors.brown.shade100
        },
        {
          'text': 'Full Body Wash',
          'image': 'assets/image/full-body-wash.png',
          'color': Colors.orange.withOpacity(0.2)
        },
        {
          'text': 'Vacuuming',
          'image': 'assets/image/vacuuming.png',
          'color': Colors.blueGrey.withOpacity(0.2)
        },
        {
          'text': 'DashBoard clean',
          'image': 'assets/image/dashboard-clean.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
        {
          'text': 'Seats clean',
          'image': 'assets/image/seat-clean.png',
          'color': Colors.green.shade100
        },
        {
          'text': 'Tyre Shine',
          'image': 'assets/image/tyre-shine.png',
          'color': Colors.redAccent.withOpacity(0.2)
        },
      ],
      'excluded': []
    }, //example of Premium Full Wash and Full Body Polish details
  ];

  List<List<int>> _priceSelection = [
    [150, 150, 180, 220, 260, 280, 350],
    [170, 170, 190, 230, 280, 300, 380],
    [190, 190, 290, 360, 400, 450, 500],
  ];

  void selectVehicleType(int index) {
    _selectVehicleIndex = index;

    calculateCharges();
    notifyListeners();
  }

  int _showingQuantity = 0;
  int get showingQuantity => _showingQuantity;

  int? updateQuantityDisplayed() {
    final _cartList = _cartController.getItems;
    for (var i = 0; i < _cartList.length; i++) {
      if (_cartList[i].id == 401 && _selectVehicleIndex == 0) {
        return _cartList[i].quantity;
      } else {
        if (_cartList[i].id == 402 && _selectVehicleIndex == 1) {
          return _cartList[i].quantity;
        } else {
          if (_cartList[i].id == 403 && _selectVehicleIndex == 2) {
            return _cartList[i].quantity;
          }
        }
      }
    }
    return 0;
  }

  Future<void> selectWashType(int index) async {
    _washTypeIndex = await index;
    _washType = washTypes[_washTypeIndex]['washType'];
    _description = washTypes[_washTypeIndex]['description'];
    // _selectedPrice =
    //     _priceSelection[_selectVehicleIndex][_washTypeIndex].toString();
    _selectedPrice = calculateCharges().toString();
    notifyListeners();
  }

  int calculateCharges() {
    _totalCharges = _priceSelection[_selectVehicleIndex][_washTypeIndex];

    notifyListeners();
    return _totalCharges;
  }

  void showDetails(
    context,
  ) {
    showModalBottomSheet(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return ShowWashTypeDetails(
            headerText: _washType,
            price: _selectedPrice,
            description: _description,
            action: 'Select',
            isMiniaturized: false,
            isCartView: false,
            onTap: () async {
              // _isLogOutLoading = true;
              // notifyListeners();
              if (true) {
                try {
                  Navigator.of(context).pop();
                  // await _auth.signOut();
                  // var removeUserData =
                  // Provider.of<ProfileViewController>(context, listen: false)
                  //     .removeUserData();
                  // Future.delayed(const Duration(milliseconds: 50), () async {
                  //   SystemNavigation().applyCustomSystemChromeSettings(
                  //       Colors.white,
                  //       Brightness.dark,
                  //       Colors.white,
                  //       Brightness.dark);
                  // });
                  // await removeUserData;
                } catch (e) {
                  GenericSnackBar().showCustomSnackBar(
                      null, context, 'Something went wrong', false);
                  // _isLogOutLoading = false;
                }
              }
              notifyListeners();
            });
      },
    );
  }

  ///Add vehicle in the included vehicles container ///
  List<Map<String, dynamic>> _includedVehicles = [];
  List<Map<String, dynamic>> get includedVehicles => _includedVehicles;
  void addVehicles() {
    final _cartController = Get.find<CartController>();
    final _cartList = _cartController.getItems;
    for (var i = 0; i < _cartList.length; i++) {
      switch (_cartList[i].id) {
        case 401:
        case 402:
        case 403:
          _includedVehicles.add(
              {'img': _cartList[i].img, 'quantity': _cartList[i].quantity});
          notifyListeners();
      }
    }
    notifyListeners();
  }

  bool get isCarAdded => _includedVehicles.length > 0;

  void addCar(String vehicleType, String imageString) {
    var existingItem = _includedVehicles
        .firstWhereOrNull((e) => e['vehicleType'] == vehicleType);

    if (existingItem != null) {
      existingItem['selectionQuantity'] += 1;
      notifyListeners();
    } else {
      _includedVehicles.add({
        'selectionQuantity': 1,
        'bill': _selectedPrice,
        'vehicleType': vehicleType,
        'imageString': imageString,
        'selectedWash': washTypes[_washTypeIndex]
      });
      print('Here is the object ${_includedVehicles}');
      notifyListeners();
    }
  }

  void addMoreCars() {
    _selectVehicleIndex = 0;
    notifyListeners();
    _washTypeIndex = 0;
    notifyListeners();
  }

  void removeItem(SpecialtyModel specialty) {
    _cartController.addItem(specialty, -1);
  }

  void clearItems() {
    _includedVehicles.clear();
  }
}
