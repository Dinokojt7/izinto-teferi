class SubscriptionModel {
  int? laundryStatus;
  int? laundryCapacity;
  DateTime? laundryLastWashDate;
  DateTime? laundryNextWashDate;
  int? carWashStatus;
  int? carWashCapacity;
  DateTime? carWashLastWashDate;
  DateTime? carWashNextWashDate;
  SubscriptionModel(
      {this.laundryCapacity,
      this.laundryLastWashDate,
      this.laundryNextWashDate,
      this.laundryStatus,
      this.carWashCapacity,
      this.carWashLastWashDate,
      this.carWashNextWashDate,
      this.carWashStatus});

  factory SubscriptionModel.fromJson(Map<dynamic, dynamic> json) {
    return SubscriptionModel(
        laundryCapacity: json['laundryCapacity'] ?? 0,
        laundryLastWashDate: json['laundryLastWashDate'] ?? DateTime.now(),
        laundryNextWashDate: json['laundryNextWashDate'] ?? DateTime.now(),
        laundryStatus: json['laundryStatus'] ?? 0,
        carWashCapacity: json['carWashCapacity'] ?? 0,
        carWashLastWashDate: json['carWashLastWashDate'] ?? DateTime.now(),
        carWashNextWashDate: json['carWashNextWashDate'] ?? DateTime.now(),
        carWashStatus: json['carWashStatus'] ?? 0);
  }
}
