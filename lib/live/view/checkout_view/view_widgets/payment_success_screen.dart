import 'package:flutter/material.dart';
import 'package:izinto/live/view/order_history_view/view_widgets/view_order_screen/view_order_screen.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';

import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import 'package:provider/provider.dart';

import '../../../utilities/generic_system_navigation.dart';
import '../../home_view/controller/home_view_controller.dart';

class CashPaymentSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const CashPaymentSuccessScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<CashPaymentSuccessScreen> createState() =>
      _CashPaymentSuccessScreenState();
}

class _CashPaymentSuccessScreenState extends State<CashPaymentSuccessScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.white, Brightness.dark, Colors.white, Brightness.dark);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   SystemNavigation().applyCustomSystemChromeSettings(
    //       Colors.white, Brightness.dark, Colors.white, Brightness.dark);
    // });

    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    final orderId = widget.order['orderId'] ?? 'N/A';
    final totalAmount = widget.order['totalAmount'] ?? 0;
    final serviceTypes = widget.order['serviceTypes'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.width20),
                  child: Column(
                    children: [
                      // Success Animation
                      // Alternative success section without Lottie
                      Container(
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: LiveColors.accent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: LiveColors.accent,
                                size: 40,
                              ),
                            ),
                            SizedBox(height: Dimensions.height15),
                            HeadingStyleText(
                              text: 'Confirmed!',
                              size: Dimensions.font20,
                              weight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.height15),
                      Image.asset(
                        'assets/image/vacuuming.png',
                        fit: BoxFit.contain,
                        width: Dimensions.width20 + Dimensions.width30 * 1.5,
                        height: Dimensions.width20 + Dimensions.height30 * 1.5,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.shopping_bag,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: Dimensions.height15),

                      // Success Message
                      Text(
                        'You’re all set! We’ll handle the rest.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.1,
                          color: Colors.grey.shade900,
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: Dimensions.height30),

                      // Order Details Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(Dimensions.width20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Order ID
                            _buildDetailRow(
                              label: 'Order Number',
                              value: '#$orderId',
                              valueColor: Colors.blue,
                            ),
                            Divider(color: Colors.grey.shade300),

                            // Amount
                            _buildDetailRow(
                              label: 'Total Amount',
                              value: 'R$totalAmount,00',
                              valueColor: Colors.black,
                            ),
                            Divider(color: Colors.grey.shade300),

                            // Payment Method
                            _buildDetailRow(
                              label: 'Payment Method',
                              value: 'Cash on Delivery',
                              valueColor: Colors.black,
                            ),
                            Divider(color: Colors.grey.shade300),

                            // Services
                            _buildDetailRow(
                              label: 'Services',
                              value: serviceTypes.isNotEmpty
                                  ? serviceTypes.join(', ')
                                  : 'Various Services',
                              valueColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.height30),

                      // Next Steps Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(Dimensions.width20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeadingStyleText(
                              text: 'What happens next?',
                              size: Dimensions.font20 / 1.2,
                              weight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            SizedBox(height: Dimensions.height15),
                            _buildInstructionItem(
                              icon: Icons.phone,
                              text:
                                  'Our team will contact you shortly to confirm your order details',
                            ),
                            _buildInstructionItem(
                              icon: Icons.schedule,
                              text:
                                  'Prepare cash for payment when our service provider arrives',
                            ),
                            _buildInstructionItem(
                              icon: Icons.track_changes,
                              text:
                                  'Track your order status in the Orders section',
                            ),
                            _buildInstructionItem(
                              icon: Icons.support_agent,
                              text: 'Contact support if you have any questions',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.height20),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Button
            Container(
              height: Dimensions.bottomHeightBar / 1.1,
              padding: EdgeInsets.all(Dimensions.width20),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SaveButton(
                  isActive: true,
                  description: 'View',
                  isAuthScreen: false,
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => ViewOrderScreen(
                                orderNumber: '#$orderId',
                                order: widget.order,
                                isFromCheckout: true,
                              )),
                      (Route<dynamic> route) => false, // removes everything
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        height: Dimensions.bottomHeightBar / 3,
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: HeadingStyleText(
              text: label,
              size: Dimensions.font16 / 1.2,
              weight: FontWeight.w500,
              color: Colors.grey.shade900,
            ),
          ),
          Expanded(
            flex: 3,
            child: HeadingStyleText(
              text: value,
              size: Dimensions.font16 / 1.2,
              weight: FontWeight.w600,
              color: valueColor,
              align: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.height15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(right: Dimensions.width15),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: Dimensions.font16 / 1.2,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
