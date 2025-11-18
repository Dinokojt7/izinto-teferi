import 'package:get/get.dart';
import 'package:izinto/models/legal_documents_model.dart';
import '../helpers/data/repository/legal_documents_repo.dart';
import 'package:flutter/foundation.dart';

class LegalDocumentsController extends GetxController {
  final LegalDocumentsRepo legalDocumentsRepo;

  LegalDocumentsController({required this.legalDocumentsRepo});

  // Use Rx for reactive state management
  final RxList<LegalDocumentCategory> _legalDocuments =
      <LegalDocumentCategory>[].obs;
  List<LegalDocumentCategory> get legalDocuments => _legalDocuments;

  final Rx<ContactInfo> _contactInfo = ContactInfo().obs;
  ContactInfo get contactInfo => _contactInfo.value;

  final Rx<DocumentMetadata> _metadata = DocumentMetadata().obs;
  DocumentMetadata get metadata => _metadata.value;

  final RxBool _isLoaded = false.obs;
  bool get isLoaded => _isLoaded.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    getLegalDocuments();
  }

  Future<void> getLegalDocuments({bool forceRefresh = false}) async {
    if (_isLoading.value || (_isLoaded.value && !forceRefresh)) {
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      Response response = await legalDocumentsRepo.getLegalDocuments();

      if (response.statusCode == 200) {
        final data = response.body;
        final documents = LegalDocuments.fromJson(data);
        _legalDocuments.value = documents.categories;
        _contactInfo.value = documents.contactInfo;
        _metadata.value = documents.metadata;
        _isLoaded.value = true;

        if (kDebugMode) {
          print(
              'Legal documents loaded successfully: ${_legalDocuments.length} categories');
        }
      } else {
        _handleError(
            'Failed to load documents: ${response.statusCode} ${response.statusText}');
      }
    } catch (error) {
      _handleError('Network error: $error');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  void _handleError(String message) {
    _errorMessage.value = message;
    if (kDebugMode) {
      print('LegalDocumentsController Error: $message');
    }

    // Auto-retry after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (!_isLoaded.value && !_isLoading.value) {
        getLegalDocuments();
      }
    });
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

  // Retry method for manual retry
  void retryLoading() {
    getLegalDocuments(forceRefresh: true);
  }

  // Clear error method
  void clearError() {
    _errorMessage.value = '';
  }
}
