import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

class FlutterAnalogClock extends StatefulWidget {
  final DateTime? dateTime;
  final double? borderWidth;
  final double width;
  final double height;
  final BoxDecoration decoration;
  final Widget? child;

  const FlutterAnalogClock({
    this.dateTime,
    this.borderWidth,
    this.width = double.infinity,
    this.height = double.infinity,
    this.decoration = const BoxDecoration(),
    this.child,
  });

  @override
  _FlutterAnalogClockState createState() =>
      _FlutterAnalogClockState(this.dateTime);
}

class _FlutterAnalogClockState extends State<FlutterAnalogClock> {
  late Timer _timer;
  DateTime? _dateTime;
  _FlutterAnalogClockState(this._dateTime);

  @override
  void initState() {
    super.initState();
    this._dateTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _dateTime = _dateTime?.add(Duration(seconds: 1));
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: widget.decoration,
      child: CustomPaint(
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
