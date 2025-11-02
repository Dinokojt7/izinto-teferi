import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class GasRefillSpecialtyRepo extends GetxService {
  final ApiClient apiClient;
  GasRefillSpecialtyRepo({required this.apiClient});

  Future<Response> getGasRefillSpecialtyList() async {
    return await apiClient.getData(AppConstants.GAS_REFILL_SPECIALTY_URI);
  }
}
