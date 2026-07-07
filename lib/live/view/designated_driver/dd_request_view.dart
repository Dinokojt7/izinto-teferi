import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/designated_driver/dd_matching_view.dart';
import 'package:izinto/live/widgets/buttons/primary_blue_button.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

/// Designated Driver — request step. No dispatch backend exists yet, so this
/// is a UI-first placeholder: "Request a driver" shows a snackbar rather than
/// starting a real match. Wire to a real dispatch service when one exists.
class DdRequestView extends StatelessWidget {
  const DdRequestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiveColors.primary,
      appBar: AppBar(
        backgroundColor: LiveColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeadingStyleText(
                text: "We'll get you and your car home — safely.",
                size: Dimensions.font26,
                weight: FontWeight.w600,
                color: LiveColors.whiteTextColor,
                height: 1.2,
              ),
              SizedBox(height: Dimensions.height20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Dimensions.width15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _TrustBadge(icon: Icons.verified_user_rounded, label: 'PrDP-licensed'),
                    _TrustBadge(icon: Icons.fact_check_rounded, label: 'Vetted'),
                    _TrustBadge(icon: Icons.shield_rounded, label: 'Insured'),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Dimensions.width20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PrimaryStyleText(
                      text: 'Estimated fare',
                      color: Colors.white70,
                      size: Dimensions.font16 * 0.9,
                    ),
                    HeadingStyleText(
                      text: 'R180 – R220',
                      color: Colors.white,
                      weight: FontWeight.w600,
                      size: Dimensions.font20,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryBlueButton(
                text: 'Request a driver',
                icon: Icons.local_taxi_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DdMatchingView()),
                  );
                },
              ),
              SizedBox(height: Dimensions.height20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
