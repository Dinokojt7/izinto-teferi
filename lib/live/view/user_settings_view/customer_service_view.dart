import 'package:flutter/material.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/customer_service_tiles.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/promo_container.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_heading.dart';
import 'package:izinto/live/view/user_settings_view/view_widgets/settings_section.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../widgets/buttons/blue_text_button.dart';
import '../../widgets/buttons/save_button.dart';
import '../../widgets/generic_center_dialog.dart';
import '../../widgets/generic_header_row.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../home_view/controller/home_view_controller.dart';
import '../order_history_view/controller/order_history_controller.dart';
import '../order_history_view/view_widgets/latest_order_item.dart'; // Import the LatestOrderItem
import '../order_history_view/view_widgets/view_order_screen/view_order_screen.dart';

class CustomerServiceView extends StatefulWidget {
  final String promoCode;
  const CustomerServiceView({Key? key, required this.promoCode})
      : super(key: key);

  @override
  State<CustomerServiceView> createState() => _CustomerServiceViewState();
}

class _CustomerServiceViewState extends State<CustomerServiceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<OrderHistoryController>(context, listen: false);
      controller.loadUserOrders();
    });
  }

  Future<void> _handleViewButtonPress(BuildContext context, order) async {
    try {
      await _openOrderDetails(context, order);
    } catch (e) {

    }
  }

  Future<void> _openOrderDetails(
      BuildContext context, Map<String, dynamic> order) async {
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);

    // Navigate to ViewOrderScreen
    homeViewController.onIndependentPageNavigation(
      context,
      ViewOrderScreen(
        order: order,
        orderNumber: order['orderId']?.toString() ?? 'N/A',
        isFromCheckout: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    final orderController = Provider.of<OrderHistoryController>(context);

    final latestOrder = orderController.getLatestOrder();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: Dimensions.height30 * 1.5),

          // Your Orders Header
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
            child: GenericHeaderRow(
              headingChild: HeadingStyleText(
                text: 'Your orders',
                weight: FontWeight.w600,
              ),
              actionButtonChild: BlueTextButton(
                text: 'See all',
                onTap: () {
                  _homeViewController.changeIndex(1, false);
                },
              ),
            ),
          ),

          SizedBox(height: Dimensions.height10 + Dimensions.height15),

          // Show Latest Order OR No Orders Dialog
          if (orderController.isLoading)
            Container(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
            )
          else if (latestOrder != null)
            LatestOrderItem(
                order: latestOrder,
                onTap: () => _handleViewButtonPress(context, latestOrder))
          else
            GenericCenterDialog(
              emoji: '🪣',
              heading: 'No past orders',
              description:
                  '..yet! View and explore services that are available in your area to get started.',
              buttonText: 'Browse services',
              callBack: () {
                _homeViewController.changeIndex(0, false);
              },
            ),

          SizedBox(height: Dimensions.height30),

          // Rest of your existing content
          SettingsHeading(heading: 'Promotions'),
          SizedBox(height: Dimensions.height20),

          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              children: [
                settingsSection(
                  subHeading: 'Promo codes',
                  onTap: _showPromoDialog,
                ),
                SizedBox(height: Dimensions.height20),
                GestureDetector(
                    onTap: () {
                      Provider.of<HomeViewController>(context, listen: false)
                          .copyPromoCodeToClip(context, widget.promoCode);
                    },
                    child: PromoContainer(promoCode: widget.promoCode)),
                SizedBox(height: Dimensions.height30),
              ],
            ),
          ),

          CustomerServiceTiles(),
        ],
      ),
    );
  }

  void _showPromoDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildPromoCodeDialog(context),
    );
  }

  Widget _buildPromoCodeDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: Dimensions.width20 * 1.1),
      child: Container(
        height: Dimensions.screenHeight / 2.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width30 * 1.2,
            vertical: Dimensions.height20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeadingStyleText(
                text: 'Share & Earn',
                weight: FontWeight.w600,
                size: Dimensions.font26 / 1.2,
              ),
              SizedBox(height: Dimensions.height10),
              HeadingStyleText(
                text: 'Share this promo code with friends:',
                size: Dimensions.font20 / 1.3,
                family: 'Poppins',
                weight: FontWeight.w400,
                align: TextAlign.center,
              ),
              SizedBox(height: Dimensions.height10),
              // Your promo code display container
              Container(
                padding: EdgeInsets.all(Dimensions.width15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.promoCode,
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height10),
              HeadingStyleText(
                text:
                    'When they use it at checkout, you\'ll both receive R50 credit towards your next service. Minimum order: R500.',
                size: Dimensions.font20 / 1.4,
                family: 'Poppins',
                weight: FontWeight.w300,
                align: TextAlign.center,
              ),
              SizedBox(height: Dimensions.height20),
              SaveButton(
                isActive: true,
                description: 'Got it!',
                isAuthScreen: false,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
