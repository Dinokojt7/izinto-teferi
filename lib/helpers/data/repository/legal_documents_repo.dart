// legal_documents_repo.dart
import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class LegalDocumentsRepo extends GetxService {
  final ApiClient apiClient;
  LegalDocumentsRepo({required this.apiClient});

  Future<Response> getLegalDocuments() async {
    return await apiClient.getData(AppConstants.LEGAL_DOCUMENTS);
  }
}
