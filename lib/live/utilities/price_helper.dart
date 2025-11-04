import '../../models/cart_model.dart';
import '../../models/new_cart_model.dart';
import '../../models/new_specialty_model.dart';
import '../../models/popular_specialty_model.dart';
import '../../models/recommended_specialty_model.dart';

// Update PriceHelper to handle size-specific pricing
class PriceHelper {
  static int getPrice(dynamic specialty) {
    if (specialty is NewSpecialtyModel) {
      // Use actualPrice which respects size selection
      return specialty.actualPrice;
    } else if (specialty is SpecialtyModel) {
      return specialty.price ?? 0;
    } else if (specialty is Specialties) {
      return specialty.price ?? 0;
    }
    return 0;
  }

  static String getDisplayName(dynamic specialty) {
    if (specialty is NewSpecialtyModel) {
      return specialty.displayName;
    } else if (specialty is SpecialtyModel) {
      return specialty.name ?? '';
    } else if (specialty is Specialties) {
      return specialty.name ?? '';
    }
    return '';
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
