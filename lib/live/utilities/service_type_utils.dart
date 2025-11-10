// service_type_utils.dart
class ServiceTypeUtils {
  static List<Map<String, dynamic>> getItemsByServiceType(
      Map<String, dynamic> order, String serviceType) {
    final dynamic items = order['items'];
    if (items == null) return [];

    // Convert List<dynamic> to List<Map<String, dynamic>>
    final List<Map<String, dynamic>> typedItems = [];

    if (items is List) {
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final provider = item['provider']?.toString();
          if (getServiceTypeFromProvider(provider) == serviceType) {
            typedItems.add(item);
          }
        }
      }
    }

    return typedItems;
  }

  static double calculateServiceTypeTotal(List<Map<String, dynamic>> items) {
    double total = 0;
    for (final item in items) {
      // Handle different number types safely
      dynamic price = item['price'];
      dynamic quantity = item['quantity'];

      final double priceValue = price is int
          ? price.toDouble()
          : price is double
              ? price
              : 0.0;
      final int quantityValue = quantity is int
          ? quantity
          : quantity is double
              ? quantity.toInt()
              : 1;

      total += priceValue * quantityValue;
    }
    return total;
  }

  static List<String> getAllServiceTypesFromOrder(Map<String, dynamic> order) {
    final dynamic items = order['items'];
    if (items == null) return [];

    final Set<String> serviceTypes = {};

    if (items is List) {
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final provider = item['provider']?.toString();
          final serviceType = getServiceTypeFromProvider(provider);
          serviceTypes.add(serviceType);
        }
      }
    }

    return serviceTypes.toList();
  }

  static String getServiceTypeFromProvider(String? provider) {
    switch (provider?.toLowerCase()) {
      case 'wegas':
        return 'Gas Refill';
      case 'easy laundry':
        return 'Laundry';
      case 'modern8':
        return 'Home Care';
      case 'clean paws':
        return 'Pet Care';
      case 'grandeur autocare':
        return 'Car Wash';
      default:
        return 'Car Wash'; // Fallback for empty/null provider
    }
  }

  static String getProviderDisplayName(String? provider) {
    switch (provider?.toLowerCase()) {
      case 'wegas':
        return 'Wegas';
      case 'easy laundry':
        return 'Easy Laundry';
      case 'modern8':
        return 'Modern8';
      case 'clean paws':
        return 'Clean Paws';
      case 'grandeur autocare':
        return 'Grandeur Autocare';
      default:
        return 'Izinto'; // Fallback
    }
  }

  static String getServiceTypeImage(String serviceType) {
    switch (serviceType) {
      case 'Gas Refill':
        return 'assets/image/gas.png';
      case 'Laundry':
        return 'assets/image/laundry.png';
      case 'Home Care':
        return 'assets/image/home_care.png';
      case 'Pet Care':
        return 'assets/image/pet_care.png';
      case 'Car Wash':
        return 'assets/image/car_wash.png';
      default:
        return 'assets/image/vacuuming.png';
    }
  }
}
