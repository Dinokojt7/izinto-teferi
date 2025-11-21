import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';

// Update ListTileLabel to accept onTap
class ListTileLabel extends StatelessWidget {
  final String imagePath;
  final String description;
  final int index;
  final VoidCallback? onTap;

  const ListTileLabel({
    Key? key,
    required this.imagePath,
    required this.description,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width15,
            vertical: Dimensions.height20,
          ),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 24,
                height: 24,
                color: Colors.black,
              ),
              SizedBox(width: Dimensions.width15),
              Text(
                description,
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
