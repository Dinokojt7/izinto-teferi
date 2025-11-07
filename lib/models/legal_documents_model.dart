// legal_documents_model.dart
class LegalDocuments {
  late List<LegalDocumentCategory> _categories;
  List<LegalDocumentCategory> get categories => _categories;

  LegalDocuments({required categories}) {
    this._categories = categories;
  }

  LegalDocuments.fromJson(Map<String, dynamic> json) {
    if (json['Specialties'] != null) {
      _categories = <LegalDocumentCategory>[];
      json['Specialties'].forEach((v) {
        _categories.add(LegalDocumentCategory.fromJson(v));
      });
    }
  }
}

class LegalDocumentCategory {
  String? categoryName;
  List<LegalDocumentItem>? items;

  LegalDocumentCategory({
    this.categoryName,
    this.items,
  });

  LegalDocumentCategory.fromJson(Map<String, dynamic> json) {
    if (json.isNotEmpty) {
      categoryName = json.keys.first;
      if (json[categoryName!] != null) {
        items = <LegalDocumentItem>[];
        json[categoryName!].forEach((v) {
          items!.add(LegalDocumentItem.fromJson(v));
        });
      }
    }
  }
}

class LegalDocumentItem {
  String? title;
  String? content;

  LegalDocumentItem({
    this.title,
    this.content,
  });

  LegalDocumentItem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
  }
}
