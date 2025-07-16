import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class CarWashSupportQuestionsRepo extends GetxService {
  final ApiClient apiClient;
  CarWashSupportQuestionsRepo({required this.apiClient});

  Future<Response> getCarWashSupportQuestionsList() async {
    return await apiClient.getData(AppConstants.CAR_WASH_SUPPORT_QUESTIONS);
  }
}
