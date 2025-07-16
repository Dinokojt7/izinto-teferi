import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';

class LiveProgressIndicator extends StatefulWidget {
  final bool? hasOwnDialog;
  final Color? color;
  const LiveProgressIndicator({Key? key, this.hasOwnDialog = false, this.color})
      : super(key: key);

  @override
  State<LiveProgressIndicator> createState() => _LiveProgressIndicatorState();
}

class _LiveProgressIndicatorState extends State<LiveProgressIndicator>
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
    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: widget.hasOwnDialog!
            ? Colors.transparent
            : Color(0xff000008).withOpacity(0.55),
        insetPadding: EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background (slower, black)
                    SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: Transform.rotate(
                        angle:
                            _secondController.value * 2.0 * 3.14159, // 2 * pi
                        child: CircularCappedProgressIndicator(
                            //      value: _backgroundAnimation.value,
                            color: Colors.white,
                            strokeWidth: 6.0,
                            strokeCap: StrokeCap.round),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: Transform.rotate(
                        angle: _controller.value * 1.8 * 3.14159, // 2 * pi
                        child: CircularCappedProgressIndicator(
                            //   value: _foregroundAnimation.value,
                            color: Colors.black.withOpacity(0.1),
                            strokeWidth: 6.0,
                            strokeCap: StrokeCap.round),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: Transform.rotate(
                        angle:
                            _secondController.value * 1.5 * 3.14159, // 2 * pi
                        child: CircularCappedProgressIndicator(
                            //   value: _foregroundAnimation.value,
                            color: Colors.black.withOpacity(0.1),
                            strokeWidth: 6.0,
                            strokeCap: StrokeCap.round),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: Transform.rotate(
                        angle: _controller.value * 0.9 * 3.14159, // 2 * pi
                        child: CircularCappedProgressIndicator(
                            //   value: _foregroundAnimation.value,
                            color: Colors.black.withOpacity(0.1),
                            strokeWidth: 6.0,
                            strokeCap: StrokeCap.round),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: Transform.rotate(
                        angle:
                            _secondController.value * 0.7 * 3.14159, // 2 * pi
                        child: CircularCappedProgressIndicator(
                            //   value: _foregroundAnimation.value,
                            color: widget.color ?? Colors.white,
                            strokeWidth: 6.0,
                            strokeCap: StrokeCap.round),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
