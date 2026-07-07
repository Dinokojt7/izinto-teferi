import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:izinto/live/view/laundry_services/bag_tier_data.dart';
import 'package:izinto/live/view/laundry_services/schedule_pickup_view.dart';
import 'package:izinto/live/widgets/buttons/primary_blue_button.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

class SpecialtyAddonsView extends StatefulWidget {
  final BagTier bagTier;
  final String washType;
  const SpecialtyAddonsView({Key? key, required this.bagTier, required this.washType})
      : super(key: key);

  @override
  State<SpecialtyAddonsView> createState() => _SpecialtyAddonsViewState();
}

class _SpecialtyAddonsViewState extends State<SpecialtyAddonsView> {
  final Map<int, int> _quantities = {};

  int get _addonsTotal => kLaundryAddons.fold(
      0, (sum, item) => sum + item.price * (_quantities[item.id] ?? 0));

  int get _grandTotal => widget.bagTier.price + _addonsTotal;

  void _changeQty(AddonItem item, int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      final current = _quantities[item.id] ?? 0;
      final next = (current + delta).clamp(0, 99);
      _quantities[item.id] = next;
    });
  }

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SchedulePickupView(
          bagTier: widget.bagTier,
          washType: widget.washType,
          addonQuantities: Map.of(_quantities),
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
        title: HeadingStyleText(text: 'Specialty items', size: Dimensions.font16, weight: FontWeight.w600),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
              child: PrimaryStyleText(
                text: "Priced per item — these can't be bagged by weight.",
                size: Dimensions.font16 * 0.85,
                color: Colors.black54,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                itemCount: kLaundryAddons.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.black.withOpacity(0.06)),
                itemBuilder: (context, index) {
                  final item = kLaundryAddons[index];
                  final qty = _quantities[item.id] ?? 0;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HeadingStyleText(text: item.name, size: Dimensions.font16 * 0.95, weight: FontWeight.w500),
                              SizedBox(height: 2),
                              PrimaryStyleText(text: 'R${item.price}', size: Dimensions.font16 * 0.85, color: Colors.black54),
                            ],
                          ),
                        ),
                        _Stepper(
                          quantity: qty,
                          onDecrement: qty > 0 ? () => _changeQty(item, -1) : null,
                          onIncrement: () => _changeQty(item, 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width20, Dimensions.height15, Dimensions.width20, Dimensions.height15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _continue,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: Dimensions.height15 * 0.85),
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3)),
              ),
              child: Text('Skip', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            ),
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            flex: 2,
            child: PrimaryBlueButton(text: 'Continue · R$_grandTotal', onTap: _continue),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _Stepper({required this.quantity, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded, size: 18),
            color: onDecrement != null ? Colors.black : Colors.black26,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 20,
            child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded, size: 18),
            color: Colors.black,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
