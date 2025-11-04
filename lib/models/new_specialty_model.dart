class NewSpecialty {
  late List<NewSpecialtyModel> _specialties;
  List<NewSpecialtyModel> get specialties => _specialties;

  NewSpecialty({required specialties}) {
    this._specialties = specialties;
  }

  NewSpecialty.fromJson(Map<String, dynamic> json) {
    if (json['Specialties'] != null) {
      _specialties = <NewSpecialtyModel>[];
      json['Specialties'].forEach((v) {
        _specialties.add(NewSpecialtyModel.fromJson(v));
      });
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
  int? originalId; // Reference to original product ID
  String? selectedSize; // Currently selected size
  bool? isSizeVariant; // Whether this is a size variant

  NewSpecialtyModel(
      {this.id,
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
      this.isSizeVariant = false});

  //  Helper to get display name with size
  String get displayName {
    if (isSizeVariant == true &&
        selectedSize != null &&
        selectedSize!.isNotEmpty) {
      return '$name ($selectedSize)';
    }
    return name ?? '';
  }

  //  Helper to check if this is the same base product
  bool isSameBaseProduct(NewSpecialtyModel other) {
    if (isSizeVariant == true && other.isSizeVariant == true) {
      return originalId == other.originalId;
    }
    return id == other.id;
  }

  NewSpecialtyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    introduction = json['introduction'];

    if (json['price'] is List) {
      price = (json['price'] as List).cast<int>();
    } else if (json['price'] is int) {
      price = [json['price']];
    } else {
      price = [];
    }

    if (json['size'] is List) {
      size = (json['size'] as List).cast<String>();
    } else if (json['size'] is String) {
      size = [json['size']];
    } else {
      size = [];
    }

    img = json['img'];
    details = json['details'] is List ? json['details'] : [];
    type = json['type'];
    material = json['material'];
    provider = json['provider'];
    time = json['time'];
    originalId = json['originalId'];
    selectedSize = json['selectedSize'];
    isSizeVariant = json['isSizeVariant'] ?? false;
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
    if (selectedSize != null && size != null && price != null) {
      final sizeIndex = size!.indexOf(selectedSize!);
      if (sizeIndex != -1 && sizeIndex < price!.length) {
        return price![sizeIndex];
      }
    }
    return firstPrice;
  }

  // Helper method to get first price
  int get firstPrice => price != null && price!.isNotEmpty ? price![0] : 0;

//  Helper to create a favorite-compatible variant
  NewSpecialtyModel createFavoriteVariant(String selectedSize) {
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
  }

// Helper method to get price for size
  static int _getPriceForSize(NewSpecialtyModel item, String size) {
    if (item.size == null || item.price == null) {
      return item.firstPrice;
    }

    final sizeIndex = item.size!.indexOf(size);
    if (sizeIndex != -1 && sizeIndex < item.price!.length) {
      return item.price![sizeIndex];
    }

    return item.firstPrice;
  }

  static int _generateSizeVariantId(int? originalId, String size) {
    if (originalId == null) return size.hashCode.abs();
    return (originalId * 1000) + (size.hashCode % 1000).abs();
  }
}
