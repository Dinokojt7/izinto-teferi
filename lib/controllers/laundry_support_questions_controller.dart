// laundry_support_questions_controller.dart
import 'package:get/get.dart';

import '../helpers/data/repository/laundry_support_repo.dart';
import '../models/support_questions_model.dart';

class LaundrySupportQuestionsController extends GetxController {
  final LaundrySupportQuestionsRepo laundrySupportQuestionsRepo;

  LaundrySupportQuestionsController(
      {required this.laundrySupportQuestionsRepo});

  List<ServiceCategory> _laundrySupportCategories = [];
  List<ServiceCategory> get laundrySupportCategories =>
      _laundrySupportCategories;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> getLaundrySupportQuestions() async {
    try {
      _isLoaded = false;
      _errorMessage = '';
      update();

      Response response =
          await laundrySupportQuestionsRepo.getLaundrySupportQuestionsList();

      if (response.statusCode == 200) {
        final data = response.body;
        final questions = Questions.fromJson(data);
        _laundrySupportCategories = questions.categories;
        _isLoaded = true;
      } else {
        _errorMessage = 'Failed to load questions: ${response.statusText}';
        _isLoaded = true;
      }
    } catch (error) {
      print('Error fetching laundry questions: $error');
      _errorMessage = 'An error occurred while loading questions';
      _isLoaded = true;
    } finally {
      update();
    }
  }

  @override
  void onInit() {
    getLaundrySupportQuestions();
    super.onInit();
  }
}
