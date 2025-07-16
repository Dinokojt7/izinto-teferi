import 'address_model.dart';

class OrderModel {
  late int? id;
  double? orderAmount;
  String? orderStatus;
  String? paymentStatus;
  String? orderNote;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  String? scheduleAt;
  String? otp;
  String? pending;
  String? accepted;
  String? confirmed;
  String? processing;
  String? handover;
  String? driver;
  String? pickedUp;
  String? delivered;
  String? canceled;
  String? refundRequested;
  String? refunded;
  int? scheduled;
  String? failed;
  int? detailsCount;

  AddressModel? deliveryAddress;

  OrderModel(
      {this.id,
      this.orderAmount,
      this.orderStatus,
      this.paymentStatus,
      this.orderNote,
      this.createdAt,
      this.updatedAt,
      this.deliveryCharge,
      this.scheduleAt,
      this.otp,
      this.pending,
      this.accepted,
      this.confirmed,
      this.processing,
      this.handover,
      this.driver,
      this.pickedUp,
      this.delivered,
      this.canceled,
      this.refundRequested,
      this.refunded,
      this.scheduled,
      this.detailsCount,
      this.deliveryAddress});

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderAmount = json['order_amount'].toDouble();
    orderStatus = json['order_status'] ?? 'pending';
    orderNote = json['order_note'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveryCharge = json['delivery_charge'] ?? '';
    scheduleAt = json['schedule_at'] ?? '';
    otp = json['otp'] ?? '';
    pending = json['pending'] ?? '';
    accepted = json['accepted'] ?? '';
    confirmed = json['confirmed'] ?? '';
    processing = json['processing'] ?? '';
    handover = json['handover'] ?? '';
    driver = json['driver'] ?? '';
    pickedUp = json['picked_up'] ?? '';
    delivered = json['delivered'] ?? '';
    canceled = json['canceled'] ?? '';
    refundRequested = json['refund_requested'] ?? '';
    refunded = json['refunded'] ?? '';
    scheduled = json['scheduled'] ?? '';
    detailsCount = json['details_count'] ?? '';
    deliveryAddress = (json['delivery_address'] != null
        ? AddressModel.fromJson(json['delivery_address'])
        : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_amount'] = this.orderAmount;
    data['order_status'] = this.orderStatus;
    data['createdAt'] = this.createdAt;
    data['orderNote'] = this.orderNote;
    data['updatedAt'] = this.updatedAt;
    data['deliveryCharge'] = this.deliveryCharge;
    data['pending'] = this.pending;
    data['otp'] = this.otp;
    data['accepted'] = this.accepted;
    data['deliveryAddress'] = this.deliveryAddress;
    data['confirmed'] = this.confirmed;
    data['processing'] = this.processing;
    data['handover'] = this.handover;
    data['detailsCount'] = this.detailsCount;
    data['scheduled'] = this.scheduled;
    data['refunded'] = this.refunded;
    data['refundRequested'] = this.refundRequested;
    data['canceled'] = this.canceled;
    data['delivered'] = this.delivered;
    data['driver'] = this.driver;
    return data;
  }
}
