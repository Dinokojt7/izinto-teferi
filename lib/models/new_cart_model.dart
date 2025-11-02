import 'dart:convert';

class NewCartModel {
  int? id;
  String? name;
  int? price;
  String? time;
  String? type;
  String? img;
  String? provider;
  String? material;
  int? quantity;
  bool? isExist;
  dynamic specialty; // Can hold both old and new models

  NewCartModel({
    this.id,
    this.name,
    this.price,
    this.time,
    this.img,
    this.type,
    this.material,
    this.quantity,
    this.isExist,
    this.provider,
    this.specialty,
  });

  NewCartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    time = json['time'];
    img = json['img'];
    type = json['type'];
    material = json['material'];
    quantity = json['quantity'];
    isExist = json['isExist'];
    provider = json['provider'];

    // Store specialty as raw JSON for flexibility
    if (json['specialty'] != null) {
      if (json['specialty'] is String) {
        specialty = jsonDecode(json['specialty']);
      } else {
        specialty = json['specialty'];
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'time': time,
      'img': img,
      'type': type,
      'material': material,
      'quantity': quantity,
      'isExist': isExist,
      'provider': provider,
      'specialty': specialty is Map ? jsonEncode(specialty) : specialty,
    };
  }
}
