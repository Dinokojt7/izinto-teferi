import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';

class SaveButtonLoader extends StatefulWidget {
  const SaveButtonLoader({Key? key}) : super(key: key);

  @override
  State<SaveButtonLoader> createState() => _SaveButtonLoaderState();
}

class _SaveButtonLoaderState extends State<SaveButtonLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _secondController;
  late Animation<double> _foregroundAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for both progress bars
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _secondController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    // Fast animation for the foreground (white) indicator
    _foregroundAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.linear),
        reverseCurve: Interval(0.0, 0.6, curve: Curves.linear),
      ),
    );

    // Slower animation for the background (black) indicator
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.linear),
      ),
    );

    // Start the animations
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background (slower, black)
        SizedBox(
          width: 20.0,
          height: 20.0,
          child: Transform.rotate(
            angle: _secondController.value * 2.0 * 3.14159, // 2 * pi
            child: CircularCappedProgressIndicator(
                //      value: _backgroundAnimation.value,
                color: Colors.white,
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round),
          ),
        ),
        SizedBox(
          width: 20.0,
          height: 20.0,
          child: Transform.rotate(
            angle: _controller.value * 1.8 * 3.14159, // 2 * pi
            child: CircularCappedProgressIndicator(
                //   value: _foregroundAnimation.value,
                color: Colors.black.withOpacity(0.1),
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round),
          ),
        ),
        SizedBox(
          width: 20.0,
          height: 20.0,
          child: Transform.rotate(
            angle: _secondController.value * 1.5 * 3.14159, // 2 * pi
            child: CircularCappedProgressIndicator(
                //   value: _foregroundAnimation.value,
                color: Colors.black.withOpacity(0.1),
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round),
          ),
        ),
        SizedBox(
          width: 20.0,
          height: 20.0,
          child: Transform.rotate(
            angle: _controller.value * 0.9 * 3.14159, // 2 * pi
            child: CircularCappedProgressIndicator(
                //   value: _foregroundAnimation.value,
                color: Colors.black.withOpacity(0.1),
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round),
          ),
        ),
        SizedBox(
          width: 20.0,
          height: 20.0,
          child: Transform.rotate(
            angle: _secondController.value * 0.7 * 3.14159, // 2 * pi
            child: CircularCappedProgressIndicator(
                //   value: _foregroundAnimation.value,
                color: Colors.white,
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round),
          ),
        ),
      ],
    );
  }
}
