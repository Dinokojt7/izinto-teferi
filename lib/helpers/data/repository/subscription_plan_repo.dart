import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class SubscriptionPlansRepo extends GetxService {
  final ApiClient apiClient;
  SubscriptionPlansRepo({required this.apiClient});

  Future<Response> getSubscriptionPlansRepoList() async {
    return await apiClient.getData(AppConstants.SUBSCRIPTION_PLANS);
  }
}
