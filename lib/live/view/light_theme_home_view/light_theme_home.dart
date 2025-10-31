import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../controllers/home_items_controller.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/big_text.dart';
import '../../../widgets/texts/small_text.dart';
import '../../utilities/colors.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../auth_view/view_widgets/top_logo.dart';
import '../home_view/controller/home_view_controller.dart';
import '../home_view/specialty_widget.dart';
// Add other necessary imports for your custom widgets

class LightThemeHome extends StatefulWidget {
  const LightThemeHome({Key? key}) : super(key: key);

  @override
  State<LightThemeHome> createState() => _LightThemeHomeState();
}

class _LightThemeHomeState extends State<LightThemeHome> {
  final List<String> rotatingTexts = [
    "Laundry",
    "Car Wash",
    "Gas Refill",
    "Carpet Care"
  ];
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    // Apply system chrome settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.white, Brightness.dark, Colors.white, Brightness.dark);
    });

    // Start text animation
    _startTextAnimation();
  }

  void _startTextAnimation() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % rotatingTexts.length;
        });
        _startTextAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeItemsController>(builder: (homeItems) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              _buildHeroSection(),
              SizedBox(height: Dimensions.height20),

              // Services Grid
              _buildServicesGrid(homeItems.homeItemsRepoList),
              SizedBox(height: Dimensions.height20),

              // Promo Banner
              _buildPromoBanner(),
              SizedBox(height: Dimensions.height20),
            ],
          ),
        ),
      );
    });
  }

  PreferredSizeWidget? _buildAppBar() {
    // Try to build the full app bar, if it doesn't fit we'll return null and build the row in body
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: TopLogo(), // Your existing TopLogo widget
      actions: [
        Padding(
          padding: EdgeInsets.only(right: Dimensions.width20),
          child: Row(
            children: [
              Icon(
                size: Dimensions.iconSize24 / 1.1,
                Icons.location_on_rounded,
                color: LiveColors.accent.withOpacity(0.7),
              ),
              SizedBox(width: Dimensions.width20 / 4),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadingStyleText(
                    text: "Street Name", // Replace with actual street variable
                    size: Dimensions.font20 / 1.5,
                    family: 'Poppins',
                    weight: FontWeight.w600,
                  ),
                  HeadingStyleText(
                    text: "Suburb", // Replace with actual suburb variable
                    size: Dimensions.font20 / 1.8,
                    family: 'Poppins',
                    weight: FontWeight.w300,
                    color: Colors.black54,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.maxFinite,
      height: Dimensions.screenHeight / 5,
      child: Stack(
        children: [
          Image.asset(
            'assets/image/wallpaper.png',
            width: double.maxFinite,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BigText(
                    text: "Discover & book local",
                    color: Colors.white,
                    size: Dimensions.font20,
                    weight: FontWeight.w500,
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: BigText(
                      key: ValueKey(_currentTextIndex),
                      text: "professional ${rotatingTexts[_currentTextIndex]}",
                      color: Colors.white,
                      size: Dimensions.font20,
                      weight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(homeItems) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: Dimensions.width10,
          mainAxisSpacing: Dimensions.height10,
          childAspectRatio: 0.9,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return SpecialtyWidget(
            index: index,
            homeItemList: homeItems,
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: Container(
        width: Dimensions.screenWidth,
        height: Dimensions.screenHeight / 4.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          color: LiveColors.accent.withOpacity(0.2),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/image/car-wash-background.png'),
          ),
        ),
        child: Stack(
          children: [
            // Left side content
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BigText(
                    text: "Professional Car Wash",
                    color: Colors.white,
                    size: Dimensions.font20,
                    weight: FontWeight.bold,
                  ),
                  SizedBox(height: Dimensions.height10),
                  SmallText(
                    text:
                        "Get your car sparkling clean with our premium service",
                    color: Colors.white,
                    size: Dimensions.font16,
                  ),
                  SizedBox(height: Dimensions.height20),
                  Container(
                    height: Dimensions.height45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15 * 1.3),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Book Now",
                        style: TextStyle(
                          color: LiveColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right side image
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                'assets/image/car-wash-side.png', // You'll need this asset
                height: Dimensions.screenHeight / 6,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
