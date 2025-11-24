import 'package:flutter/material.dart';
import 'package:izinto/models/new_specialty_model.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../utilities/generic_system_navigation.dart';
import '../../../widgets/icons/back_arrow.dart';
import '../../../widgets/text_widgets/introduction_text.dart';
import '../../profile_view/controller/profile_view_controller.dart';
import '../controller/home_view_controller.dart';

class ReferralRewardsView extends StatefulWidget {
  final bool shouldReturnToBlack;

  const ReferralRewardsView({
    Key? key,
    this.shouldReturnToBlack = true,
  }) : super(key: key);

  @override
  State<ReferralRewardsView> createState() => _ReferralRewardsViewState();
}

class _ReferralRewardsViewState extends State<ReferralRewardsView> {
  // Static data - no backend fetch needed
  final Map<String, dynamic> _referralData = {
    "title": "Share & Earn Together",
    "subtitle": "Give R50, Get R50 - Everyone Wins!",
    "description":
        "Spread the word about Izinto and both you and your friends benefit. When they use your code for their first service booking, you both receive special rewards to use on your next home service orders.",
    "features": [
      {
        "icon": "assets/image/gift.png",
        "header": "You Earn R50 Credit",
        "description":
            "When your friend completes their first service booking using your code, you'll receive R50 in Izinto service credit applicable to laundry, cleaning, or any home service."
      },
      {
        "icon": "assets/image/discount.png",
        "header": "They Save R50 Instantly",
        "description":
            "Your friend gets R50 off their first service order when they spend R500 or more. Perfect for trying our premium home services."
      }
    ],
    "howItWorks": [
      "Share your unique promo code with friends & family",
      "They enter your code when booking their first service",
      "Their order must be R500+ to qualify for the R50 discount",
      "Once completed, you receive R50 service credit within 24 hours",
      "Use your credit on any Izinto home service - laundry, cleaning, pet care & more"
    ]
  };

  void _handleBackNavigation(BuildContext context) {
    try {
      final navColor = widget.shouldReturnToBlack ? Colors.black : Colors.white;
      final brightness =
          widget.shouldReturnToBlack ? Brightness.light : Brightness.dark;

      SystemNavigation().applyCustomSystemChromeSettings(
        navColor,
        brightness,
        navColor,
        brightness,
      );

      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  void _applySystemChromeSettings() {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);
  }

  void _onTap() {
    _applySystemChromeSettings();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set transparent status bar initially for the header image
      SystemNavigation().applyCustomSystemChromeSettings(Colors.transparent,
          Brightness.dark, Colors.transparent, Brightness.dark);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _applySystemChromeSettings();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            // Change status bar to white when scrolling up
            if (scrollNotification.metrics.pixels > 100) {
              SystemNavigation().applyCustomSystemChromeSettings(
                  Colors.white, Brightness.dark, Colors.white, Brightness.dark);
            } else {
              // Reset to transparent when at top
              SystemNavigation().applyCustomSystemChromeSettings(
                  Colors.transparent,
                  Brightness.dark,
                  Colors.transparent,
                  Brightness.dark);
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 50,
                title: Padding(
                  padding: EdgeInsets.only(right: Dimensions.width10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackArrow(iconColor: Colors.black, onTap: _onTap),
                    ],
                  ),
                ),
                pinned: true,
                backgroundColor: Colors.white,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderImage(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Center(
                        child: IntroductionText(
                          align: TextAlign.center,
                          text: _referralData['title'],
                          textSize: Dimensions.font20 * 1.3,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10),

                      // Subtitle
                      Center(
                        child: Text(
                          _referralData['subtitle'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Dimensions.font16 / 1.1,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      SizedBox(height: Dimensions.height30),

                      // Description
                      Text(
                        _referralData['description'],
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.2,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: Dimensions.height30),

                      // Features
                      _buildFeaturesSection(),
                      SizedBox(height: Dimensions.height30),

                      // How It Works
                      _buildHowItWorksSection(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: _buildPromoCodeSection(context),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      color: Colors.blue.shade50,
      child: Center(
        child: Image.asset(
          'assets/image/promo-line.png',
          width: 150,
          height: 350,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.people_alt_rounded,
              size: 80,
              color: Colors.blue.shade300,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Dimensions.height20),
        ..._referralData['features']
            .map<Widget>((feature) => _buildFeatureRow(feature))
            .toList(),
      ],
    );
  }

  Widget _buildFeatureRow(Map<String, dynamic> feature) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container with circular background
          _buildFeatureIcon(feature['icon']),
          SizedBox(width: Dimensions.width15),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  feature['header'] ?? '',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 1.1,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 2),

                // Description
                Text(
                  feature['description'] ?? '',
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.2,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
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

  Widget _buildFeatureIcon(String iconPath) {
    if (iconPath.isNotEmpty && iconPath.contains('.png')) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return _getDefaultIcon(iconPath);
            },
          ),
        ),
      );
    }

    return _getDefaultIcon(iconPath);
  }

  Widget _getDefaultIcon(String iconPath) {
    // Container for consistent circular background
    Widget _wrapWithBackground(Widget child) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      );
    }

    if (iconPath.contains('gift')) {
      return _wrapWithBackground(
        Image.asset(
          'assets/image/wallet.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.card_giftcard,
                color: Colors.blue.shade700, size: 24);
          },
        ),
      );
    } else if (iconPath.contains('discount')) {
      return _wrapWithBackground(
        Image.asset(
          'assets/image/coupon.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.percent_rounded,
                color: Colors.blue.shade700, size: 24);
          },
        ),
      );
    } else if (iconPath.contains('wallet') || iconPath.contains('earn')) {
      return _wrapWithBackground(
        Image.asset(
          'assets/image/wallet.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.account_balance_wallet,
                color: Colors.blue.shade700, size: 24);
          },
        ),
      );
    }

    // Default for celebrations
    return _wrapWithBackground(
      Icon(Icons.celebration_rounded, color: Colors.blue.shade700, size: 24),
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Simple Steps to Earn Together',
          style: TextStyle(
            fontSize: Dimensions.font16 * 1.1,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        SizedBox(height: Dimensions.height20),
        ...List.generate(
            _referralData['howItWorks'].length,
            (index) => Padding(
                  padding: EdgeInsets.only(bottom: Dimensions.height15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Dimensions.width15),
                      Expanded(
                        child: Text(
                          _referralData['howItWorks'][index],
                          style: TextStyle(
                            fontSize: Dimensions.font16 / 1.2,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
      ],
    );
  }

  Widget _buildPromoCodeSection(BuildContext context) {
    return Consumer<ProfileViewController>(
      builder: (context, profileController, child) {
        final promoCode = profileController.promoCode ?? '';

        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: Dimensions.width20, vertical: Dimensions.height20),
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20, vertical: Dimensions.height20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Unique Referral Code',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Promo code text
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width15,
                        vertical: Dimensions.height10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius20 / 2),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        promoCode.isNotEmpty
                            ? promoCode
                            : 'Generating your code...',
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.1,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: Dimensions.width15),

                  // Copy button
                  if (promoCode.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Provider.of<HomeViewController>(context, listen: false)
                            .copyPromoCodeToClip(context, promoCode);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,
                          vertical: Dimensions.height15 / 1.35,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius20 / 2),
                        ),
                        child: Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: Dimensions.font16 / 1.1,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'Share this code with friends & family to start earning together!',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.2,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
