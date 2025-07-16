import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseApi {
  static const _apiKey = '';

  static Future init() async {
    await Purchases.setLogLevel;
    await PurchasesConfiguration(_apiKey);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      return current == null ? [] : [current];
    } on Exception catch (e) {
      return [];
    }
  }
}
