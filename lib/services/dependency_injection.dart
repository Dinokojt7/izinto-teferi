import 'package:get/get.dart';
import 'package:izinto/controllers/network_controller.dart';

class NetworkInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
