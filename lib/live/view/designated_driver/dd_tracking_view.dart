import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/buttons/destructive_button.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

/// D3 — driver en route. No real-time dispatch backend yet: driver details
/// and ETA below are placeholders until a live tracking service exists.
class DdTrackingView extends StatelessWidget {
  const DdTrackingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiveColors.primary,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1A1A1A),
              child: const Center(
                child: Icon(Icons.map_rounded, color: Colors.white24, size: 64),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Align(
                alignment: Alignment.topLeft,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.32,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height15),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: Dimensions.height20),
                        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(99)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: LiveColors.accent, borderRadius: BorderRadius.circular(99)),
                      child: Text('Arriving in 4 min',
                          style: TextStyle(color: LiveColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    SizedBox(height: Dimensions.height15),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: LiveColors.primary,
                          child: const Text('SM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(width: Dimensions.width15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HeadingStyleText(text: 'Sipho M.', weight: FontWeight.w600, size: Dimensions.font16),
                              PrimaryStyleText(text: '★ 4.9 · PrDP · 6 yrs driving', size: Dimensions.font16 * 0.8, color: Colors.black54),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: LiveColors.primary,
                          child: const Icon(Icons.call_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                    Divider(height: Dimensions.height30, color: Colors.black.withOpacity(0.08)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: PrimaryStyleText(text: 'Home · 12 Rivonia Rd', weight: FontWeight.w600)),
                        HeadingStyleText(text: 'R195', weight: FontWeight.w600, size: Dimensions.font16),
                      ],
                    ),
                    SizedBox(height: Dimensions.height20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.ios_share_rounded, size: 16),
                            label: Text('Share trip', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black26),
                              padding: EdgeInsets.symmetric(vertical: Dimensions.height15 * 0.8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3)),
                            ),
                          ),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: DestructiveButton(
                            text: 'Safety',
                            icon: Icons.shield_outlined,
                            onTap: () => _showSafetySheet(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSafetySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.ios_share_rounded), title: const Text('Share trip'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.call_rounded), title: const Text('Call driver'), onTap: () => Navigator.pop(context)),
            ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: LiveColors.standardRed),
              title: Text('Emergency', style: TextStyle(color: LiveColors.standardRed)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
