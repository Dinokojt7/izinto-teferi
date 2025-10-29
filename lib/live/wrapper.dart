import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:izinto/controllers/car_specialty_controller.dart';
import 'package:izinto/controllers/car_wash_support_questions_controller.dart';
import 'package:izinto/controllers/home_items_controller.dart';
import 'package:izinto/controllers/laundry_support_questions_controller.dart';
import 'package:izinto/controllers/subscription_plans_controller.dart';
import 'package:izinto/controllers/tabs_header.dart';
import 'package:izinto/live/view/auth_view/phone_auth_view.dart';
import 'package:izinto/live/view/cart_view/cart_view_page.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/view/home_view/guest_access.dart';
import 'package:izinto/live/view/home_view/home_view.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/models/user.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/laundry_specialty_controller.dart';
import '../controllers/popular_specialty_controller.dart';
import '../controllers/recommended_specialty_controller.dart';
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
    await Get.find<PopularSpecialtyController>().getPopularSpecialtyList();
    await Get.find<LaundrySpecialtyController>().getLaundrySpecialtyList();
    await Get.find<CarSpecialtyController>().getCarSpecialtyList();
    await Get.find<TabsHeaderController>().getTabsHeaderList();
    await Get.find<LaundrySupportQuestionsController>()
        .getLaundrySupportQuestionsList();
    await Get.find<HomeItemsController>().getHomeItemsList();
    await Get.find<CarWashSupportQuestionsController>()
        .getCarWashSupportQuestionsList();
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
        Brightness.dark, Colors.white.withOpacity(0.001), Brightness.dark);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    return Consumer<ProfileViewController>(
      builder: (context, profileController, child) {
        final List<dynamic> _addresses = profileController.savedAddresses;

        if (user == null) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (!didPop) {
                final focus = FocusScope.of(context);
                if (!focus.hasPrimaryFocus && focus.focusedChild != null) {
                  focus.unfocus();
                } else {
                  Navigator.of(context).maybePop();
                }
              }
            },
            child: PhoneAuthView(),
          );
        } else {
          if (_addresses.length == 0) {
            if (profileController.isLoading) {
              return Scaffold(
                body: Container(
                  height: double.maxFinite,
                  color: Colors.white,
                  child: Center(
                    child: LiveProgressIndicator(
                      hasOwnDialog: true,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                if (!didPop) {
                  final focus = FocusScope.of(context);
                  if (!focus.hasPrimaryFocus && focus.focusedChild != null) {
                    focus.unfocus();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                }
              },
              child: GuestAccess(),
            );
          }
          return HomeView();
        }
      },
    );
  }
}
