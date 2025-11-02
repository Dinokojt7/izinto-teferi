import 'package:shared_preferences/shared_preferences.dart';
import 'package:izinto/utils/app_constants.dart';

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
