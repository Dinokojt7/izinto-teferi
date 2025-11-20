import 'package:get/get.dart';
import '../helpers/data/repository/subscription_plan_repo.dart';
import '../models/subscription_plans_model.dart';

class SubscriptionPlansController extends GetxController {
  final SubscriptionPlansRepo subscriptionPlansRepo;
  SubscriptionPlansController({required this.subscriptionPlansRepo});
  List<dynamic> _subscriptionPlansList = [];
  List<dynamic> get subscriptionPlansList => _subscriptionPlansList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getSubscriptionPlansList() async {
    Response response =
        await subscriptionPlansRepo.getSubscriptionPlansRepoList();
    if (response.statusCode == 200) {
      _subscriptionPlansList = [];
      _subscriptionPlansList.addAll(Plans.fromJson(response.body).specialties);

      _isLoaded = true;
      update();
    } else {}
  }
}
