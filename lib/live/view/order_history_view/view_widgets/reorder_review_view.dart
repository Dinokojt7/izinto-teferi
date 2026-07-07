import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/checkout_view/checkout_page.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/widgets/buttons/primary_blue_button.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/models/new_specialty_model.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:provider/provider.dart';

/// R2 — reorder review. Rehydrates a past order's line items into a fresh,
/// editable cart rather than blindly resubmitting it. We don't have a live
/// price-lookup against the current catalog yet, so this shows a general
/// "prices may have changed" notice rather than fabricating a specific diff.
class ReorderReviewView extends StatefulWidget {
  final Map<String, dynamic> order;
  const ReorderReviewView({Key? key, required this.order}) : super(key: key);

  @override
  State<ReorderReviewView> createState() => _ReorderReviewViewState();
}

class _ReorderReviewViewState extends State<ReorderReviewView> {
  late List<Map<String, dynamic>> _items;
  late Map<int, int> _quantities;

  @override
  void initState() {
    super.initState();
    final rawItems = (widget.order['items'] as List?) ?? [];
    _items = rawItems.whereType<Map<String, dynamic>>().toList();
    _quantities = {
      for (final item in _items)
        (item['id'] as num?)?.toInt() ?? item.hashCode: (item['quantity'] as num?)?.toInt() ?? 1,
    };
  }

  int _idFor(Map<String, dynamic> item) => (item['id'] as num?)?.toInt() ?? item.hashCode;

  int get _total => _items.fold(0, (sum, item) {
        final price = (item['price'] as num?)?.toInt() ?? 0;
        final qty = _quantities[_idFor(item)] ?? 0;
        return sum + price * qty;
      });

  void _changeQty(Map<String, dynamic> item, int delta) {
    setState(() {
      final id = _idFor(item);
      final next = ((_quantities[id] ?? 0) + delta).clamp(0, 20);
      _quantities[id] = next;
    });
  }

  void _confirmReorder(BuildContext context) {
    final cartController = Get.find<NewCartController>();

    for (final item in _items) {
      final qty = _quantities[_idFor(item)] ?? 0;
      if (qty <= 0) continue;

      cartController.addItem(
        NewSpecialtyModel(
          id: _idFor(item),
          name: item['name']?.toString() ?? 'Item',
          introduction: 'Reordered item',
          price: [(item['price'] as num?)?.toInt() ?? 0],
          img: item['img']?.toString() ?? 'assets/image/placeholder.png',
          type: item['type']?.toString() ?? 'General',
          material: item['material']?.toString() ?? 'Standard',
          provider: item['provider']?.toString() ?? 'Unknown Provider',
        ),
        qty,
      );
    }

    Provider.of<HomeViewController>(context, listen: false)
        .onIndependentPageNavigation(context, const CheckoutPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: HeadingStyleText(text: 'Review your reorder', size: Dimensions.font16, weight: FontWeight.w600),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Container(
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
                        text: 'Prices may have changed since this order. Review before confirming — nothing is charged yet.',
                        size: Dimensions.font16 * 0.8,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: PrimaryStyleText(text: 'This order has no items to reorder.', color: Colors.black54),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.black.withOpacity(0.06)),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final qty = _quantities[_idFor(item)] ?? 0;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.height15 * 0.8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HeadingStyleText(
                                      text: item['name']?.toString() ?? 'Item',
                                      size: Dimensions.font16 * 0.95,
                                      weight: FontWeight.w500,
                                    ),
                                    SizedBox(height: 2),
                                    PrimaryStyleText(
                                      text: 'R${item['price'] ?? 0}',
                                      size: Dimensions.font16 * 0.85,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(99)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: qty > 0 ? () => _changeQty(item, -1) : null,
                                      icon: const Icon(Icons.remove_rounded, size: 18),
                                      color: qty > 0 ? Colors.black : Colors.black26,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                    SizedBox(width: 18, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    IconButton(
                                      onPressed: () => _changeQty(item, 1),
                                      icon: const Icon(Icons.add_rounded, size: 18),
                                      color: Colors.black,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(Dimensions.width20, Dimensions.height15, Dimensions.width20, Dimensions.height15),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06)))),
      child: PrimaryBlueButton(
        text: 'Confirm reorder · R$_total',
        onTap: _total > 0 ? () => _confirmReorder(context) : null,
      ),
    );
  }
}
