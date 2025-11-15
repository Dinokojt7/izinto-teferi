import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:provider/provider.dart';

import '../../utils/dimensions.dart';
import '../auxiliery_classes/generic_app_bar.dart';
import '../view/profile_view/controller/profile_view_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralInformationPage extends StatelessWidget {
  final String title;
  final String heading;
  final String information;
  final PageType pageType;
  final Map<String, dynamic>? additionalData;

  const GeneralInformationPage({
    Key? key,
    required this.title,
    required this.information,
    required this.heading,
    this.pageType = PageType.general,
    this.additionalData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.97),
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
              heading: title,
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(left: 24.0, top: 25.0, right: 24.0),
                  child: Column(
                    children: [
                      // Main Information Section
                      _buildMainInformationSection(context),

                      // Additional Data Sections based on page type
                      if (pageType == PageType.wallet)
                        _buildWalletDetailsSection(context),

                      if (pageType == PageType.promoCode &&
                          additionalData != null)
                        _buildPromoCodeDetailsSection(context),

                      SizedBox(height: Dimensions.height20),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainInformationSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                heading,
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            information,
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.3,
              color: Colors.grey.shade700,
              fontFamily: 'Poppins',
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletDetailsSection(BuildContext context) {
    final profileController = Provider.of<ProfileViewController>(context);

    return Column(
      children: [
        SizedBox(height: Dimensions.height20),
        // Current Balance Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet,
                      color: Colors.blue, size: 20),
                  SizedBox(width: Dimensions.width10),
                  Text(
                    'Current Wallet Balance',
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'R${profileController.walletBalance},00',
                style: TextStyle(
                  fontSize: Dimensions.font20 * 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade900,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'Available for use on your next order',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.2,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: Dimensions.height15),

        // Wallet Usage Info
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.width15),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(
              color: Colors.green.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to use your wallet:',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Dimensions.height10),
              _buildInfoItem(
                'Apply wallet balance at checkout',
                Icons.shopping_cart_checkout,
              ),
              _buildInfoItem(
                'Partial payments supported',
                Icons.payment,
              ),
              _buildInfoItem(
                'Instant discount application',
                Icons.bolt,
              ),
              _buildInfoItem(
                'Secure and convenient',
                Icons.security,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCodeDetailsSection(BuildContext context) {
    final promoData = additionalData!;

    return Column(
      children: [
        SizedBox(height: Dimensions.height20),

        // Promo Code Stats Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(
              color: Colors.purple.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.purple, size: 20),
                  SizedBox(width: Dimensions.width10),
                  Text(
                    'Promo Code Statistics',
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height15),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: Dimensions.width15,
                mainAxisSpacing: Dimensions.height10,
                childAspectRatio: 2.5,
                children: [
                  _buildStatItem(
                    'Times Used',
                    '${promoData['timesUsed'] ?? 0}',
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatItem(
                    'Total Rewards',
                    'R${promoData['totalRewardsGiven'] ?? 0},00',
                    Icons.card_giftcard,
                    Colors.green,
                  ),
                  _buildStatItem(
                    'Recent Users',
                    '${promoData['recentUsersCount'] ?? 0}',
                    Icons.person_add,
                    Colors.orange,
                  ),
                  _buildStatItem(
                    'Last Used',
                    _formatDate(promoData['lastUsedAt']),
                    Icons.calendar_today,
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: Dimensions.height15),

        // Promo Code Benefits
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.width15),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(
              color: Colors.orange.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promo Code Benefits:',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade800,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: Dimensions.height10),
              _buildInfoItem(
                'R50 discount per successful referral',
                Icons.discount,
              ),
              _buildInfoItem(
                'Minimum order: R500',
                Icons.shopping_bag,
              ),
              _buildInfoItem(
                'Share with friends and family',
                Icons.share,
              ),
              _buildInfoItem(
                'Instant wallet rewards',
                Icons.account_balance_wallet,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.height10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 16),
          SizedBox(width: Dimensions.width10),
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

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.4,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Never';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year}';
      }
      return 'Recently';
    } catch (e) {
      return 'Recently';
    }
  }
}

enum PageType {
  general,
  wallet,
  promoCode,
}
