import 'package:izinto/models/popular_specialty_model.dart';

class CartModel {
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
  SpecialtyModel? specialty;

  CartModel(
      {this.id,
      this.name,
      this.price,
      this.time,
      this.img,
      this.type,
      this.material,
      this.quantity,
      this.isExist,
      this.provider,
      this.specialty});

  CartModel.fromJson(Map<String, dynamic> json) {
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
    specialty = SpecialtyModel.fromJson(json['specialty']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'price': this.price,
      'time': this.time,
      'img': this.img,
      'type': this.type,
      'material': this.material,
      'quantity': this.quantity,
      'isExist': this.isExist,
      'provider': this.provider,
      'specialty': this.specialty!.toJson()
    };
  }
}
