// TODO(dual-di): there are two separate DI entry points called from main.dart
// — this one (NetworkInjection, registers only NetworkController) and
// helpers/dependencies.dart's `dep.init()` (registers everything else via
// Get.lazyPut). Fold this into dep.init() so there's a single init path,
// or rename both so it's obvious neither is legacy/dead.
import 'package:get/get.dart';
import 'package:izinto/controllers/network_controller.dart';

class NetworkInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
