import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class RecommendedSpecialtyRepo extends GetxService {
  final ApiClient apiClient;
  RecommendedSpecialtyRepo({required this.apiClient});

  Future<Response> getRecommendedSpecialtyList() async {
    return await apiClient.getData(AppConstants.RECOMMENDED_SPECIALTY_URI);
  }
}
