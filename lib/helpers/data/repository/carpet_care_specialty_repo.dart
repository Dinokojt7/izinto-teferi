import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class CarpetCareSpecialtyRepo extends GetxService {
  final ApiClient apiClient;
  CarpetCareSpecialtyRepo({required this.apiClient});

  Future<Response> getCarpetCareSpecialtyList() async {
    return await apiClient.getData(AppConstants.CARPET_CARE_SPECIALTY_URI);
  }
}
