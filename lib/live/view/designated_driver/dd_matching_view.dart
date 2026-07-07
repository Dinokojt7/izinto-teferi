import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/designated_driver/dd_tracking_view.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

/// D2 — matching. No real dispatch backend exists yet, so this auto-advances
/// to tracking after a short delay, same honesty level as the design mockup.
class DdMatchingView extends StatefulWidget {
  const DdMatchingView({Key? key}) : super(key: key);

  @override
  State<DdMatchingView> createState() => _DdMatchingViewState();
}

class _DdMatchingViewState extends State<DdMatchingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DdTrackingView()),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiveColors.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      _pulseRing(_pulseController.value),
                      _pulseRing((_pulseController.value + 0.5) % 1.0),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: LiveColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.airline_seat_recline_normal_rounded,
                            color: LiveColors.primary, size: 34),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: Dimensions.height30),
            HeadingStyleText(
              text: 'Finding your driver',
              size: Dimensions.font26 * 0.85,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
            SizedBox(height: Dimensions.height10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width30 * 1.2),
              child: PrimaryStyleText(
                text: "We're matching you with the nearest vetted driver. Stay where you are — we'll tell you the moment they're on the way.",
                align: TextAlign.center,
                size: Dimensions.font16 * 0.85,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
            SizedBox(height: Dimensions.height30),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel request',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pulseRing(double t) {
    final scale = 0.5 + (t * 1.9);
    final opacity = (1 - t).clamp(0.0, 1.0) * 0.6;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: LiveColors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
