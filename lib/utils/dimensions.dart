import 'package:get/get.dart';

class Dimensions {
  static double screenHeight = Get.context!.height;
  static double screenWidth = Get.context!.width;

  static double pageView = screenHeight / 2.64;
  static double pageViewContainer = screenHeight / 4.10;
  static double pageViewTextContainer = screenHeight / 7.73;
  //dynamic height padding and margin
  static double height10 = screenHeight / 84.4;
  static double height15 = screenHeight / 56.27;
  static double height18 = screenHeight / 45.4;
  static double height20 = screenHeight / 42.2;
  static double height45 = screenHeight / 18.76;

  static double height30 = screenHeight / 28.13;
  //dynamic width padding and margin
  static double width10 = screenHeight / 84.4;
  static double width15 = screenHeight / 56.27;
  static double width20 = screenHeight / 42.2;
  static double width30 = screenHeight / 28.13;

  //font size
  static double font16 = screenHeight / 48.75;
  static double font26 = screenHeight / 32.46;
  static double font20 = screenHeight / 42.2;

  //radius
  static double radius20 = screenHeight / 60.2;
  static double radius30 = screenHeight / 50.13;
  static double radius15 = screenHeight / 100.27;

  //icon size
  static double iconSize24 = screenHeight / 35.17;
  static double iconSize16 = screenHeight / 45.75;
  static double iconSize26 = screenHeight / 32.46;

  //list view size
  static double listViewImgSize = screenWidth / 3.83;
  static double listViewTextContSize = screenWidth / 3.9;

  //popular specialty
  static double popularSpecialtyImgSize = screenHeight / 2.41;

  //bottom height
  static double bottomHeightBar = screenHeight / 7.03;

  //splash screen
  static double splashImg = screenHeight / 12.05;
  // static double splashImg = screenHeight/3.38;
}
