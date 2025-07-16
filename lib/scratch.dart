import 'package:flutter/material.dart';
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
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarWashController>(
      builder: (context, carWashController, child) {
        // Get the currently selected wash type's included items
        final List<Map<String, dynamic>> includedItems = carWashController
            .washTypes[carWashController.washTypeIndex]['included'];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  var listLength =
                      includedItems.length < 4 ? includedItems.length : 3;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(listLength, (index) {
                      final spec = includedItems[index];
                      final delayFactor =
                          index * 0.2; // Stagger delay for each item

                      // Delay the animation for each item
                      return Transform.translate(
                        offset:
                            Offset(_controller.value * (index - 0) * 100, 0),
                        child: Hero(
                          tag: spec['text'],
                          transitionOnUserGestures: true,
                          child: SpecificationColumn(
                            text: spec['text'],
                            image: spec['image'],
                            backgroundColor: spec['color'],
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
