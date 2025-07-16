import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class LaundrySpecialtyRepo extends GetxService {
  final ApiClient apiClient;
  LaundrySpecialtyRepo({required this.apiClient});

  Future<Response> getLaundrySpecialtyList() async {
    return await apiClient.getData(AppConstants.LAUNDRY_SPECIALTY_URI);
  }
}
