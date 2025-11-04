import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';

class LiveProgressIndicator extends StatefulWidget {
  final bool? hasOwnDialog;
  final Color? color;
  final double size;
  const LiveProgressIndicator({
    Key? key,
    this.hasOwnDialog = false,
    this.color,
    this.size = 30.0,
  }) : super(key: key);

  @override
  State<LiveProgressIndicator> createState() => _LiveProgressIndicatorState();
}

class _LiveProgressIndicatorState extends State<LiveProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000), // Faster speed (was 1500)
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Container(
          width: Dimensions.screenWidth,
          height: Dimensions.screenHeight,
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _FadeTailProgressPainter(
                    progress: _controller.value,
                    color: widget.color ?? Colors.white,
                    strokeWidth: 6.0,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeTailProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _FadeTailProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        size.width / 2 - strokeWidth / 3; // Was /1.4, now /3 for bigger radius
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Strong front tip with nice fade at the end
    final gradient = SweepGradient(
      colors: [
        color.withValues(alpha: 0.1), // Back tip fade
        color.withValues(alpha: 0.5), // Quick transition
        color, // Long white section starts
        color, // Long white section continues
        color.withValues(alpha: 0.5), // Quick transition
        color.withValues(alpha: 0.1), // Front tip fade
      ],
      stops: [
        0.0,
        0.1,
        0.3,
        0.7,
        0.9,
        1.0
      ], // More space for white, less for fade
      // Clockwise rotation
      transform: GradientRotation(progress * 2 * 3.14159),
    );

    paint.shader = gradient.createShader(rect);

    // Continuous clockwise motion with good arc length
    final arcLength = 2.0; // Slightly shorter arc for better fade visibility
    final startAngle = progress * 2 * 3.14159;

    canvas.drawArc(
      rect,
      startAngle,
      arcLength,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
