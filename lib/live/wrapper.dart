import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:izinto/controllers/car_specialty_controller.dart';
import 'package:izinto/controllers/car_wash_support_questions_controller.dart';
import 'package:izinto/controllers/favorite_controller.dart';
import 'package:izinto/controllers/gas_refill_specialty_controller.dart';
import 'package:izinto/controllers/carpet_care_specialty_controller.dart';
import 'package:izinto/controllers/legal_documents_controller.dart';
import 'package:izinto/controllers/pet_care_specialty_controller.dart';
import 'package:izinto/controllers/home_items_controller.dart';
import 'package:izinto/controllers/laundry_support_questions_controller.dart';
import 'package:izinto/controllers/recommendation_controller.dart';
import 'package:izinto/controllers/size_selection_controller.dart';
import 'package:izinto/controllers/subscription_plans_controller.dart';
import 'package:izinto/controllers/tabs_header.dart';
import 'package:izinto/controllers/temperature_controller.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:izinto/live/view/auth_view/phone_auth_view.dart';
import 'package:izinto/live/view/cart_view/cart_view_page.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/view/home_view/guest_access.dart';
import 'package:izinto/live/view/home_view/home_view.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/view/profile_view/profile_view.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/profile_big_text.dart';
import 'package:izinto/models/user.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/laundry_specialty_controller.dart';
import '../controllers/new_cart_controller.dart';
import '../controllers/popular_specialty_controller.dart';
import '../controllers/recommended_specialty_controller.dart';
import '../helpers/data/repository/cart_repo.dart';
import 'auxiliery_classes/live_progress_indicator.dart';
import 'utilities/generic_system_navigation.dart';
import '../services/phone_auth_methods.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isInitialLoadComplete = false;
  bool _isProfileDataLoaded = false;

  Future<void> _loadProfileData() async {
    try {
      await Provider.of<ProfileViewController>(context, listen: false)
          .getData();
      await Provider.of<ProfileViewController>(context, listen: false)
          .getAddresses();
      setState(() {
        _isProfileDataLoaded = true;
      });
    } catch (e) {
      setState(() {
        _isProfileDataLoaded = true;
      });
    }
  }

  Future<void> _loadOtherResources() async {
    try {
      await Future.wait([
        Get.find<RecommendedSpecialtyController>()
            .getRecommendedSpecialtyList(),
        Get.find<CartController>().getCartHistoryList(),
        Get.find<NewCartController>().getCartData(),
        Get.find<FavoriteController>().onInit(),
        Get.find<RecommendationController>().getRecommendedItems(),
        Get.find<PopularSpecialtyController>().getPopularSpecialtyList(),
        Get.find<LaundrySpecialtyController>().getLaundrySpecialtyList(),
        Get.find<GasRefillSpecialtyController>().getGasRefillSpecialtyList(),
        Get.find<CarpetCareSpecialtyController>().getCarpetCareSpecialtyList(),
        Get.find<PetCareSpecialtyController>().getPetCareSpecialtyList(),
        Get.find<CarSpecialtyController>().getCarSpecialtyList(),
        Get.find<TabsHeaderController>().getTabsHeaderList(),
        Get.find<LaundrySupportQuestionsController>()
            .getLaundrySupportQuestions(),
        Get.find<LegalDocumentsController>().getLegalDocuments(),
        Get.find<HomeItemsController>().getHomeItemsList(),
        Get.find<CarWashSupportQuestionsController>()
            .getCarWashSupportQuestionsList(),
        Get.find<CartRepo>().migrateOldCartToNew(),
        Get.find<SubscriptionPlansController>().getSubscriptionPlansList(),
      ] as Iterable<Future>);
    } catch (e) {}
  }

  Future<void> _loadGuestAddress() async {
    try {
      final addressController =
          Provider.of<MainAddressViewController>(context, listen: false);
      await addressController.loadGuestAddressFromLocalStorage();
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Load guest address first (fast operation)
      await _loadGuestAddress();

      // Load profile data first (critical for routing)
      await _loadProfileData();

      // Then load other resources in background (non-critical)
      _loadOtherResources();

      setState(() {
        _isInitialLoadComplete = true;
      });

      FlutterNativeSplash.remove();
    } catch (e) {
      setState(() {
        _isInitialLoadComplete = true;
        _isProfileDataLoaded = true;
      });
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    // Show loading screen until everything is ready
    if (!_isInitialLoadComplete || (user != null && !_isProfileDataLoaded)) {
      return _buildLoadingScreen();
    }

    // Unauthenticated users go directly to auth
    if (user == null) {
      return const PhoneAuthView();
    }

    // Authenticated users - determine routing based on profile data
    return Consumer<ProfileViewController>(
      builder: (context, profileController, child) {
        final hasBasicInfo = profileController.firstName.isNotEmpty &&
            profileController.lastName.isNotEmpty &&
            profileController.emailAddress.isNotEmpty &&
            profileController.phoneNumber.isNotEmpty;

        final hasAddresses = profileController.savedAddresses.isNotEmpty;

        // Decision tree - only show these screens if data is actually missing
        // if (!hasBasicInfo) {
        //   return const ProfileView();
        if (!hasAddresses) {
          return const GuestAccess();
        } else {
          return const HomeView();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        color: Colors.white,
        child: const Center(
          child: LiveProgressIndicator(
            hasOwnDialog: true,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
