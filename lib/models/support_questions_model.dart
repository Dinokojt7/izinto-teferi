class Questions {
  late List<QuestionsModel> _specialties;
  List<QuestionsModel> get specialties => _specialties;
  Questions({required specialties}) {
    this._specialties = specialties;
  }
  Questions.fromJson(Map<String, dynamic> json) {
    if (json['Specialties'] != null) {
      _specialties = <QuestionsModel>[];
      json['Specialties'].forEach((v) {
        _specialties.add(QuestionsModel.fromJson(v));
      });
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
