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

class NewItemView extends StatefulWidget {
  final int? index;
  final List? homeItemList;
  final dynamic item;
  final bool shouldReturnToBlack;

  const NewItemView({
    Key? key,
    this.index,
    this.homeItemList,
    this.item,
    this.shouldReturnToBlack = true,
  }) : super(key: key);

  @override
  State<NewItemView> createState() => _NewItemViewState();
}

class _NewItemViewState extends State<NewItemView> {
  dynamic get item {
    try {
      if (widget.item != null) {
        return widget.item;
      }

      if (widget.index != null &&
          widget.homeItemList != null &&
          widget.index! < widget.homeItemList!.length) {
        return widget.homeItemList![widget.index!];
      }

      throw Exception('NewItemView: Could not resolve item.');
    } catch (e) {
      if (kDebugMode) {

      }
      return _createFallbackItem();
    }
  }

  NewSpecialtyModel _createFallbackItem() {
    return NewSpecialtyModel(
      id: -1,
      name: 'Item Not Available',
      introduction: 'This item could not be loaded properly.',
      price: [0],
      size: ['Standard'],
      provider: 'assets/image/placeholder.png',
      type: 'Unavailable',
      material: 'Unknown',
    );
  }

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
    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SystemNavigation().applyCustomSystemChromeSettings(
            Colors.white.withOpacity(0.95),
            Brightness.dark,
            Colors.white,
            Brightness.dark);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ReleaseDebug.logItem('NewItemView', item);

    if (item == null) {
      return _buildErrorScreen('Item data is null', _onTap);
    }

    if (_isItemInvalid(item)) {
      return _buildErrorScreen('Item data is incomplete or invalid', _onTap);
    }

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
        body: CustomScrollView(
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
                    // Removed favorite icon
                  ],
                ),
              ),
              pinned: true,
              backgroundColor: Colors.white.withOpacity(0.1),
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProductImage(item),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Center(
                    child: IntroductionText(
                      align: TextAlign.center,
                      text: widget.homeItemList?[widget.index!].material,
                      textSize: Dimensions.font20 * 1.2,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: Dimensions.width20,
                      right: Dimensions.width20,
                      bottom: Dimensions.height20,
                    ),
                    child: _buildContent(item),
                  ),
                ],
              ),
            )
          ],
        ),
        bottomNavigationBar: _buildPromoCodeSection(context),
      ),
    );
  }

  Widget _buildContent(dynamic item) {
    try {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Dimensions.height30),

          // Centered size text
          Center(
            child: Text(
              textAlign: TextAlign.center,
              _getSizeText(item),
              style: TextStyle(
                fontSize: Dimensions.font16 / 1.2,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: Dimensions.height30),

          // Features list
          _buildFeaturesList(item),
        ],
      );
    } catch (e) {
      return Column(
        children: [
          Text('Error displaying content', style: TextStyle(color: Colors.red)),
          SizedBox(height: 20),
          Text('Details: $e'),
        ],
      );
    }
  }

  // Replace the entire _buildFeaturesList and related methods with this:

  Widget _buildFeaturesList(dynamic item) {
    final details = _getDetails(item);

    if (details == null || details.isEmpty) {
      return Container(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Text(
          'No features available',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Extract the data from the details
    List<String> promoIncludes = [];
    List<String> items = [];
    List<String> specialFeatures = [];

    for (var section in details) {
      final header = section.keys.first;
      final content = section[header];

      if (content is List) {
        if (header == "Promo Includes") {
          promoIncludes = List<String>.from(content);
        } else if (header == "Items") {
          items = List<String>.from(content);
        } else if (header == "Special Features") {
          specialFeatures = List<String>.from(content);
        }
      }
    }

    // We only have 2 features, so create exactly 2 rows
    List<Map<String, dynamic>> features = [];
    for (int i = 0; i < 2; i++) {
      features.add({
        'icon': specialFeatures.isNotEmpty && i < specialFeatures.length
            ? specialFeatures[i]
            : '',
        'header': promoIncludes.isNotEmpty && i < promoIncludes.length
            ? promoIncludes[i]
            : 'Feature ${i + 1}',
        'description': items.isNotEmpty && i < items.length ? items[i] : '',
      });
    }

    return Column(
      children: features.map((feature) => _buildFeatureRow(feature)).toList(),
    );
  }

  Widget _buildFeatureRow(Map<String, dynamic> feature) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF56C6FF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildFeatureIcon(feature['icon']),
            ),
          ),

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
      return Image.asset(
        iconPath,
        width: 20,
        height: 20,
        errorBuilder: (context, error, stackTrace) {
          return _getDefaultIcon(iconPath);
        },
      );
    }

    return _getDefaultIcon(iconPath);
  }

  Widget _getDefaultIcon(String iconPath) {
    // Use different default icons based on the image path
    if (iconPath.contains('wallet')) {
      return Icon(Icons.account_balance_wallet,
          color: Color(0xFF56C6FF), size: 20);
    } else if (iconPath.contains('coupon')) {
      return Icon(Icons.local_offer, color: Color(0xFF56C6FF), size: 20);
    }

    return Icon(Icons.check_circle_outline, color: Color(0xFF56C6FF), size: 20);
  }

// Keep your existing _getDetails method
  List<Map<String, dynamic>>? _getDetails(dynamic item) {
    try {
      if (item.details != null && item.details is List) {
        return List<Map<String, dynamic>>.from(item.details);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {

      }
      return null;
    }
  }

  Widget _buildPromoCodeSection(BuildContext context) {
    return Consumer<ProfileViewController>(
      builder: (context, profileController, child) {
        final promoCode = profileController.promoCode ?? '';

        return Container(
          margin: EdgeInsets.symmetric(
              horizontal: Dimensions.width20, vertical: Dimensions.height10),
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height20 / 3),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Promo code text
              Expanded(
                child: Text(
                  promoCode.isNotEmpty ? promoCode : 'No promo code',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
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
                      horizontal: Dimensions.width15,
                      vertical: Dimensions.height10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radius15 * 1.1),
                    ),
                    child: Text(
                      'Copy',
                      style: TextStyle(
                        fontSize: Dimensions.font16 / 1.1,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getSizeText(dynamic item) {
    try {
      if (item.size != null && item.size is List && item.size.isNotEmpty) {
        return item.size[0]?.toString() ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

// Update the _buildFeatureContent method to handle different content types
  Widget _buildFeatureContent(dynamic content, String header) {
    try {
      if (content is List) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content.map<Widget>((item) {
            if (item is String && item.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(bottom: Dimensions.height10 / 2),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.1,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }).toList(),
        );
      } else if (content is String) {
        // Handle case where content is a single string instead of list
        return Text(
          content,
          style: TextStyle(
            fontSize: Dimensions.font16 / 1.1,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        );
      }

      return SizedBox.shrink();
    } catch (e) {
      if (kDebugMode) {

      }
      return SizedBox.shrink();
    }
  }

// Keep the _isSpecialFeatures method
  bool _isSpecialFeatures(String header) {
    return header.toLowerCase().contains('special');
  }

  String _safeGetIntroduction(dynamic item) {
    try {
      return item.introduction?.toString() ?? 'No description available.';
    } catch (e) {
      return 'No description available.';
    }
  }

  // Validation method
  bool _isItemInvalid(dynamic item) {
    try {
      return item.id == null ||
          item.name == null ||
          item.name.toString().isEmpty ||
          item.provider == null;
    } catch (e) {
      return true;
    }
  }

  // Error screen
  Widget _buildErrorScreen(String message, onTap) {
    return Scaffold(
      appBar: AppBar(
        leading: BackArrow(
          iconColor: Colors.black,
          onTap: onTap,
        ),
        title: Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Could not load item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(dynamic item) {
    return Image.asset(
      item.provider, // Using provider instead of img
      width: double.maxFinite,
      fit: BoxFit.scaleDown,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[100],
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 60,
            ),
          ),
        );
      },
    );
  }
}

// Helper class for release mode debugging
class ReleaseDebug {
  static void logItem(String tag, dynamic item) {
    if (kDebugMode) {

    }
  }
}
