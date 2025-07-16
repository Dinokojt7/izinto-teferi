import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';

class MainAddress extends StatelessWidget {
  const MainAddress({
    super.key,
    required String street,
  }) : _street = street;

  final String _street;

  @override
  Widget build(BuildContext context) {
    return PrimaryStyleText(
      text: _street,
      height: 1.9,
      overFlow: TextOverflow.ellipsis,
    );
  }
}
