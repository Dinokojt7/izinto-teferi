import 'package:shared_preferences/shared_preferences.dart';
import 'package:izinto/utils/app_constants.dart';

// TODO(legacy-cart): confirm who actually reads useNewModels()/checks this
// flag before touching the old cart/model/controller pair it gates — if
// nothing branches on it anymore, that's a sign the "new" path already won
// and the flag (and old path) can be retired, but verify first.
class FeatureFlags {
  static Future<bool> useNewModels() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.USE_NEW_MODELS) ?? false;
  }

  static Future<void> enableNewModels() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.USE_NEW_MODELS, true);
  }

  static Future<void> disableNewModels() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.USE_NEW_MODELS, false);
  }
}
