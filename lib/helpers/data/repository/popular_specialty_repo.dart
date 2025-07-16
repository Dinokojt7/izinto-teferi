import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class PopularSpecialtyRepo extends GetxService {
  final ApiClient apiClient;
  PopularSpecialtyRepo({required this.apiClient});

  Future<Response> getPopularSpecialtyList() async {
    return await apiClient.getData(AppConstants.POPULAR_SPECIALTY_URI);
  }
}
