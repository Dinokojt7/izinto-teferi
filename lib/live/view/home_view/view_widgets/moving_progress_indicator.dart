import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';

import '../../../../utils/dimensions.dart';

class MovingProgressIndicator extends StatefulWidget {
  @override
  _MovingProgressIndicatorState createState() =>
      _MovingProgressIndicatorState();
}

class _MovingProgressIndicatorState extends State<MovingProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4), // Total duration
    )..forward(); // Start the animation

    // Repeat the animation if needed
    _controller?.repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6),
      child: SizedBox(
        width: Dimensions.screenWidth / 7,
        child: AnimatedBuilder(
          animation: _controller!,
          builder: (context, child) {
            return LinearCappedProgressIndicator(
              color: LiveColors.primary, backgroundColor: Colors.black26,
              value: _controller!.value, // Use the controller's value
              minHeight: 8,
            );
          },
        ),
      ),
    );
  }
}
