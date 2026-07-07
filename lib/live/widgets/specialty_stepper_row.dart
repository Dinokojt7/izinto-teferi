import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/models/new_specialty_model.dart';
import 'package:izinto/utils/dimensions.dart';

/// A single specialty item row with a quantity stepper — reused by the Gas
/// Delivery and Pet Grooming screens, both of which are a flat list of
/// specialty items priced individually (no bag-tier equivalent for these).
class SpecialtyStepperRow extends StatelessWidget {
  final NewSpecialtyModel specialty;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  const SpecialtyStepperRow({
    Key? key,
    required this.specialty,
    required this.quantity,
    required this.onIncrement,
    this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height15 * 0.8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radius15 * 0.7),
            child: Image.asset(
              specialty.img ?? 'assets/image/placeholder.png',
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 54,
                height: 54,
                color: const Color(0xFFF0F0F0),
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.black26),
              ),
            ),
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadingStyleText(
                  text: specialty.displayName,
                  size: Dimensions.font16 * 0.95,
                  weight: FontWeight.w500,
                  maxLines: 2,
                ),
                SizedBox(height: 2),
                PrimaryStyleText(text: 'R${specialty.actualPrice}', size: Dimensions.font16 * 0.85, color: Colors.black54),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(99)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove_rounded, size: 18),
                  color: onDecrement != null ? Colors.black : Colors.black26,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                SizedBox(width: 18, child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  color: Colors.black,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
