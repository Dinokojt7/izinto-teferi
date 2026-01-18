// lib/live/view/laundry_services/laundry_home_view.dart
import 'package:flutter/material.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../widgets/texts/small_text.dart';
import '../../widgets/text_widgets/heading_style_text.dart';

class LaundryHomeView extends StatefulWidget {
  const LaundryHomeView({Key? key}) : super(key: key);

  @override
  State<LaundryHomeView> createState() => _LaundryHomeViewState();
}

class _LaundryHomeViewState extends State<LaundryHomeView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late String _userName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final profileController =
        Provider.of<ProfileViewController>(context, listen: false);
    _userName = profileController?.firstName ?? 'Guest';
  }

  void _onRefresh() async {
    // Refresh logic here
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // Loading logic here
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {});
    }
    _refreshController.loadComplete();
  }

  void _navigateToHelp() {
    // TODO: Navigate to help screen
    print('Navigate to help');
  }

  void _navigateToBooking() {
    // TODO: Navigate to booking screen
    print('Navigate to booking');
  }

  void _navigateToHowItWorks() {
    // TODO: Navigate to how it works screen
    print('Navigate to how it works');
  }

  void _navigateToSaveItems() {
    // TODO: Navigate to save items screen
    print('Navigate to save items');
  }

  void _navigateToJoinMembership() {
    // TODO: Navigate to membership screen
    print('Navigate to membership');
  }

  Widget _buildTopRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallText(
                text: 'Hi,',
                size: Dimensions.font16 / 1.2,
                color: Colors.black,
              ),
              HeadingStyleText(
                text: '$_userName!',
                size: Dimensions.font20,
                weight: FontWeight.w600,
                color: Colors.black,
              ),
            ],
          ),

          // Help Button
          GestureDetector(
            onTap: _navigateToHelp,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius20),
                border: Border.all(
                  color: Colors.grey.shade700,
                  width: 1.5,
                ),
              ),
              child: Text(
                'Help',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksHeader() {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimensions.width20,
        right: Dimensions.width20,
        bottom: Dimensions.height15,
      ),
      child: Row(
        children: [
          Text(
            '🔄',
            style: TextStyle(fontSize: Dimensions.font20),
          ),
          SizedBox(width: Dimensions.width10),
          HeadingStyleText(
            text: 'How it works?',
            size: Dimensions.font16 * 1.1,
            weight: FontWeight.w600,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required String title,
    required String description,
    required String iconAsset,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with circular background
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: LiveColors.lavender,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                iconAsset,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.help_outline,
                    color: Colors.blue.shade700,
                    size: 24,
                  );
                },
              ),
            ),
          ),
          SizedBox(width: Dimensions.width15),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadingStyleText(
                  text: '$number. $title',
                  size: Dimensions.font16,
                  weight: FontWeight.w600,
                  color: Colors.black,
                ),
                SizedBox(height: Dimensions.height10 / 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.1,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Column(
      children: [
        _buildStepRow(
          number: '1',
          title: 'Select service',
          description:
              'No need to list each item. We\'ll weigh or count your items before cleaning.',
          iconAsset: 'assets/laundry/select_service.png',
        ),
        _buildStepRow(
          number: '2',
          title: 'Pack your items',
          description: 'Use one bag per service.',
          iconAsset: 'assets/laundry/pack_items.png',
        ),
        _buildStepRow(
          number: '3',
          title: 'Hand over the bags',
          description: 'Meet your driver or leave the bags at your door.',
          iconAsset: 'assets/laundry/hand_over.png',
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      child: GestureDetector(
        onTap: _navigateToBooking,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.height15,
          ),
          decoration: BoxDecoration(
            color: LiveColors.accent,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
          child: Center(
            child: Text(
              'BOOK FIRST ORDER',
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: Color(0xFF003366), // Dark blue color
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGettingStartedCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height10,
      ),
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadingStyleText(
                  text: 'Getting started?',
                  size: Dimensions.font16,
                  weight: FontWeight.w700,
                  color: Color(0xFF003366), // Dark blue
                ),
                SizedBox(height: Dimensions.height10 / 2),
                Text(
                  'See how EasyLaundry works and learn more about our services.',
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.1,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: Color(0xFF336699), // Medium blue
                    height: 1.4,
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                GestureDetector(
                  onTap: _navigateToHowItWorks,
                  child: Text(
                    'Start now',
                    style: TextStyle(
                      fontSize: Dimensions.font16 / 1.1,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Color(0xFF66abf9), // Light blue
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Icon
          Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.only(left: Dimensions.width15),
            decoration: BoxDecoration(
              color: Color(0xFF66abf9).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_fill_outlined,
                color: Color(0xFF66abf9),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveItemsCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height15,
      ),
      padding: EdgeInsets.only(
        left: Dimensions.width30 / 1.4,
        top: Dimensions.height20,
        bottom: Dimensions.height20,
        right: Dimensions.width10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text content
          Expanded(
            flex: 5,
            child: Container(
              margin: EdgeInsets.only(right: Dimensions.width30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadingStyleText(
                    text: 'Prepare and save on your frequent laundry items',
                    size: Dimensions.font16,
                    weight: FontWeight.w700,
                    color: Color(0xFF003366), // Dark blue
                    maxLines: 2,
                  ),
                  SizedBox(height: Dimensions.height15),
                  GestureDetector(
                    onTap: _navigateToSaveItems,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.height10,
                        horizontal: Dimensions.width15,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF003366), // Dark blue
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
                      ),
                      child: Center(
                        child: Text(
                          'Save now',
                          style: TextStyle(
                            fontSize: Dimensions.font16 / 1.1,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image/Icon
          Expanded(
            flex: 4,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/laundry/save_items.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height15,
      ),
      padding: EdgeInsets.only(
        left: Dimensions.width30 / 1.4,
        top: Dimensions.height20,
        bottom: Dimensions.height20,
        right: Dimensions.width10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text content
          Expanded(
            flex: 5,
            child: Container(
              margin: EdgeInsets.only(right: Dimensions.width30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadingStyleText(
                    text: 'Easy Laundry Member',
                    size: Dimensions.font16,
                    weight: FontWeight.w700,
                    color: Color(0xFF003366), // Dark blue
                  ),
                  SizedBox(height: Dimensions.height10 / 2),
                  Text(
                    'Skip the service fee for just R49 / month',
                    style: TextStyle(
                      fontSize: Dimensions.font16 / 1.1,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: Color(0xFF003366), // Dark blue
                    ),
                  ),
                  SizedBox(height: Dimensions.height15),
                  GestureDetector(
                    onTap: _navigateToJoinMembership,
                    child: Text(
                      'Join now',
                      style: TextStyle(
                        fontSize: Dimensions.font16 / 1.1,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: Color(0xFF66abf9), // Light blue
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image/Icon
          Expanded(
            flex: 4,
            child: Container(
              height: 100,
              padding: EdgeInsets.only(left: Dimensions.width10),
              child: Image.asset(
                'assets/laundry/membership.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: ClassicHeader(
          height: 80,
          refreshingText: 'Refreshing...',
          completeText: 'Refresh complete',
          failedText: 'Failed to refresh',
          idleText: 'Pull down to refresh',
          releaseText: 'Release to refresh',
          textStyle: TextStyle(
            fontSize: Dimensions.font16 / 1.1,
            color: Colors.grey.shade700,
          ),
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(),
              SizedBox(height: Dimensions.height10),
              _buildHowItWorksHeader(),
              SizedBox(height: Dimensions.height10 / 2),
              _buildStepsSection(),
              SizedBox(height: Dimensions.height20),
              _buildBookButton(),
              SizedBox(height: Dimensions.height10),
              _buildGettingStartedCard(),
              _buildSaveItemsCard(),
              _buildMembershipCard(),
              SizedBox(height: Dimensions.height30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
