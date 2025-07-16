class UserModel {
  final String uid;
  final String? name;
  final String? surname;
  final String? phone;
  final String? email;
  final String? address;
  int? laundryStatus;
  int? laundryCapacity;
  DateTime? laundryLastWashDate;
  DateTime? laundryNextWashDate;
  int? carWashStatus;
  int? carWashCapacity;
  DateTime? carWashLastWashDate;
  DateTime? carWashNextWashDate;
  final int? loyalty;

  // final String metadata;

  UserModel(
      {this.address,
      this.loyalty,
      this.surname,
      this.email,
      this.phone,
      this.name,
      required this.uid,
      this.laundryCapacity,
      this.laundryLastWashDate,
      this.laundryNextWashDate,
      this.laundryStatus,
      this.carWashCapacity,
      this.carWashLastWashDate,
      this.carWashNextWashDate,
      this.carWashStatus});

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      surname: json['surname'] ?? '',
      email: json['email'] ?? '',
      laundryCapacity: json['Laundry'] ?? 0,
      laundryLastWashDate: json['laundryLastWashDate'] ?? DateTime.now(),
      laundryNextWashDate: json['laundryNextWashDate'] ?? DateTime.now(),
      laundryStatus: json['Laundry initialized'] ?? 0,
      carWashCapacity: json['Car Wash'] ?? 0,
      carWashLastWashDate: json['carWashLastWashDate'] ?? DateTime.now(),
      carWashNextWashDate: json['carWashNextWashDate'] ?? DateTime.now(),
      carWashStatus: json['Car Wash initialized'] ?? 0,
      uid: json['uid'] ?? '',
    );
  }
}
