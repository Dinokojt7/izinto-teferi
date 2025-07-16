import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class HomeItemsRepo extends GetxService {
  final ApiClient apiClient;
  HomeItemsRepo({required this.apiClient});

  Future<Response> getHomeItemsList() async {
    return await apiClient.getData(AppConstants.HOME_ITEMS);
  }
}
