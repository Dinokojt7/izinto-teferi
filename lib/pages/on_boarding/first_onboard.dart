import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../utils/colors.dart';
import '../../utils/on_board_image_strings.dart';
import '../../utils/on_board_text.dart';
import '../../widgets/texts/integers_and_doubles.dart';
import '../auth/get_started.dart';
import '../home/home_page.dart';

class FirstOnBoard extends StatelessWidget {
  const FirstOnBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      OnboardPage(
        color: AppColors.screen1,
        logo: 'assets/image/white_logo.png',
        backgroundImage: OnBoardImages.screen1,
        text: OnBoardText.screen1,
        index: 1.0,
      ),
      OnboardPage(
        color: AppColors.screen2,
        logo: 'assets/image/white_logo.png',
        backgroundImage: OnBoardImages.screen2,
        text: OnBoardText.screen2,
        index: 2.0,
      ),
      OnboardPage(
        color: AppColors.screen3,
        logo: 'assets/image/white_logo.png',
        backgroundImage: OnBoardImages.screen3,
        text: OnBoardText.screen3,
        index: 3.0,
      ),
    ];
    final controller = LiquidController();
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            liquidController: controller,
            pages: screens,
            slideIconWidget: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            enableSideReveal: true,
          ),
        ],
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final Color color;
  final String logo;
  final String text;
  final String backgroundImage;
  final double index;
  const OnboardPage({
    super.key,
    required this.color,
    required this.logo,
    required this.backgroundImage,
    required this.text,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: Dimensions.screenHeight,
          width: Dimensions.screenWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/image/sneaker_shop.jpg'),
            ),
          ),
        ),
        Column(
          children: [
            Spacer(),
            Container(
              height: Dimensions.screenHeight / 1.6,
              width: Dimensions.screenWidth,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radius30 * 20),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: Dimensions.height45 * 3,
                  ),
                  Image(
                    image: AssetImage(logo),
                    color: Colors.white,
                    width: Dimensions.width30 * 2.5,
                  ),
                  SizedBox(
                    height: Dimensions.height15,
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: Dimensions.font16,
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.height20,
                  ),
                  OnBoardSignIn(),
                  SizedBox(
                    height: Dimensions.height15,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    child: IntegerText(
                      text: 'Later',
                      size: Dimensions.font16 * 1.2,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  // DotsIndicator(
                  //   dotsCount: 3,
                  //   position: index,
                  //   decorator: DotsDecorator(
                  //     activeColor: Colors.white,
                  //     color: Colors.grey[300]!,
                  //     size: const Size.square(6.5),
                  //     activeSize: const Size(16, 8),
                  //     activeShape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(5)),
                  //   ),
                  // ),
                  Spacer()
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class OnBoardSignIn extends StatelessWidget {
  const OnBoardSignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Get.to(
            () => const GetStarted(
                  pageId: 'splash',
                ),
            transition: Transition.fade,
            duration: Duration(seconds: 1));
      },
      child: Container(
        height: Dimensions.screenHeight / 17,
        width: Dimensions.width30 * 12,
        // width: Dimensions.screenWidth / 2.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.white, Colors.white],
          ),
          border: Border.all(
            width: 1,
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(Dimensions.radius20 * 3),
          ),
        ),

        child: Center(
          child: IntegerText(
            text: 'Customer sign in',
            size: Dimensions.font16 / 1.1,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
