import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/car_specialty_controller.dart';
import 'package:izinto/controllers/cart_controller.dart';
import 'package:izinto/controllers/checkout_controller.dart';
import 'package:izinto/controllers/laundry_specialty_controller.dart';
import 'package:izinto/controllers/legal_documents_controller.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/controllers/popular_specialty_controller.dart';
import 'package:izinto/controllers/recommendation_controller.dart';
import 'package:izinto/controllers/recommended_specialty_controller.dart';
import 'package:izinto/controllers/sneakers_blankets_controller.dart';
import 'package:izinto/controllers/subscription_plans_controller.dart';
import 'package:izinto/controllers/tabs_header.dart';
import 'package:izinto/helpers/dependencies.dart' as dep;
import 'package:izinto/live/auxiliery_classes/cart_recommended_items_controller.dart';
import 'package:izinto/live/view/auth_view/phone_auth_view.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:izinto/live/view/checkout_view/controller/riderTip_controller.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/view/home_view/guest_access.dart';
import 'package:izinto/live/view/home_view/home_view.dart';
import 'package:izinto/live/view/order_history_view/controller/order_history_controller.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/view/profile_view/profile_view.dart';
import 'package:izinto/live/view/user_settings_view/controller/user_settings_controller.dart';
import 'package:izinto/models/user.dart';
import 'package:izinto/routes/route_helper.dart';
import 'package:izinto/services/auth_service.dart';
import 'package:izinto/services/dependency_injection.dart';
import 'package:izinto/services/firebase_auth_methods.dart';
import 'package:izinto/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'controllers/home_items_controller.dart';
import 'controllers/laundry_support_questions_controller.dart';
import 'controllers/size_selection_controller.dart';
import 'controllers/user_data_controller.dart';
import 'firebase_options.dart';
import 'live/utilities/system_navigaton_observer.dart';
import 'live/view/address_view/controller/address_dropdown_controller.dart';
import 'live/view/auth_view/controller/phone_auth_view_controller.dart';
import 'live/view/cart_view/controller/cart_actions_controller.dart';
import 'live/view/home_view/category_view/controller/category_view_controller.dart';
import 'live/view/order_support/controller/order_support_controller.dart';
import 'live/wrapper.dart';

/// Initialize Firebase Messaging and setup notification handlers
Future<void> setupFirebaseMessaging() async {
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Setup chat message listeners
  notificationService.setupChatMessageListener();
}

/// Handle foreground messages
void handleForegroundMessage(RemoteMessage message) {
  // For example, using GetX:
  if (message.notification != null) {
    Get.snackbar(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      backgroundColor: Colors.white,
      colorText: Colors.black,
    );
  }
}

/// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Handle background message

  // You can process the background message here
  // For example, update local data, show local notification using system APIs, etc.

  // Note: Since we removed flutter_local_notifications, you might want to use
  // the system's native notification capabilities or handle data messages directly
  if (message.data.isNotEmpty) {}
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // DEBUG: Use explicit Firebase options
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDQY8tW-zImz3hIPxw8z5QgQErJRl1NHrk',
        appId: '1:406571227857:android:374fb323036907e6a603f0',
        messagingSenderId: '406571227857',
        projectId: 'izinto-domestically',
        storageBucket: 'izinto-domestically.appspot.com',
      ),
    );
  } catch (e, stack) {}
  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidPlayIntegrityProvider(),
  );
  await FirebaseAuth.instance.setLanguageCode("en");
  // Setup Firebase Messaging
  await setupFirebaseMessaging();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen(handleForegroundMessage);

  // Handle when app is opened from terminated state
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print(
        'App opened from terminated state with message: ${message.messageId}',
      );
      // Handle the message, e.g., navigate to specific screen
    }
  });

  // Handle when app is opened from background state
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle the message, e.g., navigate to specific screen
  });

  await dep.init();
  NetworkInjection.init();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // navigation bar color
      statusBarColor: Colors.transparent, // status bar color
      statusBarBrightness: Brightness.light, //status bar brightness
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness:
          Brightness.light, //status barIcon Brightness
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // runApp(DevicePreview(builder: (context) => const MyApp(), enabled: true));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<CartController>().getCartData();

    return GetBuilder<SneakersBlanketsController>(
      builder: (_) {
        return GetBuilder<PopularSpecialtyController>(
          builder: (_) {
            return GetBuilder<RecommendationController>(
              builder: (_) {
                return GetBuilder<LaundrySpecialtyController>(
                  builder: (_) {
                    return GetBuilder<CarSpecialtyController>(
                      builder: (_) {
                        return GetBuilder<SubscriptionPlansController>(
                          builder: (_) {
                            return GetBuilder<TabsHeaderController>(
                              builder: (_) {
                                return GetBuilder<LegalDocumentsController>(
                                  builder: (_) {
                                    return GetBuilder<
                                        LaundrySupportQuestionsController>(
                                      builder: (_) {
                                        return GetBuilder<HomeItemsController>(
                                          builder: (_) {
                                            return GetBuilder<
                                                SizeSelectionController>(
                                              builder: (_) {
                                                return GetBuilder<
                                                    CarWashController>(
                                                  builder: (_) {
                                                    return GetBuilder<
                                                        RecommendedSpecialtyController>(
                                                      builder: (_) {
                                                        return GetBuilder<
                                                            NewCartController>(
                                                          builder: (_) {
                                                            return StreamProvider<
                                                                UserModel?>.value(
                                                              value:
                                                                  FirebaseAuthMethods()
                                                                      .user,
                                                              initialData:
                                                                  UserModel(
                                                                uid: '',
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                return MultiProvider(
                                                                  providers: [
                                                                    StreamProvider<
                                                                        UserModel?>.value(
                                                                      value: FirebaseAuthMethods()
                                                                          .user,
                                                                      initialData:
                                                                          UserModel(
                                                                        uid: '',
                                                                      ),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        PhoneAuthViewController>(
                                                                      create: (_) =>
                                                                          PhoneAuthViewController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        ProfileViewController>(
                                                                      create: (_) =>
                                                                          ProfileViewController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        MainAddressViewController>(
                                                                      create: (_) =>
                                                                          MainAddressViewController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        CategoryViewController>(
                                                                      create: (_) =>
                                                                          CategoryViewController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        RiderTipController>(
                                                                      create: (_) =>
                                                                          RiderTipController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        CheckoutViewController>(
                                                                      create: (_) =>
                                                                          CheckoutViewController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        CartRecommendedItemsController>(
                                                                      create: (_) =>
                                                                          CartRecommendedItemsController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        CheckoutController>(
                                                                      create: (_) =>
                                                                          CheckoutController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        UserDataController>(
                                                                      create: (_) =>
                                                                          UserDataController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        HomeViewController>(
                                                                      create: (_) =>
                                                                          HomeViewController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        CartRecommendedItemsController>(
                                                                      create: (_) =>
                                                                          CartRecommendedItemsController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        CartActionsController>(
                                                                      create: (_) =>
                                                                          CartActionsController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        UserSettingsController>(
                                                                      create: (_) =>
                                                                          UserSettingsController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        OrderHistoryController>(
                                                                      create: (_) =>
                                                                          OrderHistoryController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        OrderSupportController>(
                                                                      create: (_) =>
                                                                          OrderSupportController(),
                                                                    ),
                                                                    ChangeNotifierProvider<
                                                                        OrderSupportController>(
                                                                      create: (_) =>
                                                                          OrderSupportController(),
                                                                    ),
                                                                    Provider<
                                                                        NotificationService>(
                                                                      create: (_) =>
                                                                          NotificationService(),
                                                                    ),
                                                                    Provider<
                                                                        AuthService>(
                                                                      create: (_) =>
                                                                          AuthService(),
                                                                    ),
                                                                  ],
                                                                  child:
                                                                      GetMaterialApp(
                                                                    debugShowCheckedModeBanner:
                                                                        false,
                                                                    navigatorObservers: [
                                                                      SystemNavigationObserver(),
                                                                    ],
                                                                    title:
                                                                        'Izinto',
                                                                    home:
                                                                        Wrapper(),
                                                                    routes: {
                                                                      '/login': (
                                                                        context,
                                                                      ) =>
                                                                          const PhoneAuthView(),
                                                                      '/home': (
                                                                        context,
                                                                      ) =>
                                                                          const HomeView(),
                                                                      '/profile': (
                                                                        context,
                                                                      ) =>
                                                                          const ProfileView(),
                                                                      '/guest-access': (
                                                                        context,
                                                                      ) =>
                                                                          const GuestAccess(),
                                                                    },
                                                                    theme:
                                                                        ThemeData(
                                                                      colorScheme:
                                                                          ColorScheme
                                                                              .fromSeed(
                                                                        seedColor:
                                                                            Colors.white,
                                                                        // base for a white theme
                                                                        // Your primary color
                                                                        brightness:
                                                                            Brightness.light,
                                                                      ),
                                                                    ),
                                                                    getPages:
                                                                        RouteHelper
                                                                            .routes,
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
