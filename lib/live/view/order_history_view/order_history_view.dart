import 'package:flutter/material.dart';
import 'package:izinto/live/view/order_history_view/view_widgets/order_history_item.dart';
import 'package:izinto/live/view/order_history_view/view_widgets/order_tab.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/small_text.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../utilities/colors.dart';
import '../../widgets/generic_center_dialog.dart';
import '../../widgets/no_user_page.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../home_view/controller/home_view_controller.dart';
import 'controller/order_history_controller.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({Key? key}) : super(key: key);

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filterTabs = ['active', 'fulfilled', 'closed'];

  // Track current index for reactive updates
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterTabs.length, vsync: this);

    // Add listener to track both programmatic and swipe changes
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<OrderHistoryController>(context, listen: false);
      controller.loadUserOrders();
    });
  }

  void _handleTabChange() {
    if (_tabController.index != _currentIndex) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  String _getFilterTitle(String filter) {
    switch (filter) {
      case 'active':
        return 'Active';
      case 'fulfilled':
        return 'Fulfilled';
      case 'closed':
        return 'Closed';
      default:
        return 'Orders';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final orderController = Provider.of<OrderHistoryController>(context);

    if (user == null) {
      return NoUserPage(
        title: 'Orders',
        message: 'Log in to see your orders.',
        isSettingView: false,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.97),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          GenericAppBar(
            heading: 'Your orders',
            removeLeading: true,
          ),

          // Tab Bar - Always visible when there are orders
          if (orderController.orders.isNotEmpty) _buildTabBar(),

          // Main Content Area
          Expanded(
            child: orderController.orders.isEmpty
                ? _buildEmptyAllOrdersState()
                : TabBarView(
                    controller: _tabController,
                    children: _filterTabs.map((filter) {
                      return _buildOrderListForFilter(filter, orderController);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height15 / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TabBar(
            dividerHeight: 0.0,
            controller: _tabController,
            indicator: BoxDecoration(), // Remove default indicator
            indicatorColor: Colors.transparent,
            labelColor: Colors.transparent,
            unselectedLabelColor: Colors.transparent,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            tabs: _filterTabs.asMap().entries.map((entry) {
              final index = entry.key;
              final filter = entry.value;
              return Tab(
                child: OrderTab(
                  title: _getFilterTitle(filter),
                  isActive: _currentIndex == index,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListForFilter(
      String filter, OrderHistoryController orderController) {
    final filteredOrders = _filterOrders(orderController.orders, filter);

    return Column(
      children: [
        // Header with count
        if (filteredOrders.isNotEmpty)
          _buildFilterHeader(filter, filteredOrders.length),

        // Order List or Empty State
        Expanded(
          child: filteredOrders.isEmpty
              ? _buildEmptyFilterState(filter)
              : _buildOrderListView(filteredOrders),
        ),
      ],
    );
  }

  Widget _buildFilterHeader(String filter, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height20,
        Dimensions.height10,
        Dimensions.height10,
      ),
      child: Row(
        children: [
          HeadingStyleText(
            text: _getFilterTitle(filter),
            weight: FontWeight.w600,
          ),
          SizedBox(width: Dimensions.width10),
          SmallText(
            height: 1.5,
            color: Colors.black,
            size: Dimensions.font16 / 1.5,
            text: '$count ${count == 1 ? 'item' : 'items'}',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListView(List<Map<String, dynamic>> orders) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height10,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderHistoryItem(
          order: order,
          index: index,
        );
      },
    );
  }

  Widget _buildEmptyAllOrdersState() {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimensions.height30,
        bottom: Dimensions.height20,
      ),
      child: GenericCenterDialog(
        emoji: '🪣',
        heading: 'No past orders',
        description:
            '..yet! View and explore services that are available in your area to get started.',
        buttonText: 'Browse services',
        callBack: () {
          final homeViewController =
              Provider.of<HomeViewController>(context, listen: false);
          homeViewController.changeIndex(0, false);
        },
      ),
    );
  }

  Widget _buildEmptyFilterState(String filter) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimensions.height30,
        bottom: Dimensions.height20,
      ),
      child: GenericCenterDialog(
        emoji: _getEmptyStateEmoji(filter),
        heading: _getEmptyStateHeading(filter),
        description: _getEmptyStateDescription(filter),
        buttonText: _getEmptyStateButtonText(filter),
        callBack: () {
          if (filter == 'active') {
            final homeViewController =
                Provider.of<HomeViewController>(context, listen: false);
            homeViewController.changeIndex(0, false);
          } else {
            _tabController.animateTo(0);
          }
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterOrders(
      List<Map<String, dynamic>> orders, String filter) {
    switch (filter) {
      case 'active':
        return orders.where((order) {
          final status = order['status']?.toString().toLowerCase() ?? '';
          return status == 'pending' ||
              status == 'in_progress' ||
              status == 'processing';
        }).toList();
      case 'fulfilled':
        return orders.where((order) {
          final status = order['status']?.toString().toLowerCase() ?? '';
          return status == 'completed' || status == 'fulfilled';
        }).toList();
      case 'closed':
        return orders.where((order) {
          final status = order['status']?.toString().toLowerCase() ?? '';
          return status == 'cancelled' ||
              status == 'closed' ||
              status == 'refunded';
        }).toList();
      default:
        return orders;
    }
  }

  String _getEmptyStateEmoji(String filter) {
    switch (filter) {
      case 'active':
        return '🪣';
      case 'fulfilled':
        return '✅';
      case 'closed':
        return '📦';
      default:
        return '📝';
    }
  }

  String _getEmptyStateHeading(String filter) {
    switch (filter) {
      case 'active':
        return 'No active orders';
      case 'fulfilled':
        return 'No fulfilled orders';
      case 'closed':
        return 'No closed orders';
      default:
        return 'No past orders';
    }
  }

  String _getEmptyStateDescription(String filter) {
    switch (filter) {
      case 'active':
        return 'You don\'t have any active orders at the moment. Browse services to get started!';
      case 'fulfilled':
        return 'Your completed orders will appear here once they\'re fulfilled. Keep an eye on your active orders!';
      case 'closed':
        return 'Cancelled or closed orders will appear here. All your completed orders are looking great!';
      default:
        return '..yet! View and explore services that are available in your area to get started.';
    }
  }

  String _getEmptyStateButtonText(String filter) {
    switch (filter) {
      case 'active':
        return 'Browse services';
      case 'fulfilled':
        return 'View active orders';
      case 'closed':
        return 'View active orders';
      default:
        return 'Browse services';
    }
  }
}
