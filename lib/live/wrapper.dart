import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:izinto/controllers/car_specialty_controller.dart';
import 'package:izinto/controllers/favorite_controller.dart';
import 'package:izinto/controllers/gas_refill_specialty_controller.dart';
import 'package:izinto/controllers/carpet_care_specialty_controller.dart';
import 'package:izinto/controllers/legal_documents_controller.dart';
import 'package:izinto/controllers/pet_care_specialty_controller.dart';
import 'package:izinto/controllers/home_items_controller.dart';
import 'package:izinto/controllers/laundry_support_questions_controller.dart';
import 'package:izinto/controllers/recommendation_controller.dart';
import 'package:izinto/controllers/size_selection_controller.dart';
import 'package:izinto/controllers/sneakers_blankets_controller.dart';
import 'package:izinto/controllers/subscription_plans_controller.dart';
import 'package:izinto/controllers/tabs_header.dart';
import 'package:izinto/controllers/temperature_controller.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:izinto/live/view/auth_view/phone_auth_view.dart';
import 'package:izinto/live/view/home_view/guest_access.dart';
import 'package:izinto/live/view/home_view/home_view.dart';
import 'package:izinto/live/view/laundry_services/laundry_home_view.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/view/profile_view/profile_view.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/laundry_specialty_controller.dart';
import '../controllers/new_cart_controller.dart';
import '../controllers/popular_specialty_controller.dart';
import '../controllers/recommended_specialty_controller.dart';
import '../helpers/data/repository/cart_repo.dart';
import '../services/auth_service.dart';
import '../utils/dimensions.dart';
import 'auxiliery_classes/live_progress_indicator.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isInitialLoadComplete = false;
  Map<String, dynamic>? _userProfileData;
  bool _hasError = false;
  bool _hasAddresses = false;
  final Map<String, bool> _controllerLoadStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        setState(() {
          _isInitialLoadComplete = true;
        });
        FlutterNativeSplash.remove();
        return;
      }

      // Load critical data first
      await _loadCriticalData(authService, user.uid);

      // Load non-critical data with better error handling
      await _loadNonCriticalResources();

      setState(() {
        _isInitialLoadComplete = true;
      });

      FlutterNativeSplash.remove();
    } catch (e) {
      setState(() {
        _hasError = true;
        _isInitialLoadComplete = true;
      });
      FlutterNativeSplash.remove();
    }
  }

  Future<void> _loadCriticalData(AuthService authService, String uid) async {
    await _loadGuestAddress();
    await _loadUserProfileData(authService, uid);
    await _loadProfileViewController();
    await _loadOtherResources();
  }

  Future<void> _loadNonCriticalResources() async {
    final controllers = [
      _loadController(
          'RecommendedSpecialty',
          () => Get.find<RecommendedSpecialtyController>()
              .getRecommendedSpecialtyList()),
      _loadController('HomeItems',
          () => Get.find<HomeItemsController>().getHomeItemsList()),
      _loadController(
          'LaundrySpecialty',
          () =>
              Get.find<LaundrySpecialtyController>().getLaundrySpecialtyList()),
      _loadController(
          'GasRefillSpecialty',
          () => Get.find<GasRefillSpecialtyController>()
              .getGasRefillSpecialtyList()),
      _loadController(
          'CarpetCareSpecialty',
          () => Get.find<CarpetCareSpecialtyController>()
              .getCarpetCareSpecialtyList()),
      _loadController(
          'PetCareSpecialty',
          () =>
              Get.find<PetCareSpecialtyController>().getPetCareSpecialtyList()),
      _loadController(
          'Cart', () => Get.find<NewCartController>().getCartData()),
    ];

    // Load controllers with timeout and individual error handling
    for (var controllerLoad in controllers) {
      try {
        await controllerLoad().timeout(Duration(seconds: 10));
      } catch (e) {
        // Continue with other controllers even if one fails
      }
    }
  }

  Future<void> Function() _loadController(
      String name, Future<void> Function() loadFunction) {
    return () async {
      try {
        await loadFunction();
        _controllerLoadStatus[name] = true;
      } catch (e) {
        _controllerLoadStatus[name] = false;

        rethrow;
      }
    };
  }

  Future<void> _loadGuestAddress() async {
    try {
      final addressController =
          Provider.of<MainAddressViewController>(context, listen: false);
      await addressController.loadGuestAddressFromLocalStorage();
    } catch (e) {}
  }

  Future<void> _loadUserProfileData(AuthService authService, String uid) async {
    try {
      final data = await authService.getUserProfileData(uid);
      setState(() {
        _userProfileData = data;
      });

      // Update profile controller with fresh data
      if (data != null) {
        final controller =
            Provider.of<ProfileViewController>(context, listen: false);
        controller.updateNewUser(
          data['name'] ?? '',
          data['surname'] ?? '',
          data['email'] ?? '',
          data['phone'] ?? '',
          data['telephoneSurveyConsent'] ?? false,
          data['emailMarketingConsent'] ?? false,
          data['wallet'] ?? 0,
        );
      }

      // Check addresses once
      _hasAddresses = await authService.hasAddresses();
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  Future<void> _loadProfileViewController() async {
    try {
      final controller =
          Provider.of<ProfileViewController>(context, listen: false);
      await controller.getData();
      await controller.getAddresses();
    } catch (e) {}
  }

  Future<void> _loadControllerWithTimeout(
      Future<void> Function() loadFunction, String controllerName) async {
    try {
      await loadFunction().timeout(Duration(seconds: 10));
    } catch (e) {
      // Don't rethrow - let other controllers continue loading
    }
  }

  Future<void> _ensureCartControllers() async {
    if (!Get.isRegistered<TemperatureController>()) {
      Get.put(TemperatureController());
    }
    if (!Get.isRegistered<FavoriteController>()) {
      Get.put(FavoriteController());
    }
    if (!Get.isRegistered<SizeSelectionController>()) {
      Get.put(SizeSelectionController());
    }
  }

// Call this before building any cart-related screens
  Future<void> _loadOtherResources() async {
    try {
      await Future.wait(
          [
            _loadControllerWithTimeout(
                () => Get.find<TabsHeaderController>().getTabsHeaderList(),
                'TabsHeader'),
            _ensureCartControllers,
            Get.find<RecommendedSpecialtyController>()
                .getRecommendedSpecialtyList(),
            Get.find<CartController>().getCartHistoryList(),
            Get.find<NewCartController>().getCartData(),
            Get.find<FavoriteController>().onInit(),
            Get.find<RecommendationController>().getRecommendedItems(),
            Get.find<PopularSpecialtyController>().getPopularSpecialtyList(),
            Get.find<SneakersBlanketsController>().getSneakersAndBlanketsList(),
            Get.find<LaundrySpecialtyController>().getLaundrySpecialtyList(),
            Get.find<GasRefillSpecialtyController>()
                .getGasRefillSpecialtyList(),
            Get.find<CarpetCareSpecialtyController>()
                .getCarpetCareSpecialtyList(),
            Get.find<PetCareSpecialtyController>().getPetCareSpecialtyList(),
            Get.find<CarSpecialtyController>().getCarSpecialtyList(),
            Get.find<TabsHeaderController>().getTabsHeaderList(),
            Get.find<LaundrySupportQuestionsController>()
                .getLaundrySupportQuestions(),
            Get.find<LegalDocumentsController>().getLegalDocuments(),
            Get.find<HomeItemsController>().getHomeItemsList(),
            Get.find<CartRepo>().migrateOldCartToNew(),
            Get.find<SubscriptionPlansController>().getSubscriptionPlansList(),
          ] as Iterable<Future>,
          eagerError: false);
    } catch (e) {}
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.98),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: Dimensions.font26 * 2,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: Dimensions.height20),
              Text(
                'Unable to Load User Data',
                style: TextStyle(
                  fontSize: Dimensions.font20 / 1.2,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'Please try again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: Dimensions.height30),
              ElevatedButton(
                onPressed: () => _initializeApp(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width30 * 1.1,
                    vertical: Dimensions.height15 * 1.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    // Unauthenticated users go directly to auth
    if (user == null) {
      return const PhoneAuthView();
    }

    // Show loading while initializing
    if (!_isInitialLoadComplete) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: LiveProgressIndicator(
          color: Colors.black,
          hasOwnDialog: true,
        ),
      );
    }

    // Show error screen if initialization failed
    if (_hasError) {
      return _buildErrorScreen();
    }

    // Use cached data for routing decisions
    final hasBasicInfo = _userProfileData != null &&
        _userProfileData!['name'] != null &&
        _userProfileData!['name'] != '' &&
        _userProfileData!['surname'] != null &&
        _userProfileData!['surname'] != '' &&
        _userProfileData!['phone'] != null &&
        _userProfileData!['phone'] != '' &&
        _userProfileData!['email'] != null &&
        _userProfileData!['email'] != '';

    // Navigate through the flow using cached data
    if (!hasBasicInfo) {
      return const ProfileView();
    } else if (!_hasAddresses) {
      return const GuestAccess(isFromWrapper: true);
    } else {
      return const LaundryHomeView();
    }
  }
}
