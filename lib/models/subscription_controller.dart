class SubscriptionController {
  int _laundrySubscriptionStatus = 0;
  int get laundrySubscriptionStatus => _laundrySubscriptionStatus;
  int _laundrySubscriptionCapacity = 0;
  int get laundrySubscriptionCapacity => _laundrySubscriptionCapacity;
  int _carWashSubscriptionStatus = 0;
  int get carWashSubscriptionStatus => _carWashSubscriptionStatus;
  int _carWashSubscriptionCapacity = 0;
  int get carWashSubscriptionCapacity => _carWashSubscriptionCapacity;
  DateTime _laundryLastWashDate = DateTime.now();
  DateTime get laundryLastWashDate => _laundryLastWashDate;
  DateTime _laundryNextWashDate = DateTime.now();
  DateTime get laundryNextWashDate => _laundryNextWashDate;
  DateTime _carWashLastWashDate = DateTime.now();
  DateTime get carWashLastWashDate => _carWashLastWashDate;
  DateTime _carWashNextWashDate = DateTime.now();
  DateTime get carWashNextWashDate => _carWashNextWashDate;

  // SubscriptionModel(
  //     {});
}
