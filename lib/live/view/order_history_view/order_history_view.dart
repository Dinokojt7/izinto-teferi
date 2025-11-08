// Updated OrderHistoryView
import 'package:flutter/material.dart';
import 'package:izinto/live/view/order_history_view/view_widgets/order_history_item.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../utilities/colors.dart';
import '../../widgets/generic_center_dialog.dart';
import '../../widgets/no_user_page.dart';
import '../home_view/controller/home_view_controller.dart';
import 'controller/order_history_controller.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({Key? key}) : super(key: key);

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
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
          if (orderController.isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: LiveColors.standardBlue,
                ),
              ),
            )
          else if (orderController.orders.isEmpty)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    top: Dimensions.height30, bottom: Dimensions.height20),
                child: GenericCenterDialog(
                  emoji: '\u{1F9FA}',
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
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height10,
                ),
                itemCount: orderController.orders.length,
                itemBuilder: (context, index) {
                  final order = orderController.orders[index];
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
}
