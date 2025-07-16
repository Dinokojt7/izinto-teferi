import 'dart:core';
import 'package:get/get.dart';
import 'package:izinto/models/order_model.dart';
import 'package:izinto/pages/auth/email_sign_in.dart';
import 'package:izinto/pages/auth/phone_auth.dart';
import 'package:izinto/pages/auth/get_started.dart';
import 'package:izinto/pages/cart/post_checkout/cart_history_items.dart';
import 'package:izinto/pages/checkout/payment_page.dart';
import 'package:izinto/pages/home/main_components/main_specialty_page.dart';
import 'package:izinto/pages/on_boarding/first_onboard.dart';
import 'package:izinto/pages/options/profile_settings.dart';
import 'package:izinto/pages/specialty/recommended_specialty_Detail.dart';
import 'package:izinto/pages/specialty/recommended_specialty_grid_view.dart';
import 'package:izinto/pages/splash/splash_screen.dart';
import '../pages/cart/cart_page.dart';
import '../pages/checkout/order_received.dart';
import '../pages/home/home_page.dart';
import '../pages/options/location_settings.dart';
import '../pages/specialty/laundry_specialty_detail.dart';
import '../pages/specialty/popular_specialty_detail.dart';

class RouteHelper {
  static const String reSplashScreen = '/re-splash-screen';
  static const String splashScreen = '/splash-screen';
  static const String firstOnboard = '/first-onboard';
  static const String initial = '/';
  static const String recommendedSpecialties = '/recommended-specialties';
  static const String popularSpecialities = '/popular-specialties';
  static const String laundrySpecialties = '/laundry-specialties';
  static const String cartPage = '/cart-page';
  static const String cartHistory = '/cart-history';
  static const String signUpPage = '/sign_up';
  static const String signInPage = '/sign_in';
  static const String emailSignIn = '/email_sign_in';
  static const String phoneAuth = '/phone_auth';
  static const String mainPage = '/main_specialty_page';
  static const String recommendedSpecialtyGridView =
      '/recommended_specialty_grid_view';
  static const String locationSettings = '/location_settings';
  static const String profileSettings = '/profile_settings';
  static const String payment = '/payment';
  static const String orderReceived = '/order-successful';

  static String getRecommendedSpecialtyGridView() =>
      recommendedSpecialtyGridView;
  static String getMainPage() => mainPage;
  static String getSignUp() => signUpPage;
  static String getSignIn() => signInPage;
  static String getEmailSignIn() => emailSignIn;
  static String getPhoneAuth() => phoneAuth;
  static String getReSplashScreen() => reSplashScreen;
  static String getSplashScreen() => splashScreen;
  static String getFirstOnboard() => firstOnboard;
  static String getInitial() => initial;
  static String getPopularSpecialties(int pageId, String page) =>
      '$popularSpecialities?pageId=$pageId&page=$page';
  static String getLaundrySpecialties(int pageId, String page) =>
      '$laundrySpecialties?pageId=$pageId&page=$page';
  static String getRecommendedSpecialities(int pageId, String page) =>
      '$recommendedSpecialties?pageId=$pageId&page=$page';
  static String getCartPage() => cartPage;
  static String getCartHistoryItems() => cartHistory;
  static String getLocationSetting() => locationSettings;
  static String getProfileSettings() => profileSettings;
  static String getPaymentPage() => '$payment';
  static String getOrderSuccess() => '$orderReceived';

  static List<GetPage> routes = [
    GetPage(
        name: mainPage,
        page: () {
          return const MainSpecialtyPage();
        }),
    GetPage(
        name: recommendedSpecialtyGridView,
        page: () {
          return const RecommendedSpecialtyGridView();
        },
        transition: Transition.fadeIn),
    GetPage(
        name: signUpPage,
        page: () {
          return const GetStarted();
        },
        transition: Transition.fadeIn),
    GetPage(
      name: emailSignIn,
      page: () {
        return const EmailSignIn();
      },
    ),
    GetPage(
        name: phoneAuth,
        page: () {
          var phoneController;
          return PhoneAuth(phoneController.text);
        }),
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: firstOnboard, page: () => const FirstOnBoard()),
    GetPage(name: initial, page: () => const HomePage()),
    GetPage(
      name: recommendedSpecialties,
      page: () {
        var pageId = Get.parameters['pageId'];
        var page = Get.parameters['page'];
        return RecommendedSpecialtyDetail(
            pageId: int.parse(pageId!), page: page!);
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
        name: popularSpecialities,
        page: () {
          var pageId = Get.parameters['pageId'];
          var page = Get.parameters['page'];
          return PopularSpecialtyDetail(
              pageId: int.parse(pageId!), page: page!);
        },
        transition: Transition.fadeIn),
    GetPage(
        name: cartPage,
        page: () {
          return CartPage();
        },
        transition: Transition.fadeIn),
    GetPage(
        name: cartHistory,
        page: () {
          return const CartHistoryItems();
        },
        transition: Transition.fadeIn),
    GetPage(
        name: laundrySpecialties,
        page: () {
          var pageId = Get.parameters['pageId'];
          var page = Get.parameters['page'];
          return LaundrySpecialtyDetail(
              pageId: int.parse(pageId!), page: page!);
        },
        transition: Transition.fadeIn),
    GetPage(
        name: locationSettings,
        page: () {
          return const AddressSettings();
        },
        transition: Transition.cupertinoDialog),
    GetPage(
        name: profileSettings,
        page: () {
          return ProfileSettings();
        },
        transition: Transition.native),
    GetPage(name: orderReceived, page: () => OrderReceived()),
    GetPage(
      name: payment,
      page: () => PaymentPage(
        orderModel: OrderModel(),
      ),
    )
  ];
}
