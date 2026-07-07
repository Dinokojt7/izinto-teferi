import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:izinto/live/view/home_view/car_wash_view/car_wash_view.dart';
import 'package:izinto/live/view/home_view/category_view/view_widgets/try_this_service_widget.dart';
import 'package:izinto/live/view/designated_driver/dd_request_view.dart';
import 'package:izinto/live/view/gas_delivery/gas_delivery_view.dart';
import 'package:izinto/live/view/laundry_services/laundry_home_view.dart';
import 'package:izinto/live/view/pet_grooming/pet_grooming_view.dart';
import 'package:izinto/live/widgets/photo_tile.dart';
import 'package:provider/provider.dart';
import '../../../controllers/home_items_controller.dart';
import '../../../utils/dimensions.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../../widgets/text_widgets/primary_style_text.dart';
import '../home_view/controller/home_view_controller.dart';
import '../home_view/main_address_view.dart';
import '../home_view/referral_rewards_view.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.black, Brightness.light, Colors.black, Brightness.light);
    });
  }

  void _onRefresh() async {
    try {
      await Get.find<HomeItemsController>()
          .getHomeItemsList(forceRefresh: true);
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void _push(BuildContext context, Widget page) {
    Provider.of<HomeViewController>(context, listen: false)
        .navigateToNestedWidget(context, page);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeItemsController>(builder: (homeItems) {
      final _profileController = Provider.of<ProfileViewController>(context);
      final String _firstName = _profileController.firstName;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: SafeArea(
          top: false,
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
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Dimensions.height15),
                  _buildGreeting(_firstName),
                  SizedBox(height: Dimensions.height15),
                  MainAddressView(),
                  SizedBox(height: Dimensions.height20),
                  _buildServiceMosaic(context),
                  SizedBox(height: Dimensions.height30),
                  _buildHeading('Popular', 'Services'),
                  _buildServicesGrid(homeItems),
                  TryThisServiceWidget(),
                  SizedBox(height: Dimensions.height30),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGreeting(String firstName) => Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: HeadingStyleText(
          text: firstName.isNotEmpty ? 'Hey, $firstName.' : 'Hey, welcome.',
          size: Dimensions.font26,
          weight: FontWeight.w600,
        ),
      );

  /// The 5 primary services, front and center — replaces the old plain
  /// dynamic grid as the main entry point into the app's core flows.
  Widget _buildServiceMosaic(BuildContext context) {
    final tileHeight = Dimensions.screenHeight / 9;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: Column(
        children: [
          SizedBox(
            height: tileHeight * 1.7,
            width: double.infinity,
            child: PhotoTile(
              image: 'assets/image/laundry-page.png',
              title: 'Laundry',
              subtitle: 'Pay by the bag — pickup & delivery',
              badge: '50% OFF FIRST BAG',
              titleSize: 18,
              onTap: () => _push(context, const LaundryHomeView()),
            ),
          ),
          SizedBox(height: Dimensions.height10),
          SizedBox(
            height: tileHeight,
            child: Row(
              children: [
                Expanded(
                  child: PhotoTile(
                    image: 'assets/image/car-wash-background.png',
                    title: 'Car Wash',
                    subtitle: 'At your location',
                    onTap: () => _push(context, const CarWashView()),
                  ),
                ),
                SizedBox(width: Dimensions.width10),
                Expanded(
                  child: PhotoTile(
                    image: 'assets/image/gas.jpg',
                    title: 'Gas Delivery',
                    subtitle: 'LPG refills',
                    onTap: () => _push(context, const GasDeliveryView()),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Dimensions.height10),
          SizedBox(
            height: tileHeight,
            child: Row(
              children: [
                Expanded(
                  child: PhotoTile(
                    image: 'assets/image/pet-care.png',
                    title: 'Pet Grooming',
                    subtitle: 'Mobile & at-home',
                    onTap: () => _push(context, const PetGroomingView()),
                  ),
                ),
                SizedBox(width: Dimensions.width10),
                Expanded(
                  child: PhotoTile(
                    image: 'assets/image/driver.png',
                    title: 'Get You Home',
                    subtitle: 'You & your car, safely',
                    badge: 'NEW',
                    leftGradient: false,
                    onTap: () => _push(context, const DdRequestView()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String bold, String light) => Padding(
        padding: EdgeInsets.only(
          left: Dimensions.width20,
          bottom: Dimensions.height10,
        ),
        child: Row(
          children: [
            PrimaryStyleText(family: 'Poppins', text: bold, weight: FontWeight.w600),
            SizedBox(width: Dimensions.width10),
            PrimaryStyleText(family: 'Poppins', text: light, weight: FontWeight.w400, color: Colors.black54),
          ],
        ),
      );

  Widget _buildServicesGrid(HomeItemsController homeItemsController) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height10,
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
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

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
