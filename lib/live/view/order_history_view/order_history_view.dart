// Updated OrderHistoryView
import 'package:flutter/material.dart';
import 'package:izinto/live/view/order_history_view/view_widgets/order_history_item.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/integers_and_doubles.dart';
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

class _OrderHistoryViewState extends State<OrderHistoryView> {
  String _selectedFilter = 'active';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<OrderHistoryController>(context, listen: false);
      controller.loadUserOrders();
    });
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

    // Filter orders based on selected filter
    final filteredOrders =
        _filterOrders(orderController.orders, _selectedFilter);

    String _filterText(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
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

          // Filter Menu
          _buildFilterMenu(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height20,
              Dimensions.height10,
              Dimensions.height10,
            ),
            child: Row(
              children: [
                HeadingStyleText(
                  text: _filterText(_selectedFilter),
                  weight: FontWeight.w600,
                ),
                SizedBox(
                  width: Dimensions.width10,
                ),
                SmallText(
                    height: 1.5,
                    color: Colors.black,
                    size: Dimensions.font16 / 1.5,
                    text:
                        '${filteredOrders.length} ${filteredOrders.length == 1 ? 'item' : 'items'}')
              ],
            ),
          ),

          if (orderController.isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: LiveColors.standardBlue,
                ),
              ),
            )
          else if (filteredOrders.isEmpty)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    top: Dimensions.height30, bottom: Dimensions.height20),
                child: GenericCenterDialog(
                  emoji: _getEmptyStateEmoji(_selectedFilter),
                  heading: _getEmptyStateHeading(_selectedFilter),
                  description: _getEmptyStateDescription(_selectedFilter),
                  buttonText: 'Browse services',
                  callBack: () {
                    final homeViewController =
                        Provider.of<HomeViewController>(context, listen: false);
                    homeViewController.changeIndex(0, false);
                  },
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height10,
                ),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return OrderHistoryItem(
                    order: order,
                    index: index,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu() {
    return Container(
      width: double.infinity,
      height: Dimensions.height30 * 2,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10 * 1.1),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
          children: [
            _buildFilterChip('Active', 'active'),
            SizedBox(width: Dimensions.width10),
            _buildFilterChip('Fulfilled', 'fulfilled'),
            SizedBox(width: Dimensions.width10),
            _buildFilterChip('Closed', 'closed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Container(
          height: Dimensions.height45 / 1.1,
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(
                    width: 1,
                    color: Colors.grey.withOpacity(0.1),
                  )
                : null,
            borderRadius: BorderRadius.circular(Dimensions.radius30 * 2),
            color: isSelected
                ? LiveColors.accent.withOpacity(0.5)
                : Colors.transparent,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: Dimensions.width10 / 2,
                horizontal: Dimensions.width10),
            child: Center(
              //register
              child: IntegerText(
                text: label,
                size: Dimensions.font16 / 1.1,
                fontWeight: FontWeight.w600,
                color: Color(0Xff353839),
              ),
            ),
          ),
        ));
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
        return '🕒';
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
        return 'Your completed orders will appear here once they\'re fulfilled.';
      case 'closed':
        return 'Cancelled or closed orders will appear here.';
      default:
        return '..yet! View and explore services that are available in your area to get started.';
    }
  }
}
