// legal_documents_controller.dart
import 'package:get/get.dart';
import 'package:izinto/models/legal_documents_model.dart';
import '../helpers/data/repository/legal_documents_repo.dart';

class LegalDocumentsController extends GetxController {
  final LegalDocumentsRepo legalDocumentsRepo;

  LegalDocumentsController({required this.legalDocumentsRepo});

  List<LegalDocumentCategory> _legalDocuments = [];
  List<LegalDocumentCategory> get legalDocuments => _legalDocuments;

  ContactInfo _contactInfo = ContactInfo();
  ContactInfo get contactInfo => _contactInfo;

  DocumentMetadata _metadata = DocumentMetadata();
  DocumentMetadata get metadata => _metadata;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> getLegalDocuments() async {
    try {
      _isLoaded = false;
      _errorMessage = '';
      update();

      Response response = await legalDocumentsRepo.getLegalDocuments();

      if (response.statusCode == 200) {
        final data = response.body;
        final documents = LegalDocuments.fromJson(data);
        _legalDocuments = documents.categories;
        _contactInfo = documents.contactInfo;
        _metadata = documents.metadata;
        _isLoaded = true;
      } else {
        _errorMessage = 'Failed to load documents: ${response.statusText}';
        _isLoaded = true;
      }
    } catch (error) {
      print('Error fetching legal documents: $error');
      _errorMessage = 'An error occurred while loading documents';
      _isLoaded = true;
    } finally {
      update();
    }
  }

  // Helper method to get specific document by type
  LegalDocumentCategory? getDocumentByType(String documentType) {
    try {
      return _legalDocuments.firstWhere(
        (doc) => doc.categoryName == documentType,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper method to check if document exists
  bool hasDocument(String documentType) {
    return getDocumentByType(documentType) != null;
  }

  @override
  void onInit() {
    getLegalDocuments();
    super.onInit();
  }
}
