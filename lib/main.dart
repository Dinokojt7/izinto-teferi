import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:izinto/bindings/initial_binding.dart';
import 'package:izinto/controllers/car_specialty_controller.dart';
import 'package:izinto/controllers/cart_controller.dart';
import 'package:izinto/controllers/checkout_controller.dart';
import 'package:izinto/controllers/laundry_specialty_controller.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/controllers/popular_specialty_controller.dart';
import 'package:izinto/controllers/recommended_specialty_controller.dart';
import 'package:izinto/controllers/subscription_plans_controller.dart';
import 'package:izinto/controllers/tabs_header.dart';
import 'package:izinto/data_uploader_screen.dart';
import 'package:izinto/helpers/dependencies.dart' as dep;
import 'package:izinto/live/auxiliery_classes/cart_recommended_items_controller.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:izinto/live/view/checkout_view/controller/riderTip_controller.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/view/order_history_view/controller/order_history_controller.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/view/user_settings_view/controller/user_settings_controller.dart';
import 'package:izinto/models/user.dart';
import 'package:izinto/pages/cart/cart_page.dart';
import 'package:izinto/pages/cart/cart_processes_and_widgets/cart_view_controller.dart';
import 'package:izinto/pages/checkout/order_success.dart';
import 'package:izinto/pages/checkout/payment_page.dart';
import 'package:izinto/pages/home/home_route.dart';
import 'package:izinto/live/wrapper.dart';

import 'package:izinto/pages/options/profile_settings.dart';
import 'package:izinto/pages/splash/splash_screen.dart';
import 'package:izinto/routes/route_helper.dart';
import 'package:izinto/services/dependency_injection.dart';
import 'package:izinto/services/firebase_auth_methods.dart';
import 'package:izinto/services/location/location_model.dart';
import 'package:izinto/services/location/location_service.dart';
import 'package:izinto/services/phone_auth_methods.dart';
import 'package:izinto/services/subscription_methods.dart';
import 'package:izinto/utils/colors.dart';
import 'package:izinto/widgets/location/address_details_view.dart';
import 'package:provider/provider.dart';
import 'controllers/car_wash_support_questions_controller.dart';
import 'controllers/carpet_care_specialty_controller.dart';
import 'controllers/gas_refill_specialty_controller.dart';
import 'controllers/home_items_controller.dart';
import 'controllers/laundry_support_questions_controller.dart';
import 'controllers/pet_care_specialty_controller.dart';
import 'controllers/user_data_controller.dart';
import 'firebase_options.dart';
import 'live/utilities/generic_system_navigation.dart';
import 'live/view/address_view/controller/address_dropdown_controller.dart';
import 'live/view/auth_view/controller/phone_auth_view_controller.dart';
import 'live/view/cart_view/controller/cart_actions_controller.dart';
import 'live/view/home_view/category_view/controller/category_view_controller.dart';
import 'models/subscription_model.dart';

/// Initialize Firebase Messaging and setup notification handlers
Future<void> setupFirebaseMessaging() async {
  // Request permission for notifications
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Set foreground notification presentation options
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

/// Handle foreground messages
void handleForegroundMessage(RemoteMessage message) {
  print('Handling a foreground message: ${message.messageId}');

  // You can show a custom dialog or snackbar here for foreground notifications
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
  print('Handling a background message: ${message.messageId}');

  // You can process the background message here
  // For example, update local data, show local notification using system APIs, etc.

  // Note: Since we removed flutter_local_notifications, you might want to use
  // the system's native notification capabilities or handle data messages directly
  if (message.data.isNotEmpty) {
    print('Message data: ${message.data}');
  }
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
          'App opened from terminated state with message: ${message.messageId}');
      // Handle the message, e.g., navigate to specific screen
    }
  });

  // Handle when app is opened from background state
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('App opened from background with message: ${message.messageId}');
    // Handle the message, e.g., navigate to specific screen
  });

  await dep.init();
  NetworkInjection.init();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // navigation bar color
    statusBarColor: Colors.transparent, // status bar color
    statusBarBrightness: Brightness.light, //status bar brightness
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness:
        Brightness.light, //status barIcon Brightness
  ));

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

    return GetBuilder<PopularSpecialtyController>(builder: (_) {
      return GetBuilder<RecommendedSpecialtyController>(builder: (_) {
        return GetBuilder<LaundrySpecialtyController>(builder: (_) {
          return GetBuilder<CarSpecialtyController>(builder: (_) {
            return GetBuilder<SubscriptionPlansController>(builder: (_) {
              return GetBuilder<TabsHeaderController>(builder: (_) {
                return GetBuilder<LaundrySupportQuestionsController>(
                    builder: (_) {
                  return GetBuilder<HomeItemsController>(builder: (_) {
                    return GetBuilder<CarWashController>(builder: (_) {
                      return GetBuilder<CarWashSupportQuestionsController>(
                          builder: (_) {
                        return GetBuilder<NewCartController>(builder: (_) {
                          return GetBuilder<PhoneAuthMethods>(builder: (_) {
                            return StreamProvider<UserModel?>.value(
                                value: FirebaseAuthMethods().user,
                                initialData: UserModel(uid: ''),
                                builder: (context, snapshot) {
                                  return MultiProvider(
                                    providers: [
                                      StreamProvider<UserModel?>.value(
                                        value: FirebaseAuthMethods().user,
                                        initialData: UserModel(uid: ''),
                                      ),
                                      ChangeNotifierProvider<
                                          PhoneAuthViewController>(
                                        create: (_) =>
                                            PhoneAuthViewController(),
                                      ),
                                      ChangeNotifierProvider<
                                          ProfileViewController>(
                                        create: (_) => ProfileViewController(),
                                      ),
                                      ChangeNotifierProvider<
                                          MainAddressViewController>(
                                        create: (_) =>
                                            MainAddressViewController(),
                                      ),
                                      ChangeNotifierProvider<
                                          CategoryViewController>(
                                        create: (_) => CategoryViewController(),
                                      ),
                                      ChangeNotifierProvider<
                                          RiderTipController>(
                                        create: (_) => RiderTipController(),
                                      ),
                                      ChangeNotifierProvider<
                                          CheckoutViewController>(
                                        create: (_) => CheckoutViewController(),
                                      ),
                                      ChangeNotifierProvider<
                                          CartViewController>(
                                        create: (_) => CartViewController(),
                                      ),
                                      ChangeNotifierProvider<
                                          CartRecommendedItemsController>(
                                        create: (_) =>
                                            CartRecommendedItemsController(),
                                      ),
                                      ChangeNotifierProvider<
                                          CheckoutController>(
                                        create: (_) => CheckoutController(),
                                      ),
                                      ChangeNotifierProvider<
                                          UserDataController>(
                                        create: (_) => UserDataController(),
                                      ),
                                      ChangeNotifierProvider<
                                          HomeViewController>(
                                        create: (_) => HomeViewController(),
                                      ),
                                      ChangeNotifierProvider<
                                          CartRecommendedItemsController>(
                                        create: (_) =>
                                            CartRecommendedItemsController(),
                                      ),
                                      ChangeNotifierProvider<
                                          CartActionsController>(
                                        create: (_) => CartActionsController(),
                                      ),
                                      ChangeNotifierProvider<
                                          UserSettingsController>(
                                        create: (_) => UserSettingsController(),
                                      ),
                                      ChangeNotifierProvider<
                                          OrderHistoryController>(
                                        create: (_) => OrderHistoryController(),
                                      )
                                    ],
                                    child: GetMaterialApp(
                                      debugShowCheckedModeBanner: false,
                                      title: 'Izinto',
                                      home: Wrapper(),
                                      theme: ThemeData(
                                        colorScheme: ColorScheme.fromSeed(
                                          seedColor: Colors
                                              .white, // base for a white theme
                                          // Your primary color
                                          brightness: Brightness.light,
                                        ),
                                      ),
                                      getPages: RouteHelper.routes,
                                    ),
                                  );
                                });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  }
}
