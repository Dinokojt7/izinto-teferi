// lib/live/view/laundry_services/laundry_home_view.dart
import 'package:flutter/material.dart';
import 'package:izinto/live/view/laundry_services/bag_selector_view.dart';
import 'package:izinto/live/widgets/buttons/primary_blue_button.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../../widgets/text_widgets/primary_style_text.dart';

class LaundryHomeView extends StatefulWidget {
  const LaundryHomeView({Key? key}) : super(key: key);

  @override
  State<LaundryHomeView> createState() => _LaundryHomeViewState();
}

class _LaundryHomeViewState extends State<LaundryHomeView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _refreshController.refreshCompleted();
  }

  void _chooseYourBag() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BagSelectorView()),
    );
  }

  Widget _buildTopRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      child: HeadingStyleText(
        text: 'Laundry',
        size: Dimensions.font26,
        weight: FontWeight.w600,
      ),
    );
  }

  Widget _buildHeroCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Dimensions.width20),
        decoration: BoxDecoration(
          color: LiveColors.secondary,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadingStyleText(
              text: 'Pay by the bag,\nnot by the item.',
              size: Dimensions.font26 * 0.9,
              weight: FontWeight.w600,
              height: 1.15,
            ),
            SizedBox(height: Dimensions.height10),
            PrimaryStyleText(
              text: 'Choose a weight tier, pack it, hand it over. We weigh everything on collection.',
              size: Dimensions.font16 * 0.9,
              color: Colors.black87,
              height: 1.4,
            ),
            SizedBox(height: Dimensions.height20),
            PrimaryBlueButton(
              text: 'Choose your bag',
              icon: Icons.shopping_bag_rounded,
              onTap: _chooseYourBag,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksHeader() {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimensions.width20,
        top: Dimensions.height30,
        bottom: Dimensions.height15,
      ),
      child: HeadingStyleText(
        text: 'How it works',
        size: Dimensions.font20 * 0.95,
        weight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required String title,
    required String description,
    required String iconAsset,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: LiveColors.lavender,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                iconAsset,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Text(number,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: Dimensions.font16));
                },
              ),
            ),
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadingStyleText(
                  text: '$number. $title',
                  size: Dimensions.font16,
                  weight: FontWeight.w600,
                ),
                SizedBox(height: Dimensions.height10 / 2),
                PrimaryStyleText(
                  text: description,
                  size: Dimensions.font16 * 0.85,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Column(
      children: [
        _buildStepRow(
          number: '1',
          title: 'Pick a bag size',
          description: 'No need to list each item — just choose a weight tier.',
          iconAsset: 'assets/laundry/select_service.png',
        ),
        _buildStepRow(
          number: '2',
          title: 'Pack & hand over',
          description: 'Use one bag per tier. Meet your driver or leave it at your door.',
          iconAsset: 'assets/laundry/pack_items.png',
        ),
        _buildStepRow(
          number: '3',
          title: 'Cleaned & returned',
          description: 'We weigh on collection — you only ever pay your selected tier.',
          iconAsset: 'assets/laundry/hand_over.png',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const ClassicHeader(height: 70),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(),
                _buildHeroCard(),
                _buildHowItWorksHeader(),
                _buildStepsSection(),
                SizedBox(height: Dimensions.height30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
