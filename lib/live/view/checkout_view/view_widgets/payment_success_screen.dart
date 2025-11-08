import 'package:flutter/material.dart';
import 'package:izinto/live/auxiliery_classes/generic_app_bar.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:lottie/lottie.dart';

import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import 'package:provider/provider.dart';

import '../../home_view/controller/home_view_controller.dart';

class CashPaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const CashPaymentSuccessScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    final orderId = order['orderId'] ?? 'N/A';
    final totalAmount = order['totalAmount'] ?? 0;
    final serviceTypes = order['serviceTypes'] ?? [];

    return PopScope(
      canPop: false, // Prevent going back to checkout
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              GenericAppBar(
                heading: 'Order Confirmed',
                removeLeading: true,
              ),
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
                                  color:
                                      LiveColors.standardBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: LiveColors.standardBlue,
                                  size: 40,
                                ),
                              ),
                              SizedBox(height: Dimensions.height15),
                              HeadingStyleText(
                                text: 'Payment Successful!',
                                size: Dimensions.font20,
                                weight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Dimensions.height30),

                        // Order Confirmed Message
                        HeadingStyleText(
                          text: 'Order Confirmed!',
                          size: Dimensions.font26,
                          weight: FontWeight.w700,
                          align: TextAlign.center,
                          color: Colors.black,
                        ),
                        SizedBox(height: Dimensions.height15),

                        // Success Message
                        Text(
                          'Your order has been successfully placed and is being processed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Dimensions.font16,
                            color: Colors.grey.shade600,
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
                                valueColor: LiveColors.standardBlue,
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
                            color: LiveColors.standardBlue.withOpacity(0.05),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius15),
                            border: Border.all(
                              color: LiveColors.standardBlue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HeadingStyleText(
                                text: 'What happens next?',
                                size: Dimensions.font20,
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
                                text:
                                    'Contact support if you have any questions',
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
                height: Dimensions.bottomHeightBar,
                padding: EdgeInsets.all(Dimensions.width20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SaveButton(
                  isActive: true,
                  description: 'View My Orders',
                  isAuthScreen: false,
                  onTap: () {
                    // Simply navigate to order history using your existing navigation
                    // This will automatically handle the back navigation since it's changing tabs
                    homeViewController.changeIndex(1, false);

                    // Close the success screen
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
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
              size: Dimensions.font16,
              weight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            flex: 3,
            child: HeadingStyleText(
              text: value,
              size: Dimensions.font16,
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
              color: LiveColors.standardBlue,
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
                fontSize: Dimensions.font16 / 1.1,
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
