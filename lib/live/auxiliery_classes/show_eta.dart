import 'package:flutter/material.dart';
import 'package:izinto/live/widgets/buttons/highlight_button.dart';

class ShowEta extends StatelessWidget {
  const ShowEta({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HighlightButton(
      text: '15 min',
      isViewing: true,
    );
  }
}
