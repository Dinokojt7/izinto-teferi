import 'package:flutter/material.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/view/user_settings_view/controller/user_settings_controller.dart';
import 'package:izinto/live/view/user_settings_view/main_app_settings.dart';
import 'package:izinto/models/user.dart';
import 'package:provider/provider.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../utilities/colors.dart';

import '../../widgets/home_button.dart';
import '../../../utils/colors.dart';
import '../../utilities/live_dimensions.dart';
import '../../widgets/no_user_page.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import 'customer_service_view.dart';

class UserSettingsView extends StatefulWidget {
  const UserSettingsView({Key? key}) : super(key: key);

  @override
  State<UserSettingsView> createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.addListener(() {
        Provider.of<UserSettingsController>(context, listen: false)
            .getActiveTab(_tabController.index);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewController>(
      builder: (context, _profileController, child) {
        try {
          final user = Provider.of<UserModel?>(context);
          if (user == null) {
            return NoUserPage(
              title: 'Settings',
              message: 'Please sign in to get started.',
              isSettingView: true,
            );
          } else {
            return NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverPersistentHeader(
                    delegate: CustomSliverAppBarDelegate(
                      expandedHeight: 190,
                      tabController: _tabController,
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: Container(
                color: Colors.white.withOpacity(0.975),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          CustomerServiceView(
                              promoCode: _profileController.promoCode),
                          // Additional widgets can go here if necessary
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          MainAppSettings(),
                          // Additional widgets can go here if necessary
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        } catch (e) {
          return Center();
        }
      },
    );
  }
}

class CustomSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final TabController tabController;

  CustomSliverAppBarDelegate({
    required this.expandedHeight,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context, shrinkOffset, bool overlapsContent) {
    final size = 60;
    final top = expandedHeight - shrinkOffset - size / 2;
    List<Widget> _tabs = [
      Tab(
        child: HomeButton(
          title: 'Orders',
          activeScreen: 0,
        ),
      ),
      Tab(
        child: HomeButton(
          title: 'Settings',
          activeScreen: 1,
        ),
      ),
    ];
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        buildBackground(shrinkOffset),
        Positioned.fill(
          child: buildAppBar(shrinkOffset), // AppBar on top of the background
        ),
        Positioned(
          top: top,
          left: 80.0,
          right: 80.0,
          child: buildFloatingTabBar(shrinkOffset, _tabs),
        )
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 30;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;
  double walletOpacity(double shrinkOffset) =>
      1 - shrinkOffset / (expandedHeight - 150);

  Widget buildAppBar(double shrinkOffset) {
    double opacity = appear(shrinkOffset).clamp(0.0, 1.0);

    return Consumer<ProfileViewController>(
      builder: (context, _profileController, child) {
        return AppBar(
          backgroundColor: Colors.black.withOpacity(opacity),
          toolbarHeight: 200,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo that disappears when scrolling up
              Opacity(
                opacity: disappear(shrinkOffset).clamp(0.0, 1.0),
                child: Image.asset(
                  'assets/logos/logomark.png',
                  height: 25.0,
                ),
              ),

              // Space above ProfileMallana that ONLY appears when shrunk
              Opacity(
                opacity: appear(shrinkOffset).clamp(0.0, 1.0),
                child: SizedBox(height: Dimensions.height20),
              ),

              // ProfileMallana - always centered
              Center(
                child: _profileController.firstName == ''
                    ? ProfileMallana(text1: 'Hello', text2: 'Welcome')
                    : ProfileMallana(
                        text1: '${_profileController.firstName}',
                        text2: '${_profileController.lastName}'),
              ),

              // Wallet balance that appears when shrunk
              Opacity(
                opacity: walletOpacity(shrinkOffset).clamp(0.0, 1.0),
                child: Column(
                  children: [
                    SizedBox(height: 5.0),
                    HeadingStyleText(
                      text: _profileController.walletBalance > 0
                          ? 'Wallet: R${_profileController.walletBalance},00'
                          : 'Wallet: R0,00',
                      size: Dimensions.font20 / 1.3,
                      family: 'Poppins',
                      color: Colors.white,
                      weight: FontWeight.w300,
                      align: TextAlign.center,
                    ),
                    SizedBox(height: Dimensions.height30),
                  ],
                ),
              ),
            ],
          ),
          centerTitle: true,
        );
      },
    );
  }

  Widget buildBackground(double shrinkOffset) => Opacity(
        opacity: disappear(shrinkOffset).clamp(0.0, 1.0),
        child: Container(
          height: expandedHeight * 1.5,
          child: Image.asset(
            'assets/image/wallpaper.png',
            width: double.maxFinite,
            fit: BoxFit.cover,
          ),
        ),
      );

  Widget buildFloatingTabBar(double shrinkOffset, List<Widget> tabs) => Opacity(
        opacity: disappear(shrinkOffset),
        child: Container(
          height: Dimensions.height45 * 1.5,
          width: Dimensions.screenWidth / 2.2,
          child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(LiveDimensions.radius30 * 2),
              ),
              child: TabsSection(
                isSpecialtiesLoaded: true,
                tabController: tabController,
                tabs: tabs,
              )),
        ),
      );
}

class TabsSection extends StatelessWidget {
  const TabsSection({
    super.key,
    required bool isSpecialtiesLoaded,
    required TabController tabController,
    required List<Widget> tabs,
  })  : _tabController = tabController,
        _tabs = tabs,
        isSpecialtiesLoaded = isSpecialtiesLoaded;

  final TabController _tabController;
  final List<Widget> _tabs;
  final bool? isSpecialtiesLoaded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LiveDimensions.radius30 * 2),
      ),
      child: TabBar(
        dividerHeight: 0,
        labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
        physics: AlwaysScrollableScrollPhysics(),
        indicatorColor: Colors.transparent,
        controller: _tabController,
        tabs: _tabs,
        labelColor: AppColors.fontColor,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }
}

class ProfileMallana extends StatelessWidget {
  final String text1;
  final String text2;
  final double? size;
  final bool isSettingsView;

  const ProfileMallana({
    Key? key,
    required this.text1,
    required this.text2,
    this.size,
    this.isSettingsView = false,
  }) : super(key: key);

  // Safe text getters with defaults
  String get _safeText1 => text1.trim();
  String get _safeText2 => text2.trim();

  // Calculate the total character count safely
  int get _totalCharacters => _safeText1.length + _safeText2.length;

  // Check if we have any content
  bool get _hasContent => _safeText1.isNotEmpty || _safeText2.isNotEmpty;

  // More aggressive scaling based on character count
  double get _dynamicFontSize {
    final baseSize = size ?? Dimensions.height20 * 2.2;
    final totalChars = _totalCharacters;

    if (totalChars <= 12) {
      return baseSize; // Normal size for short names
    } else if (totalChars <= 20) {
      return baseSize * 0.8; // Reduce for medium names
    } else if (totalChars <= 30) {
      return baseSize * 0.6; // Further reduce for long names
    } else {
      return baseSize * 0.4; // Minimum for very long names
    }
  }

  // More aggressive min font size
  double get _minFontSize {
    final totalChars = _totalCharacters;

    if (totalChars <= 12) {
      return 18.0;
    } else if (totalChars <= 20) {
      return 14.0;
    } else if (totalChars <= 30) {
      return 10.0;
    } else {
      return 8.0;
    }
  }

  // Calculate max width based on screen size
  double get _maxWidth {
    // Use 80% of screen width as maximum constraint
    return Dimensions.screenWidth * 0.8;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) {
      return _buildPlaceholder();
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: _maxWidth, // Constrain the maximum width
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Use minimum width needed
        children: [
          // First Text Part - Flexible to prevent overflow
          Flexible(
            child: _buildAutoSizeText(
              text: _safeText1.toUpperCase(),
              color: Colors.white,
            ),
          ),

          SizedBox(width: Dimensions.width10 * 1.5),

          // Second Text Part - Flexible to prevent overflow
          Flexible(
            child: _buildAutoSizeText(
              text: _safeText2.toUpperCase(),
              color: LiveColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoSizeText({
    required String text,
    required Color color,
  }) {
    return AutoSizeText(
      text,
      maxLines: 1,
      minFontSize: _minFontSize,
      overflow: TextOverflow.ellipsis, // Use ellipsis if still too long
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: _dynamicFontSize,
        fontFamily: 'Cabin',
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: _maxWidth,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _buildStaticText(
              text: 'Hello',
              color: Colors.white,
            ),
          ),
          SizedBox(width: Dimensions.width10 * 1.5),
          Flexible(
            child: _buildStaticText(
              text: 'Welcome',
              color: LiveColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticText({
    required String text,
    required Color color,
  }) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size ?? Dimensions.height20 * 2.2,
        fontFamily: 'Cabin',
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
