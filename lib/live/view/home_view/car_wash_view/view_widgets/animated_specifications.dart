import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:provider/provider.dart';
import 'package:izinto/live/view/home_view/car_wash_view/view_widgets/specification_column.dart';
import 'package:izinto/live/view/home_view/car_wash_view/controller/car_wash_controller.dart';

class AnimatedSpecifications extends StatefulWidget {
  @override
  _AnimatedSpecificationsState createState() => _AnimatedSpecificationsState();
}

class _AnimatedSpecificationsState extends State<AnimatedSpecifications>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarWashController>(
      builder: (carWashController) {
        final includedItems = carWashController
            .washTypes[carWashController.washTypeIndex]['included'];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final listLength =
                      includedItems.length < 4 ? includedItems.length : 3;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(listLength, (index) {
                      final spec = includedItems[index];

                      return Transform.translate(
                        offset:
                            Offset(_controller.value * (index - 0) * 100, 0),
                        child: Hero(
                          tag: spec['text'],
                          transitionOnUserGestures: true,
                          child: SpecificationColumn(
                            text: spec['text'],
                            image: spec['image'],
                            backgroundColor: Color(
                                spec['color']), // FIX: Convert int to Color
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
