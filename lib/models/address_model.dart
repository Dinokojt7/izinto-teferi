class AddressModel {
  late int id;
  late int userId;
  String? streetNumber;
  String? street;
  String? city;
  String? zipCode;
  String? area;
  String? address;
  String? country;
  String? admin;

  AddressModel(
      {required this.id,
      required this.userId,
      this.streetNumber,
      this.street,
      this.city,
      this.address,
      this.area,
      this.zipCode,
      this.country,
      this.admin});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
        id: json['id'],
        userId: json['userId'],
        streetNumber: json['streetNumber'],
        street: json['street'],
        city: json['city'],
        address: json['address'],
        area: json['area'],
        zipCode: json['zipCode'],
        country: json['country'],
        admin: json['admin']);
  }
}
