// safe_pet_care_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/pet_care_specialty_controller.dart';

class SafePetCareWidget extends StatefulWidget {
  final Widget Function(PetCareSpecialtyController) builder;

  const SafePetCareWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<SafePetCareWidget> createState() => _SafePetCareWidgetState();
}

class _SafePetCareWidgetState extends State<SafePetCareWidget> {
  late final PetCareSpecialtyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PetCareSpecialtyController>();
  }

  @override
  void dispose() {
    // Ensure controller is properly disposed if needed
    // Note: GetX usually handles this automatically, but we add safety
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PetCareSpecialtyController>(
      init: _controller,
      builder: (controller) {
        return widget.builder(controller);
      },
    );
  }
}
