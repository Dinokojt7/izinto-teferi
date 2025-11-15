import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class SneakersBlanketsRepo extends GetxService {
  final ApiClient apiClient;
  SneakersBlanketsRepo({required this.apiClient});

  Future<Response> getSneakersAndBlanketsList() async {
    return await apiClient.getData(AppConstants.SNEAKER_LAUNDRY_URI);
  }
}
