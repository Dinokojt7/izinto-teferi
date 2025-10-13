import 'package:flutter/material.dart';
import 'package:izinto/live/view/inbox_view/inbox_view.dart';
import 'package:provider/provider.dart';

import '../../../../models/user.dart';
import '../../../../utils/colors.dart';
import '../../../auxiliery_classes/live_progress_indicator.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../cart_view/cart_view_page.dart';
import '../../checkout_view/checkout_page.dart';
import '../../order_history_view/order_history_view.dart';
import '../../profile_view/profile_view.dart';
import '../../user_settings_view/opening_hours.dart';
import '../../user_settings_view/user_settings_view.dart';
import '../controller/home_view_controller.dart';
import '../sliver_home_page.dart';
import 'basket_navigation_item.dart';
import 'bottom_icon_body.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({
    Key? key,
  }) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  /// Use GlobalKeys for each navigator to handle nested navigation
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onBottomNavTapped(int index) {
    final homeController =
        Provider.of<HomeViewController>(listen: false, context);
    homeController.onTapNav(index);
  }

  /// Main pages for BottomNavigationBar
  List<Widget> _pages(BuildContext context, bool hasUser) {
    if (hasUser) {
      return [
        _buildNavigator(context, _navigatorKeys[0], SliverHomePage()),
        _buildNavigator(context, _navigatorKeys[1], OrderHistoryView()),
        _buildNavigator(context, _navigatorKeys[2], CartViewPage()),
        _buildNavigator(context, _navigatorKeys[3], InboxView()),
        _buildNavigator(context, _navigatorKeys[4], UserSettingsView()),
      ];
    } else {
      return [
        _buildNavigator(context, _navigatorKeys[0], SliverHomePage()),
        OrderHistoryView(),
        _buildNavigator(context, _navigatorKeys[2], CartViewPage()),
        InboxView(),
        UserSettingsView(),
      ];
    }
  }

  /// This method returns a Navigator for each page in the BottomNavigationBar
  Widget _buildNavigator(
      BuildContext context, GlobalKey<NavigatorState> key, Widget child) {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);

    return Navigator(
      key: key,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => child,
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    final homeController =
        Provider.of<HomeViewController>(listen: false, context);
    final isFirstRouteInCurrentTab =
        !await _navigatorKeys[homeController.currentIndex]
            .currentState!
            .maybePop();
    if (isFirstRouteInCurrentTab) {
      // If there's no route to pop, let the system handle back button (maybe exit the app)
      return true;
    }
    // If current tab has routes, pop the route.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final _hasUser = user != null;
    return Consumer<HomeViewController>(builder: (context, _controller, child) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.transparent,
              body: IndexedStack(
                index: _controller.currentIndex,
                children: _pages(context, _hasUser),
              ),
              bottomNavigationBar: BottomAppBar(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: BottomNavigationBar(
                    unselectedFontSize: 11,
                    selectedFontSize: 11,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: LiveColors.primary,
                    // unselectedItemColor: LiveColors.primary,
                    //D0C9C0
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    selectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.six,
                    ),
                    unselectedLabelStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                    currentIndex: _controller.currentIndex,
                    onTap: _onBottomNavTapped,
                    items: [
                      BottomNavigationBarItem(
                          icon: IconBuilder(
                            selectedIndex: _controller.currentIndex,
                            regularIconString: 'assets/icons/home.png',
                            selectedIconString:
                                'assets/icons/home-selected.png',
                            itemIndex: 0,
                          ),
                          label: 'Home'),
                      BottomNavigationBarItem(
                          icon: IconBuilder(
                            selectedIndex: _controller.currentIndex,
                            regularIconString: 'assets/icons/order-history.png',
                            selectedIconString:
                                'assets/icons/order-history-selected.png',
                            itemIndex: 1,
                          ),
                          label: 'Orders'),
                      BottomNavigationBarItem(
                          icon: BasketNavigationItem(), label: 'Basket'),
                      BottomNavigationBarItem(
                          icon: IconBuilder(
                            selectedIndex: _controller.currentIndex,
                            regularIconString: 'assets/icons/bubble-chat.png',
                            selectedIconString:
                                'assets/icons/bubble-chat-selected-modified.png',
                            itemIndex: 3,
                          ),
                          label: 'Inbox'),
                      BottomNavigationBarItem(
                          icon: IconBuilder(
                            selectedIndex: _controller.currentIndex,
                            regularIconString: 'assets/icons/user.png',
                            selectedIconString:
                                'assets/icons/user-selected.png',
                            itemIndex: 4,
                          ),
                          label: 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
            if (_controller.isLoadingIndicator) LiveProgressIndicator(),
          ],
        ),
      );
    });
  }
}

class IconBuilder extends StatelessWidget {
  const IconBuilder({
    super.key,
    required int selectedIndex,
    required String regularIconString,
    required String selectedIconString,
    required itemIndex,
  })  : _selectedIconString = selectedIconString,
        _regularIconString = regularIconString,
        _selectedIndex = selectedIndex,
        _itemIndex = itemIndex;

  final int _selectedIndex;
  final String _regularIconString;
  final String _selectedIconString;
  final int _itemIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BottomIconBody(
          iconString: _regularIconString,
          index: _itemIndex,
        ),
        _selectedIndex == _itemIndex
            ? BottomIconBody(
                iconString: _selectedIconString,
                index: _itemIndex,
              )
            : Container(
                width: 0,
                height: 0,
              ),
      ],
    );
  }
}
