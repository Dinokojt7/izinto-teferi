import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/laundry_services/bag_tier_data.dart';
import 'package:izinto/live/view/laundry_services/specialty_addons_view.dart';
import 'package:izinto/live/widgets/buttons/primary_blue_button.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

class BagSelectorView extends StatefulWidget {
  const BagSelectorView({Key? key}) : super(key: key);

  @override
  State<BagSelectorView> createState() => _BagSelectorViewState();
}

class _BagSelectorViewState extends State<BagSelectorView> {
  int _washTypeIndex = 0;
  BagTier _selectedTier = kBagTiers.firstWhere((t) => t.popular);

  void _selectTier(BagTier tier) {
    HapticFeedback.selectionClick();
    setState(() => _selectedTier = tier);
  }

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpecialtyAddonsView(
          bagTier: _selectedTier,
          washType: kWashTypes[_washTypeIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: HeadingStyleText(
          text: 'Choose your bag',
          size: Dimensions.font16,
          weight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Dimensions.height15),
                    _buildSegmentedControl(),
                    SizedBox(height: Dimensions.height20),
                    ...kBagTiers.map((tier) => Padding(
                          padding: EdgeInsets.only(bottom: Dimensions.height15),
                          child: _BagCard(
                            tier: tier,
                            selected: tier.id == _selectedTier.id,
                            onTap: () => _selectTier(tier),
                          ),
                        )),
                    Container(
                      padding: EdgeInsets.all(Dimensions.width15),
                      decoration: BoxDecoration(
                        color: LiveColors.lavender.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(Dimensions.radius15),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18, color: Colors.black54),
                          SizedBox(width: Dimensions.width10),
                          Expanded(
                            child: PrimaryStyleText(
                              text: 'Not sure? We weigh everything on collection — you only ever pay your selected tier.',
                              size: Dimensions.font16 * 0.8,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      child: Row(
        children: List.generate(kWashTypes.length, (index) {
          final selected = index == _washTypeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _washTypeIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: Dimensions.height10 * 0.8),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(Dimensions.radius15 * 0.8),
                  boxShadow: selected
                      ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]
                      : null,
                ),
                child: Center(
                  child: PrimaryStyleText(
                    text: kWashTypes[index],
                    size: Dimensions.font16 * 0.8,
                    weight: FontWeight.w600,
                    color: selected ? Colors.black : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height15,
        Dimensions.width20,
        Dimensions.height15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: PrimaryBlueButton(
        text: 'Continue · R${_selectedTier.price}',
        onTap: _continue,
      ),
    );
  }
}

class _BagCard extends StatelessWidget {
  final BagTier tier;
  final bool selected;
  final VoidCallback onTap;

  const _BagCard({required this.tier, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(
            color: selected ? LiveColors.accent : Colors.black12,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 14, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              child: Image.asset(tier.image, width: 60, height: 60, fit: BoxFit.cover),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HeadingStyleText(text: tier.title, size: Dimensions.font16, weight: FontWeight.w600),
                      if (tier.popular) ...[
                        SizedBox(width: Dimensions.width10 * 0.6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: LiveColors.accent, borderRadius: BorderRadius.circular(6)),
                          child: Text('POPULAR',
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: LiveColors.primary)),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2),
                  PrimaryStyleText(
                    text: '${tier.weightKg} kg · ${tier.loads}',
                    size: Dimensions.font16 * 0.8,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                HeadingStyleText(text: 'R${tier.price}', size: Dimensions.font16, weight: FontWeight.w600),
                SizedBox(height: 4),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? LiveColors.accent : Colors.black26,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
