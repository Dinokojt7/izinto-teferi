import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/controllers/recommended_specialty_controller.dart';

import '../../controllers/laundry_specialty_controller.dart';
import '../../controllers/popular_specialty_controller.dart';

class CartRecommendedItemsController extends ChangeNotifier {
//User recommended items
  List _recommended = [
    {
      "id": 17,
      "name": "Jacket",
      "introduction":
          "Any small or big alteration can be handled by our qualified tailors, from shortening of trousers and skirts to major alterations on evening gowns and men’s suites. Altering garments require time, we recommend coming through and spending time with our tailors, trying on garments before any work is done. Additional fitting might be required in order to finish an alteration. Please check above the Estimated Time for this service. Thank you, we look foward to bringing a superior Izinto service to your doorstep, cheers!",
      "price": 15,
      "createAt": "assets/image/jacket-icon.png",
      "turnaroundTime": "5hrs",
      "img": "assets/image/jacket-icon.png",
      "location": [-26.14742, 28.0435],
      "type": "Hoodie",
      "material": "Randburg",
      "provider": "Easy Laundry",
      "quantity": [],
      "time": ""
    },
    {
      "id": 14,
      "name": "Pants",
      "introduction":
          "Sneaker Bar offers Detailed Wash for strong inset stains on the sneaker. This clean includes a lace wash, mid-sole clean, upper-mid sole clean, in-sole clean, and bacteria removal. Our drivers from Izinto will collect your sneakers from your prefered location anywhere in Sandton and deliver them straigth to the nearest Sneaker Wash outlet. Please check above the Estimated Time for this service. Thank you, we look foward to bringing a superior Izinto service to your doorstep, cheers!",
      "price": 5,
      "createAt": "assets/image/pants-icon.png",
      "turnaroundTime": "5hrs",
      "img": "assets/image/pants-icon.png",
      "location": [25.2285, 55.3273],
      "type": "All Materials",
      "material": "Randburg",
      "provider": "Easy Laundry",
      "quantity": [],
      "time": ""
    },
    {
      "id": 16,
      "name": "Accessories",
      "introduction":
          "Sneaker Bar offers Detailed Wash for strong inset stains on the sneaker. This clean includes a lace wash, mid-sole clean, upper-mid sole clean, in-sole clean, and bacteria removal. Our drivers from Izinto will collect your sneakers from your prefered location anywhere in Sandton and deliver them straigth to the nearest Sneaker Wash outlet. Please check above the Estimated Time for this service. Thank you, we look foward to bringing a superior Izinto service to your doorstep, cheers!",
      "price": 16,
      "createAt": "assets/image/accessories-icon.png",
      "turnaroundTime": "5hrs",
      "img": "assets/image/accessories-icon.png",
      "location": [25.2285, 55.3273],
      "type": "Hat, Gloves, Scalfs",
      "material": "Randburg",
      "provider": "Easy Laundry",
      "quantity": [],
      "time": ""
    },
    {
      "id": 59,
      "name": "Bagpack",
      "introduction":
          "Any small or big alteration can be handled by our qualified tailors, from shortening of trousers and skirts to major alterations on evening gowns and men’s suites. Altering garments require time, we recommend coming through and spending time with our tailors, trying on garments before any work is done. Additional fitting might be required in order to finish an alteration. Please check above the Estimated Time for this service. Thank you, we look foward to bringing a superior Izinto service to your doorstep, cheers!",
      "price": 7,
      "createAt": "assets/image/bagpack-icon.png",
      "turnaroundTime": "5hrs",
      "img": "assets/image/bagpack-icon.png",
      "location": [-26.14742, 28.0435],
      "type": "Any Size",
      "material": "Randburg",
      "provider": "Easy Laundry",
      "quantity": [],
      "time": ""
    },
    {
      "id": 15,
      "name": "Gym wear",
      "introduction":
          "Sneaker Bar offers Detailed Wash for strong inset stains on the sneaker. This clean includes a lace wash, mid-sole clean, upper-mid sole clean, in-sole clean, and bacteria removal. Our drivers from Izinto will collect your sneakers from your prefered location anywhere in Sandton and deliver them straigth to the nearest Sneaker Wash outlet. Please check above the Estimated Time for this service. Thank you, we look foward to bringing a superior Izinto service to your doorstep, cheers!",
      "price": 6,
      "createAt": "assets/image/gym-icon.png",
      "turnaroundTime": "5hrs",
      "img": "assets/image/gym-icon.png",
      "location": [25.2285, 55.3273],
      "type": "Any Item",
      "material": "Randburg",
      "provider": "Easy Laundry",
      "quantity": [],
      "time": ""
    },
  ];
  List get recommended => _recommended;

  // void generateRecommendedList(favouriteItems) {
  //   //Add all items from the available lists
  //   // _recommended
  //   //     .addAll(Specialty.fromJson(Get.find<LaundrySpecialtyController>().laundrySpecialtyList).specialties);
  //   // _recommended
  //   //     .addAll(Get.find<PopularSpecialtyController>().popularSpecialtyList);
  //   _recommended = _recommended + favouriteItems;
  //   // Shuffle the combined list
  //   _recommended.shuffle(Random());
  //   _recommended = _recommended.take(10).toList();
  //   print(_recommended);
  //   notifyListeners();
  // }
  Future<bool> generateRecommendedList(listA, listB) async {
    List<dynamic> combinedList = [];

    combinedList.addAll(listA);
    combinedList.addAll(listB);

    // Shuffle the combined list
    combinedList.shuffle(Random());

    // Take the first 10 items or less if there aren't enough
    _recommended = combinedList.take(10).toList();
    notifyListeners();
    return true;
  }
}
