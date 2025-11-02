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
  });

  NewSpecialtyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    introduction = json['introduction'];

    // Handle price as list
    if (json['price'] is List) {
      price = (json['price'] as List).cast<int>();
    } else if (json['price'] is int) {
      price = [json['price']];
    } else {
      price = [];
    }

    // Handle size as list
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
  }

  // Helper method to get first price
  int get firstPrice => price != null && price!.isNotEmpty ? price![0] : 0;

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
    };
  }
}
