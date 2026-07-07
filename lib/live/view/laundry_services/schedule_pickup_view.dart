import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/checkout_view/checkout_page.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/view/laundry_services/bag_tier_data.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/widgets/buttons/primary_blue_button.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/models/new_specialty_model.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:provider/provider.dart';

class SchedulePickupView extends StatefulWidget {
  final BagTier bagTier;
  final String washType;
  final Map<int, int> addonQuantities;

  const SchedulePickupView({
    Key? key,
    required this.bagTier,
    required this.washType,
    required this.addonQuantities,
  }) : super(key: key);

  @override
  State<SchedulePickupView> createState() => _SchedulePickupViewState();
}

class _SchedulePickupViewState extends State<SchedulePickupView> {
  static const _days = ['Today', 'Thu', 'Fri', 'Sat'];
  static const _windows = ['8am – 10am', '2pm – 4pm', '5pm – 7pm'];
  int _dayIndex = 0;
  int _windowIndex = 1;

  int get _addonsTotal => kLaundryAddons.fold(
      0, (sum, item) => sum + item.price * (widget.addonQuantities[item.id] ?? 0));
  static const int _serviceFee = 25;
  int get _total => widget.bagTier.price + _addonsTotal + _serviceFee;

  void _confirmPickup(BuildContext context) {
    final cartController = Get.find<NewCartController>();

    cartController.addItem(
      NewSpecialtyModel(
        id: int.parse(widget.bagTier.id.replaceAll(RegExp(r'[^0-9]'), '')) + 90000,
        name: '${widget.bagTier.title} · ${widget.washType}',
        introduction: '${widget.bagTier.weightKg}kg pay-by-the-bag laundry',
        price: [widget.bagTier.price],
        img: widget.bagTier.image,
        type: 'Laundry',
        material: 'Bag tier',
        provider: 'Laundry Services',
      ),
      1,
    );

    for (final item in kLaundryAddons) {
      final qty = widget.addonQuantities[item.id] ?? 0;
      if (qty > 0) {
        cartController.addItem(
          NewSpecialtyModel(
            id: item.id,
            name: item.name,
            introduction: 'Specialty laundry item',
            price: [item.price],
            img: 'assets/image/laundry-care.png',
            type: 'Laundry',
            material: 'Specialty',
            provider: 'Laundry Services',
          ),
          qty,
        );
      }
    }

    Provider.of<CheckoutViewController>(context, listen: false)
        .updateDeliveryNote('Laundry pickup: ${_days[_dayIndex]} · ${_windows[_windowIndex]}');

    Provider.of<HomeViewController>(context, listen: false)
        .onIndependentPageNavigation(context, const CheckoutPage());
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Provider.of<ProfileViewController>(context);
    final selected = profileController.savedAddresses
        .where((a) => a['selected'] == true)
        .toList();
    final addressLabel = selected.isNotEmpty
        ? '${selected.first['street'] ?? ''}, ${selected.first['suburb'] ?? ''}'
        : 'Add a pickup address';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: HeadingStyleText(text: 'Schedule pickup', size: Dimensions.font16, weight: FontWeight.w600),
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
                    _buildAddressCard(addressLabel),
                    SizedBox(height: Dimensions.height20),
                    _sectionLabel('PICKUP DAY'),
                    SizedBox(height: Dimensions.height10),
                    _buildChipRow(_days, _dayIndex, (i) => setState(() => _dayIndex = i)),
                    SizedBox(height: Dimensions.height20),
                    _sectionLabel('TIME WINDOW'),
                    SizedBox(height: Dimensions.height10),
                    _buildChipRow(_windows, _windowIndex, (i) => setState(() => _windowIndex = i)),
                    SizedBox(height: Dimensions.height20),
                    _buildSummaryCard(),
                    SizedBox(height: Dimensions.height20),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => PrimaryStyleText(
        text: text,
        size: Dimensions.font16 * 0.7,
        weight: FontWeight.w700,
        color: Colors.black45,
      );

  Widget _buildAddressCard(String label) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Colors.black54),
          SizedBox(width: Dimensions.width10),
          Expanded(child: PrimaryStyleText(text: label, weight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChipRow(List<String> options, int selectedIndex, ValueChanged<int> onSelect) {
    return Wrap(
      spacing: Dimensions.width10,
      runSpacing: Dimensions.height10,
      children: List.generate(options.length, (i) {
        final selected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width15, vertical: Dimensions.height10 * 0.7),
            decoration: BoxDecoration(
              color: selected ? LiveColors.primary : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              options[i],
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                fontSize: Dimensions.font16 * 0.85,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      child: Column(
        children: [
          _summaryRow(widget.bagTier.title, 'R${widget.bagTier.price}'),
          if (_addonsTotal > 0) _summaryRow('Specialty add-ons', 'R$_addonsTotal'),
          _summaryRow('Service fee', 'R$_serviceFee'),
          Divider(color: Colors.black.withOpacity(0.08)),
          _summaryRow('Total', 'R$_total', bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10 * 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PrimaryStyleText(text: label, weight: bold ? FontWeight.w700 : FontWeight.w500),
          HeadingStyleText(text: value, weight: FontWeight.w600, size: bold ? Dimensions.font20 * 0.8 : Dimensions.font16 * 0.9),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width20, Dimensions.height15, Dimensions.width20, Dimensions.height15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: PrimaryBlueButton(
        text: 'Confirm pickup · R$_total',
        onTap: () => _confirmPickup(context),
      ),
    );
  }
}
