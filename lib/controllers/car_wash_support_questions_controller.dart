import 'package:get/get.dart';
import '../helpers/data/repository/car-wash-support-questions-repo.dart';
import '../models/support_questions_model.dart';

class CarWashSupportQuestionsController extends GetxController {
  final CarWashSupportQuestionsRepo carWashSupportQuestionsRepo;
  CarWashSupportQuestionsController(
      {required this.carWashSupportQuestionsRepo});
  List<dynamic> _carWashSupportQuestionsList = [];
  List<dynamic> get carWashSupportQuestionsList => _carWashSupportQuestionsList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getCarWashSupportQuestionsList() async {
    Response response =
        await carWashSupportQuestionsRepo.getCarWashSupportQuestionsList();
    if (response.statusCode == 200) {
      _carWashSupportQuestionsList = [];
      _carWashSupportQuestionsList
          .addAll(Questions.fromJson(response.body).specialties);

      _isLoaded = true;
      update();
    } else {
      print('missing support questions ${response.statusCode}');
    }
  }
}
