import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../utils/dimensions.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final String imgPath = 'assets/image/nodatapage.png';
  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.rawSnackbar(
          messageText: Container(
            height: Dimensions.height30 * 1.8,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 0.5,
                  offset: Offset(1, 2),
                ),
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 0.5,
                  offset: Offset(0, -1),
                ),
              ],
              borderRadius: BorderRadius.circular(Dimensions.radius20 / 1.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.wifi_off,
                  color: Colors.redAccent,
                  size: Dimensions.font26 / 1.2,
                ),
                Text(
                  'You are offline',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: Dimensions.font16 * 1.01,
                  ),
                ),
              ],
            ),
          ),
          isDismissible: false,
          duration: const Duration(days: 1),
          backgroundColor: Colors.transparent,
          margin: EdgeInsets.symmetric(
              horizontal: Dimensions.width30 * 3.5,
              vertical: Dimensions.height30 * 3),
          snackStyle: SnackStyle.FLOATING);
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
