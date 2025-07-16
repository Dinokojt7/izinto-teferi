import 'package:get/get.dart';
import '../helpers/data/repository/laundry_support_repo.dart';
import '../models/support_questions_model.dart';

class LaundrySupportQuestionsController extends GetxController {
  final LaundrySupportQuestionsRepo laundrySupportQuestionsRepo;
  LaundrySupportQuestionsController(
      {required this.laundrySupportQuestionsRepo});
  List<dynamic> _laundrySupportQuestionsList = [];
  List<dynamic> get laundrySupportQuestionsList => _laundrySupportQuestionsList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> getLaundrySupportQuestionsList() async {
    Response response =
        await laundrySupportQuestionsRepo.getLaundrySupportQuestionsList();
    if (response.statusCode == 200) {
      _laundrySupportQuestionsList = [];
      _laundrySupportQuestionsList
          .addAll(Questions.fromJson(response.body).specialties);

      _isLoaded = true;
      update();
    } else {
      print('missing support questions ${response.statusCode}');
    }
  }
}
