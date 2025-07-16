import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class TermsOfUsePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  void _scrollToSection(int section) {
    final String text = _controller.text;
    final int index = text.indexOf('Section $section\n');
    if (index != -1) {
      final TextPosition position =
          _controller.selection.extentOffset > index + 1
              ? TextPosition(offset: index + 1)
              : TextPosition(offset: index);
      _controller.selection = TextSelection.fromPosition(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextSpan _text = TextSpan(
      text: 'This is some markup text with sections to navigate to.\n\n',
      children: [
        TextSpan(
          text: 'Section 1\n',
          recognizer: TapGestureRecognizer()..onTap = () => _scrollToSection(1),
        ),
        TextSpan(
          text: 'Section 2\n',
          recognizer: TapGestureRecognizer()..onTap = () => _scrollToSection(2),
        ),
        TextSpan(
          text: 'Section 3\n',
          recognizer: TapGestureRecognizer()..onTap = () => _scrollToSection(3),
        ),
      ],
    );
    return Scaffold(
      body: NavigationToolbar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _scrollToSection(1),
              child: Text('Section 1'),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () => _scrollToSection(2),
              child: Text('Section 2'),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () => _scrollToSection(3),
              child: Text('Section 3'),
            ),
          ],
        ),
      ),
    );
  }
}
