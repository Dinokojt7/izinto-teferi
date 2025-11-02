import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/try_this_service_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../../controllers/home_items_controller.dart';
import '../../../models/popular_specialty_model.dart'; // ADD THIS IMPORT
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/big_text.dart';
import '../../../widgets/texts/small_text.dart';
import '../../utilities/colors.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/text_widgets/big_mallanna.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../../widgets/text_widgets/primary_style_text.dart';
import '../auth_view/view_widgets/top_logo.dart';
import '../home_view/main_address_view.dart';
import '../home_view/specialty_widget.dart';
import '../profile_view/controller/profile_view_controller.dart';

class LightThemeHome extends StatefulWidget {
  const LightThemeHome({Key? key}) : super(key: key);

  @override
  State<LightThemeHome> createState() => _LightThemeHomeState();
}

class _LightThemeHomeState extends State<LightThemeHome> {
  @override
  void initState() {
    super.initState();
    // Apply system chrome settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.white, Brightness.dark, Colors.white, Brightness.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeItemsController>(builder: (homeItems) {
      ///Here's a list of addresses from the controller
      final _profileController =
          Provider.of<ProfileViewController>(context, listen: false);
      final List<dynamic> _addresses = _profileController.savedAddresses;
      final String _firstName = _profileController.firstName;

      ///Here's the selection of currently active address///
      var selectedAddresses =
          _addresses.where((address) => address['selected'] == true).toList();

      var street = '';
      var suburb = '';
      // Iterate over the filtered addresses and use their values
      for (var address in selectedAddresses) {
        street = address['street'];
        suburb = address['suburb'];
      }
      return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.985),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section - slightly less height
              _buildHeroSection(_firstName, street, suburb),
              SizedBox(height: Dimensions.height15),

              // Services heading
              _buildHeading(),
              // Services Grid - FIXED: Use homeItemsList instead of homeItemsRepoList
              _buildServicesGrid(homeItems),
              SizedBox(height: Dimensions.height30),

              // Promo Banner
              _buildPromoBanner(),
              SizedBox(height: Dimensions.height30),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeroSection(firstName, street, suburb) {
    final expandedHeight = Dimensions.screenHeight / 3.8;
    final size = Dimensions.screenHeight / 4;

    return Container(
      width: double.maxFinite,
      height: expandedHeight,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          // 🔹 Background with minimal zoom
          Positioned(
            top: -expandedHeight * 0.02,
            bottom: -expandedHeight * 0.02,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: 1.00, // Even more zoomed out
              child: Image.asset(
                'assets/image/wallpaper.png',
                width: double.maxFinite,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Optional soft gradient fade
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.2, 1.0],
                ),
              ),
            ),
          ),

          // 🔹 Content positioned higher up with less space below
          Positioned(
            top: expandedHeight - size * 1.1, // Positioned higher up
            left: Dimensions.width10 * 1.5,
            right: Dimensions.width10 * 1.5,
            child: _buildHeroContent(firstName),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent(String firstName) {
    return Container(
      width: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Start from top
        children: [
          _buildWelcomeText(firstName),
          SizedBox(height: Dimensions.height30), // Much less space below
          // Address widget positioned closer to welcome text
          MainAddressView(),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(String firstName) => Padding(
        padding: EdgeInsets.only(
            left: Dimensions.width10,
            right: Dimensions.width10 / 2,
            top: Dimensions.height45 * 1.5), // Even more top margin
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: BigMallanna(
                    text1: 'HEY,',
                    text2: firstName != '' ? '$firstName!' : 'Welcome',
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildHeading() => Padding(
        padding: EdgeInsets.only(left: Dimensions.width20),
        child: Row(
          children: [
            PrimaryStyleText(
              family: 'Poppins',
              text: 'Popular',
              weight: FontWeight.w600,
            ),
            SizedBox(width: Dimensions.width10),
            Container(
              margin: const EdgeInsets.only(bottom: 3),
              child: BigText(
                text: '.',
                color: Colors.black26,
                weight: FontWeight.w700,
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Container(
              margin: const EdgeInsets.only(bottom: 1),
              child: SmallText(
                family: 'Poppins',
                text: 'Services',
                maxLines: 1,
              ),
            )
          ],
        ),
      );

  Widget _buildServicesGrid(HomeItemsController homeItemsController) {
    // FIXED: Accept controller
    final itemCount = homeItemsController.homeItemsList.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: Dimensions.width10 / 8,
          mainAxisSpacing: Dimensions.height10 / 5,
          childAspectRatio: 0.9,
        ),
        itemCount: itemCount > 6 ? 6 : itemCount, // Use actual count with max 6
        itemBuilder: (context, index) {
          return SpecialtyWidget(
            index: index,
            homeItemList:
                homeItemsController.homeItemsList, // FIXED: Use homeItemsList
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return TryThisServiceWidget();
  }
}
