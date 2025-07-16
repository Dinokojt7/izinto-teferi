import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class LaundrySupportQuestionsRepo extends GetxService {
  final ApiClient apiClient;
  LaundrySupportQuestionsRepo({required this.apiClient});

  Future<Response> getLaundrySupportQuestionsList() async {
    return await apiClient.getData(AppConstants.LAUNDRY_SUPPORT_QUESTIONS);
  }
}
