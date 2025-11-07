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
  Future<void> _loadResources() async {
    Provider.of<ProfileViewController>(context, listen: false).getData();

    Provider.of<ProfileViewController>(context, listen: false).getAddresses();
    await Get.find<RecommendedSpecialtyController>()
        .getRecommendedSpecialtyList();
    await Get.find<CartController>().getCartHistoryList();
    await Get.find<NewCartController>().getCartData();
    await Get.find<TemperatureController>();
    await Get.find<SizeSelectionController>();
    await Get.find<FavoriteController>();

    await Get.find<RecommendationController>();
    await Get.find<PopularSpecialtyController>().getPopularSpecialtyList();
    await Get.find<LaundrySpecialtyController>().getLaundrySpecialtyList();
    await Get.find<GasRefillSpecialtyController>().getGasRefillSpecialtyList();
    await Get.find<CarpetCareSpecialtyController>()
        .getCarpetCareSpecialtyList();
    await Get.find<PetCareSpecialtyController>().getPetCareSpecialtyList();
    await Get.find<CarSpecialtyController>().getCarSpecialtyList();
    await Get.find<TabsHeaderController>().getTabsHeaderList();
    await Get.find<LaundrySupportQuestionsController>()
        .getLaundrySupportQuestions();
    await Get.find<LegalDocumentsController>().getLegalDocuments();
    await Get.find<HomeItemsController>().getHomeItemsList();
    await Get.find<CarWashSupportQuestionsController>()
        .getCarWashSupportQuestionsList();
    await Get.find<CartRepo>().migrateOldCartToNew();

    await Get.find<SubscriptionPlansController>().getSubscriptionPlansList();
    await Get.find<PhoneAuthMethods>();

    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    super.initState();

    _loadResources();
  }

  @override
  void didChangeDependencies() {
    var navBarColor =
        Provider.of<HomeViewController>(context).navigationBarColor;
    SystemNavigation().applyCustomSystemChromeSettings(navBarColor,
        Brightness.light, Colors.black.withOpacity(0.001), Brightness.light);

    super.didChangeDependencies();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    return Consumer<ProfileViewController>(
      builder: (context, profileController, child) {
        // Show loader while initial data is being loaded
        if (user != null &&
            profileController.firstName.isEmpty &&
            profileController.isLoading) {
          return _buildLoadingScreen();
        }

        if (user == null) {
          return const PhoneAuthView();
        }

        // At this point, we should have user data loaded via getData()
        final hasBasicInfo = profileController.firstName.isNotEmpty &&
            profileController.lastName.isNotEmpty &&
            profileController.emailAddress.isNotEmpty &&
            profileController.phoneNumber.isNotEmpty;

        final hasAddresses = profileController.savedAddresses.isNotEmpty;

        // Decision tree
        if (!hasBasicInfo) {
          return const ProfileView();
        } else if (!hasAddresses) {
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
