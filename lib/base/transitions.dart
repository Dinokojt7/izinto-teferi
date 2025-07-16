import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../routes/route_helper.dart';

class Transition extends StatefulWidget {
  //final Widget page;
  const Transition({Key? key}) : super(key: key);

  @override
  State<Transition> createState() => _TransitionState();
}

class _TransitionState extends State<Transition> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  late Widget page;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    Timer(
        const Duration(seconds: 3),
        () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => page,
              ),
            ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
