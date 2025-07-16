class Address {
  late List<RudimentaryAddressModel> _address;
  List<RudimentaryAddressModel> get address => _address;
  Specialty({required address}) {
    this._address = address;
  }

  Address.fromJson(Map<String, dynamic> json) {
    if (json['Addresses'] != null) {
      _address = <RudimentaryAddressModel>[];
      json['Addresses'].forEach((v) {
        _address.add(RudimentaryAddressModel.fromJson(v));
      });
    }
  }
}

class RudimentaryAddressModel {
  String? streetNumber;
  String? suburb;
  String? zipCode;
  String? town;

  String? country;

  RudimentaryAddressModel({
    this.streetNumber,
    this.suburb,
    this.zipCode,
    this.town,
    this.country,
  });

  factory RudimentaryAddressModel.fromJson(Map<String, dynamic> json) {
    return RudimentaryAddressModel(
      streetNumber: json['streetNumber'],
      suburb: json['suburb'],
      zipCode: json['zipCode'],
      town: json['town'],
      country: json['country'],
    );
  }
}
