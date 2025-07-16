import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ViewTokens extends StatefulWidget {
  const ViewTokens({Key? key}) : super(key: key);

  @override
  State<ViewTokens> createState() => _ViewTokensState();
}

class _ViewTokensState extends State<ViewTokens> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xffA0937D),
            Color(0xff966C3B),
          ],
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Center(
              child: Lottie.asset('assets/image/check.json',
                  controller: _controller, onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward();
              }),
            )
          ],
        ),
      ),
    );
  }
}
