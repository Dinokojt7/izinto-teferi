// questions_model.dart
class Questions {
  late List<ServiceCategory> _categories;
  List<ServiceCategory> get categories => _categories;

  Questions({required categories}) {
    this._categories = categories;
  }

  Questions.fromJson(Map<String, dynamic> json) {
    if (json['Specialties'] != null) {
      _categories = <ServiceCategory>[];
      json['Specialties'].forEach((v) {
        _categories.add(ServiceCategory.fromJson(v));
      });
    }
  }
}

class ServiceCategory {
  String? categoryName;
  List<QuestionsModel>? questions;

  ServiceCategory({
    this.categoryName,
    this.questions,
  });

  ServiceCategory.fromJson(Map<String, dynamic> json) {
    // Get the first key as category name and its value as questions list
    if (json.isNotEmpty) {
      categoryName = json.keys.first;
      if (json[categoryName!] != null) {
        questions = <QuestionsModel>[];
        json[categoryName!].forEach((v) {
          questions!.add(QuestionsModel.fromJson(v));
        });
      }
    }
  }
}

class QuestionsModel {
  String? title;
  String? text;

  QuestionsModel({
    this.title,
    this.text,
  });

  QuestionsModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    text = json['text'];
  }

  Map<String, dynamic>? toJson() {
    return {
      'title': this.title,
      'text': this.text,
    };
  }
}
