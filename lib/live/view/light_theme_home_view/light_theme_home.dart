import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/try_this_service_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../../controllers/home_items_controller.dart';
import '../../../controllers/laundry_specialty_controller.dart';
import '../../../controllers/gas_refill_specialty_controller.dart';
import '../../../controllers/carpet_care_specialty_controller.dart';
import '../../../controllers/pet_care_specialty_controller.dart';
import '../../../models/popular_specialty_model.dart';
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
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    // Apply system chrome settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.black, Brightness.light, Colors.black, Brightness.light);
    });
  }

  void _onRefresh() async {
    try {
      // Reload only the home items controller (popular services)
      await Get.find<HomeItemsController>()
          .getHomeItemsList(forceRefresh: true);

      _refreshController.refreshCompleted();

      // Show success feedback
      Get.snackbar(
        'Refreshed',
        'Services updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      print('Refresh error: $e');
      _refreshController.refreshFailed();

      // Show error feedback
      Get.snackbar(
        'Refresh Failed',
        'Please check your connection and try again',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeItemsController>(builder: (homeItems) {
      final _profileController = Provider.of<ProfileViewController>(context);
      final List<dynamic> _addresses = _profileController.savedAddresses;
      final String _firstName = _profileController.firstName;

      var selectedAddresses =
          _addresses.where((address) => address['selected'] == true).toList();
      var street = '';
      var suburb = '';

      for (var address in selectedAddresses) {
        street = address['street'];
        suburb = address['suburb'];
      }

      return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.985),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: Column(
          children: [
            // Top section (fixed - no pull to refresh)
            _buildHeroSection(_firstName, street, suburb),
            SizedBox(height: Dimensions.height15),

            // Popular Services section with pull-to-refresh
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                enablePullDown: true,
                enablePullUp: false,
                header: ClassicHeader(
                  height: 60,
                  completeIcon: Icon(Icons.check, color: Colors.green),
                  failedIcon: Icon(Icons.error, color: Colors.red),
                  idleIcon: Icon(Icons.arrow_downward, color: Colors.grey),
                  releaseIcon: Icon(Icons.refresh, color: Colors.black),
                  textStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: Dimensions.font16 / 1.1,
                    fontFamily: 'Poppins',
                  ),
                  refreshingText: 'Refreshing services...',
                  completeText: 'Services updated',
                  failedText: 'Refresh failed',
                  idleText: 'Pull down to refresh services',
                  releaseText: 'Release to refresh',
                ),
                child: SingleChildScrollView(
                  physics:
                      AlwaysScrollableScrollPhysics(), // Important for nested scrolling
                  child: Column(
                    children: [
                      _buildHeading(),
                      _buildServicesGrid(homeItems),
                      SizedBox(height: Dimensions.height30),
                      _buildPromoBanner(),
                      SizedBox(height: Dimensions.height30),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
          Positioned(
            top: -expandedHeight * 0.02,
            bottom: -expandedHeight * 0.02,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: 1.00,
              child: Image.asset(
                'assets/image/wallpaper.png',
                width: double.maxFinite,
                fit: BoxFit.cover,
              ),
            ),
          ),
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
          Positioned(
            top: expandedHeight - size * 1.1,
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildWelcomeText(firstName),
          SizedBox(height: Dimensions.height30),
          MainAddressView(),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(String firstName) => Padding(
        padding: EdgeInsets.only(
            left: Dimensions.width10,
            right: Dimensions.width10 / 2,
            top: Dimensions.height45 * 1.5),
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
        padding: EdgeInsets.only(
          left: Dimensions.width20,
          top: Dimensions.height10, // Add some top padding
        ),
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height10, // Add vertical padding
      ),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: Dimensions.width10 / 5,
          mainAxisSpacing: Dimensions.height10,
          childAspectRatio: 0.9,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return SpecialtyWidget(
            index: index,
            homeItemList: homeItemsController.homeItemsList,
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return TryThisServiceWidget();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
