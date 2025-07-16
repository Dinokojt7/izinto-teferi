import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class CarSpecialtyRepo extends GetxService {
  final ApiClient apiClient;
  CarSpecialtyRepo({required this.apiClient});

  Future<Response> getCarSpecialtyList() async {
    return await apiClient.getData(AppConstants.CAR_SPECIALTY_URI);
  }
}
