import 'dart:core';
import 'package:get/get.dart';
import 'package:izinto/live/view/home_view/home_view.dart';

class RouteHelper {
  static const String homeView = '/homeView';

  static String getHomeView() => homeView;

  static List<GetPage> routes = [
    GetPage(
        name: homeView,
        page: () {
          return const HomeView();
        }),
  ];
}
