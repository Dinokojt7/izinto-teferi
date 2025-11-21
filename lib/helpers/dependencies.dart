import 'package:get/get.dart';
import 'package:izinto/controllers/cart_controller.dart';
import 'package:izinto/controllers/carpet_care_specialty_controller.dart';
import 'package:izinto/controllers/gas_refill_specialty_controller.dart';
import 'package:izinto/controllers/home_items_controller.dart';
import 'package:izinto/controllers/laundry_specialty_controller.dart';
import 'package:izinto/controllers/laundry_support_questions_controller.dart';
import 'package:izinto/controllers/pet_care_specialty_controller.dart';
import 'package:izinto/controllers/recommended_specialty_controller.dart';
import 'package:izinto/controllers/sneakers_blankets_controller.dart';
import 'package:izinto/controllers/subscription_plans_controller.dart';
import 'package:izinto/helpers/data/api/api_client.dart';
import 'package:izinto/helpers/data/repository/car-wash-support-questions-repo.dart';
import 'package:izinto/helpers/data/repository/carpet_care_specialty_repo.dart';
import 'package:izinto/helpers/data/repository/cart_repo.dart';
import 'package:izinto/helpers/data/repository/gas_refill_specialty_repo.dart';
import 'package:izinto/helpers/data/repository/home_items_repo.dart';
import 'package:izinto/helpers/data/repository/laundry_specialty_repo.dart';
import 'package:izinto/helpers/data/repository/laundry_support_repo.dart';
import 'package:izinto/helpers/data/repository/pet_care_specialty_repo.dart';
import 'package:izinto/helpers/data/repository/recommended_specialty_repo.dart';
import 'package:izinto/helpers/data/repository/sneakers_blankets_repo.dart';
import 'package:izinto/helpers/data/repository/subscription_plan_repo.dart';
import 'package:izinto/helpers/data/repository/tabs_header_repo.dart';
import 'package:izinto/live/view/order_support/controller/order_support_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/car_specialty_controller.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/legal_documents_controller.dart';
import '../controllers/new_cart_controller.dart';
import '../controllers/new_recommended_specialty_controller.dart';
import '../controllers/popular_specialty_controller.dart';
import '../controllers/recommendation_controller.dart';
import '../controllers/size_selection_controller.dart';
import '../controllers/tabs_header.dart';
import '../controllers/temperature_controller.dart';
import '../live/view/home_view/car_wash_view/controller/car_wash_controller.dart';
import '../utils/app_constants.dart';
import 'data/repository/auth_repo.dart';
import 'data/repository/car_specialty_repo.dart';
import 'data/repository/legal_documents_repo.dart';
import 'data/repository/popular_specialty_repo.dart';
import 'data/repository/user_repo.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(() => sharedPreferences);

  //This is our ApiClient
  Get.lazyPut(() => ApiClient(
      appBaseUrl: AppConstants.BASE_URL, sharedPreferences: Get.find()));

  Get.lazyPut(
      () => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => UserRepo(apiClient: Get.find()));

  //This will get our repositories
  Get.lazyPut(() => PopularSpecialtyRepo(apiClient: Get.find()));
  Get.lazyPut(() => SneakersBlanketsRepo(apiClient: Get.find()));
  Get.lazyPut(() => RecommendedSpecialtyRepo(apiClient: Get.find()));
  Get.lazyPut(() => CartRepo(sharedPreferences: Get.find()));
  Get.lazyPut(() => LaundrySpecialtyRepo(apiClient: Get.find()));
  Get.lazyPut(() => CarSpecialtyRepo(apiClient: Get.find()));

  // NEW REPOSITORIES
  Get.lazyPut(() => GasRefillSpecialtyRepo(apiClient: Get.find()));
  Get.lazyPut(() => CarpetCareSpecialtyRepo(apiClient: Get.find()));
  Get.lazyPut(() => PetCareSpecialtyRepo(apiClient: Get.find()));

  Get.lazyPut(() => TabsHeaderRepo(apiClient: Get.find()));
  Get.lazyPut(() => LaundrySupportQuestionsRepo(apiClient: Get.find()));
  Get.lazyPut(() => CarWashSupportQuestionsRepo(apiClient: Get.find()));
  Get.lazyPut(() => SubscriptionPlansRepo(apiClient: Get.find()));
  Get.lazyPut(() => HomeItemsRepo(apiClient: Get.find()));

  Get.lazyPut(() => CarWashController());

  //This is the new dependency repos
  Get.lazyPut(() => NewCartController(cartRepo: Get.find()));
  Get.lazyPut(() =>
      NewRecommendedSpecialtyController(recommendedSpecialtyRepo: Get.find()));
  //controller

  Get.lazyPut(() =>
      RecommendedSpecialtyController(recommendedSpecialtyRepo: Get.find()));
  Get.lazyPut(
      () => PopularSpecialtyController(popularSpecialtyRepo: Get.find()));
  Get.lazyPut(
      () => SneakersBlanketsController(sneakersAndBlanketsRepo: Get.find()));
  Get.lazyPut(() => RecommendationController());
  Get.lazyPut(() => FavoriteController());
  Get.lazyPut(() => TemperatureController());
  Get.lazyPut(() => SizeSelectionController());

  // Laundry Specialty Controller
  Get.lazyPut(() => LaundrySpecialtyController(
      laundrySpecialtyRepo: Get.find(), cartRepo: Get.find()));

  // Car Specialty Controller
  Get.lazyPut(() => CarSpecialtyController(carSpecialtyRepo: Get.find()));

  // NEW SPECIALTY CONTROLLERS
  Get.lazyPut(() => GasRefillSpecialtyController(
      gasRefillRepo: Get.find(), cartRepo: Get.find()));

  Get.lazyPut(() => CarpetCareSpecialtyController(
      carpetCareRepo: Get.find(), cartRepo: Get.find()));

// In your dependencies.dart
  Get.lazyPut(() => PetCareSpecialtyController(
        petCareRepo: Get.find(), // Remove cartRepo parameter
      ));
  // In your main binding file
  Get.lazyPut(() => LegalDocumentsRepo(apiClient: Get.find()));
  Get.lazyPut(() => LegalDocumentsController(legalDocumentsRepo: Get.find()));
  Get.lazyPut(() => OrderSupportController());
  Get.lazyPut(() => CartController(cartRepo: Get.find()));
  Get.lazyPut(() => TabsHeaderController(tabsHeaderRepo: Get.find()));
  Get.lazyPut(() => LaundrySupportQuestionsController(
      laundrySupportQuestionsRepo: Get.find()));
  Get.lazyPut(
      () => SubscriptionPlansController(subscriptionPlansRepo: Get.find()));
  Get.lazyPut(() => HomeItemsController(homeItemsRepo: Get.find()));
}
