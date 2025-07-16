class Plans {
  late List<PlansModel> _specialties;
  List<PlansModel> get specialties => _specialties;
  Plans({required specialties}) {
    this._specialties = specialties;
  }
  Plans.fromJson(Map<String, dynamic> json) {
    if (json['Specialties'] != null) {
      _specialties = <PlansModel>[];
      json['Specialties'].forEach((v) {
        _specialties.add(PlansModel.fromJson(v));
      });
    }
  }
}

class PlansModel {
  int? carWashPlan;
  int? laundryPlan;
  String? laundryInterval;
  String? carWashInterval;

  PlansModel({
    this.carWashInterval,
    this.laundryInterval,
    this.laundryPlan,
    this.carWashPlan,
  });

  PlansModel.fromJson(Map<String, dynamic> json) {
    carWashInterval = json['carWashInterval'];
    carWashPlan = json['carWashPlan'];
    laundryInterval = json['laundryInterval'];
    laundryPlan = json['laundryPlan'];
  }

  Map<String, dynamic>? toJson() {
    return {
      'carWashInterval': this.carWashInterval,
      'laundryInterval': this.laundryInterval,
      'laundryPlan': this.laundryPlan,
      'carWashPlan': this.carWashPlan,
    };
  }
}
