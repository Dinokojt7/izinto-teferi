import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'miscellaneous/app_icon.dart';

class ApplySubColumn extends StatelessWidget {
  const ApplySubColumn({
    Key? key,
    required this.closeSubView,
  }) : super(key: key);

  final void Function() closeSubView;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: closeSubView,
                child: AppIcon(
                  size: 22,
                  backgroundColor: Color(0xFFCFC5A5),
                  weight: 20,
                  icon: Icons.close,
                  iconColor: Colors.white,
                  iconSize: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
