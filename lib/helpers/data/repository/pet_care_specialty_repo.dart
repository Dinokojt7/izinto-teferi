import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class PetCareSpecialtyRepo extends GetxService {
  final ApiClient apiClient;
  PetCareSpecialtyRepo({required this.apiClient});

  Future<Response> getPetCareSpecialtyList() async {
    return await apiClient.getData(AppConstants.PET_CARE_SPECIALTY_URI);
  }
}
