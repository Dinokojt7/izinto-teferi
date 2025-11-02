import '../../models/cart_model.dart';
import '../../models/new_cart_model.dart';
import '../../models/new_specialty_model.dart';
import '../../models/popular_specialty_model.dart';

class PriceHelper {
  static int getPrice(dynamic item) {
    if (item == null) return 0;

    // Handle NewSpecialtyModel
    if (item is NewSpecialtyModel) {
      return item.firstPrice;
    }

    // Handle SpecialtyModel (old)
    if (item is SpecialtyModel) {
      return item.price ?? 0;
    }

    // Handle CartModel (old)
    if (item is CartModel) {
      return item.price ?? 0;
    }

    // Handle NewCartModel
    if (item is NewCartModel) {
      return item.price ?? 0;
    }

    return 0;
  }

  static String getPriceDisplay(dynamic item) {
    return 'R${getPrice(item)},00*';
  }

  // Helper to get image from any model type
  static String getImage(dynamic item) {
    if (item == null) return 'assets/image/placeholder.png';

    if (item is NewSpecialtyModel)
      return item.img ?? 'assets/image/placeholder.png';
    if (item is SpecialtyModel)
      return item.img ?? 'assets/image/placeholder.png';
    if (item is CartModel) return item.img ?? 'assets/image/placeholder.png';
    if (item is NewCartModel) return item.img ?? 'assets/image/placeholder.png';

    return 'assets/image/placeholder.png';
  }
}
