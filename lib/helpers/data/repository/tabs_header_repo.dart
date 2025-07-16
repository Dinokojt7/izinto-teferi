import 'package:get/get.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/utils/app_constants.dart';

class TabsHeaderRepo extends GetxService {
  final ApiClient apiClient;
  TabsHeaderRepo({required this.apiClient});

  Future<Response> getTabsHeaderList() async {
    return await apiClient.getData(AppConstants.TABS_HEADER_URI);
  }
}
