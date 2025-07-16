import 'package:flutter/material.dart';

class RiderTipController extends ChangeNotifier {
  List _tipOptions = [
    {'image': 'assets/image/lollipop.png', 'text': 'R10'},
    {'image': 'assets/image/hot-tea.png', 'text': 'R15'},
    {'image': 'assets/image/beer.png', 'text': 'R20'},
    {'image': 'assets/image/mai-thai.png', 'text': 'R25'},
    {'image': 'assets/image/waffle.png', 'text': 'R30'},
    {'image': 'assets/image/pizza.png', 'text': 'R40'},
    {'image': 'assets/image/coffee-bag.png', 'text': 'R50'},
  ];

  List get tipOptions => _tipOptions;
}
