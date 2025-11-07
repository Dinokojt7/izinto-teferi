// legal_documents_model.dart
class LegalDocuments {
  late List<LegalDocumentCategory> _categories;
  List<LegalDocumentCategory> get categories => _categories;

  late ContactInfo _contactInfo;
  ContactInfo get contactInfo => _contactInfo;

  late DocumentMetadata _metadata;
  DocumentMetadata get metadata => _metadata;

  LegalDocuments({
    required categories,
    required contactInfo,
    required metadata,
  }) {
    this._categories = categories;
    this._contactInfo = contactInfo;
    this._metadata = metadata;
  }

  LegalDocuments.fromJson(Map<String, dynamic> json) {
    if (json['Specialties'] != null) {
      _categories = <LegalDocumentCategory>[];
      json['Specialties'].forEach((v) {
        _categories.add(LegalDocumentCategory.fromJson(v));
      });
    }

    if (json['contactInfo'] != null) {
      _contactInfo = ContactInfo.fromJson(json['contactInfo']);
    } else {
      _contactInfo = ContactInfo(); // Default fallback
    }

    if (json['metadata'] != null) {
      _metadata = DocumentMetadata.fromJson(json['metadata']);
    } else {
      _metadata = DocumentMetadata(); // Default fallback
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

class ContactInfo {
  String? email;
  String? phone;
  String? supportHours;
  String? website;
  String? address;

  ContactInfo({
    this.email = 'info@izinto.africa',
    this.phone = '+27 81 725 8447',
    this.supportHours = 'Mon-Sun: 8:00 - 22:00',
    this.website = 'www.izinto.africa',
    this.address =
        '123 Innovation Street, Tech Park, Johannesburg, 2196, South Africa',
  });

  ContactInfo.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    phone = json['phone'];
    supportHours = json['supportHours'];
    website = json['website'];
    address = json['address'];
  }
}

class DocumentMetadata {
  String? lastUpdated;
  String? version;

  DocumentMetadata({
    this.lastUpdated = 'December 2024',
    this.version = '1.0.0',
  });

  DocumentMetadata.fromJson(Map<String, dynamic> json) {
    lastUpdated = json['lastUpdated'];
    version = json['version'];
  }
}
