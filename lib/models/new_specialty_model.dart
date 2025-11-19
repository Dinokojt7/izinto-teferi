import 'package:flutter/foundation.dart';

class NewSpecialty {
  late List<NewSpecialtyModel> _specialties;
  List<NewSpecialtyModel> get specialties => _specialties;

  NewSpecialty({required specialties}) {
    this._specialties = specialties;
  }

  NewSpecialty.fromJson(Map<String, dynamic> json) {
    if (json['Specialties'] != null) {
      _specialties = <NewSpecialtyModel>[];
      try {
        for (var v in json['Specialties']) {
          if (v is Map<String, dynamic>) {
            _specialties.add(NewSpecialtyModel.fromJson(v));
          } else {
            if (kDebugMode) {

            }
          }
        }
      } catch (e) {
        if (kDebugMode) {

        }
        _specialties = [];
      }
    } else {
      _specialties = [];
    }
  }
}

class NewSpecialtyModel {
  int? id;
  String? name;
  String? introduction;
  List<int>? price;
  List<String>? size;
  String? img;
  List<dynamic>? details;
  String? type;
  String? material;
  String? provider;
  String? time;
  bool? isSelected = false;

  // New fields for size selection
  int? originalId;
  String? selectedSize;
  bool? isSizeVariant;

  NewSpecialtyModel({
    this.id,
    this.isSelected,
    this.name,
    this.introduction,
    this.price,
    this.size,
    this.img,
    this.details,
    this.type,
    this.material,
    this.provider,
    this.time,
    this.selectedSize,
    this.originalId,
    this.isSizeVariant = false,
  });

  // Helper to get display name with size
  String get displayName {
    try {
      if (isSizeVariant == true &&
          selectedSize != null &&
          selectedSize!.isNotEmpty) {
        return '$name ($selectedSize)';
      }
      return name ?? 'Unnamed Item';
    } catch (e) {
      return 'Unknown Item';
    }
  }

  // Helper to check if this is the same base product
  bool isSameBaseProduct(NewSpecialtyModel other) {
    try {
      if (isSizeVariant == true && other.isSizeVariant == true) {
        return originalId == other.originalId;
      }
      return id == other.id;
    } catch (e) {
      return false;
    }
  }

  NewSpecialtyModel.fromJson(Map<String, dynamic> json) {
    try {
      // ID with fallback
      id = _safeParseInt(json['id']) ?? _generateFallbackId(json);

      // Name with fallback
      name = json['name']?.toString() ?? 'Unknown Item';

      // Introduction with fallback
      introduction =
          json['introduction']?.toString() ?? 'No description available';

      // Price handling with comprehensive safety
      price = _safeParsePriceList(json['price']);

      // Size handling with safety
      size = _safeParseSizeList(json['size']);

      // Image with fallback
      img = json['img']?.toString() ?? 'assets/image/placeholder.png';

      // Details with safety
      details = json['details'] is List ? json['details'] : [];

      // Type with fallback
      type = json['type']?.toString() ?? 'General';

      // Material with fallback
      material = json['material']?.toString() ?? 'Standard';

      // Provider with fallback
      provider = json['provider']?.toString() ?? 'Unknown Provider';

      // Time with fallback
      time = json['time']?.toString() ?? '';

      // Size variant fields
      originalId = _safeParseInt(json['originalId']) ?? id;
      selectedSize = json['selectedSize']?.toString() ?? '';
      isSizeVariant = json['isSizeVariant'] ?? false;

      // Validation logging in debug mode
      if (kDebugMode) {
        _validateAndLog();
      }
    } catch (e) {
      if (kDebugMode) {


      }
      // Set safe defaults
      _setSafeDefaults();
    }
  }

  // Safe price list parsing
  List<int> _safeParsePriceList(dynamic priceData) {
    try {
      if (priceData is List) {
        final List<int> result = [];
        for (var item in priceData) {
          final parsed = _safeParseInt(item);
          if (parsed != null) {
            result.add(parsed);
          }
        }
        return result.isNotEmpty ? result : [0];
      } else if (priceData is int) {
        return [priceData];
      } else if (priceData is String) {
        final parsed = int.tryParse(priceData);
        return [parsed ?? 0];
      } else if (priceData is double) {
        return [priceData.toInt()];
      }
      return [0];
    } catch (e) {
      if (kDebugMode) {

      }
      return [0];
    }
  }

  // Safe size list parsing
  List<String> _safeParseSizeList(dynamic sizeData) {
    try {
      if (sizeData is List) {
        return sizeData.map((e) => e.toString()).toList();
      } else if (sizeData is String) {
        return [sizeData];
      }
      return ['Standard'];
    } catch (e) {
      if (kDebugMode) {

      }
      return ['Standard'];
    }
  }

  // Safe integer parsing
  int? _safeParseInt(dynamic value) {
    try {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return null;
    } catch (e) {
      return null;
    }
  }

  // Generate fallback ID
  int _generateFallbackId(Map<String, dynamic> json) {
    return json.hashCode.abs() % 1000000;
  }

  // Validation and logging
  void _validateAndLog() {
    if (price == null || price!.isEmpty) {

    }
    if (size == null || size!.isEmpty) {

    }
    if (img == null || img!.isEmpty) {

    }
  }

  // Set safe defaults in case of error
  void _setSafeDefaults() {
    id = id ?? _generateFallbackId({});
    name = name ?? 'Unknown Item';
    price = price ?? [0];
    size = size ?? ['Standard'];
    img = img ?? 'assets/image/placeholder.png';
    introduction = introduction ?? 'No description available';
    type = type ?? 'General';
    material = material ?? 'Standard';
    provider = provider ?? 'Unknown Provider';
    details = details ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'introduction': introduction,
      'price': price,
      'size': size,
      'img': img,
      'details': details,
      'type': type,
      'material': material,
      'provider': provider,
      'time': time,
      'originalId': originalId,
      'selectedSize': selectedSize,
      'isSizeVariant': isSizeVariant,
    };
  }

  // Helper method to get the actual price (respects size selection)
  int get actualPrice {
    try {
      if (selectedSize != null && size != null && price != null) {
        final sizeIndex = size!.indexOf(selectedSize!);
        if (sizeIndex != -1 && sizeIndex < price!.length) {
          return price![sizeIndex];
        }
      }
      return firstPrice;
    } catch (e) {
      if (kDebugMode) {

      }
      return firstPrice;
    }
  }

  // Helper method to get first price
  int get firstPrice {
    try {
      return price != null && price!.isNotEmpty ? price![0] : 0;
    } catch (e) {
      return 0;
    }
  }

  // Helper to create a favorite-compatible variant
  NewSpecialtyModel createFavoriteVariant(String selectedSize) {
    try {
      final priceForSize = _getPriceForSize(this, selectedSize);

      return NewSpecialtyModel(
        id: _generateSizeVariantId(id, selectedSize),
        name: name,
        introduction: introduction,
        price: [priceForSize],
        size: [selectedSize],
        img: img,
        details: details,
        type: type,
        material: material,
        provider: provider,
        time: time,
        originalId: id,
        selectedSize: selectedSize,
        isSizeVariant: true,
      );
    } catch (e) {
      if (kDebugMode) {

      }
      // Return a safe fallback
      return NewSpecialtyModel(
        id: _generateSizeVariantId(id, selectedSize),
        name: name ?? 'Unknown',
        price: [firstPrice],
        size: [selectedSize],
        img: img ?? 'assets/image/placeholder.png',
        originalId: id,
        selectedSize: selectedSize,
        isSizeVariant: true,
      );
    }
  }

  // Helper method to get price for size
  static int _getPriceForSize(NewSpecialtyModel item, String size) {
    try {
      if (item.size == null || item.price == null) {
        return item.firstPrice;
      }

      final sizeIndex = item.size!.indexOf(size);
      if (sizeIndex != -1 && sizeIndex < item.price!.length) {
        return item.price![sizeIndex];
      }

      return item.firstPrice;
    } catch (e) {
      if (kDebugMode) {

      }
      return item.firstPrice;
    }
  }

  static int _generateSizeVariantId(int? originalId, String size) {
    try {
      if (originalId == null) return size.hashCode.abs();
      return (originalId * 1000) + (size.hashCode % 1000).abs();
    } catch (e) {
      return size.hashCode.abs();
    }
  }
}

// Debug helper class
class ReleaseDebug {
  static void logItem(String tag, dynamic item) {
    try {










      // Check for common issues
      if (item.img == null || item.img.isEmpty) {

      }
      if (item.price == null || item.price.isEmpty) {

      }
    } catch (e) {


    }
  }
}
