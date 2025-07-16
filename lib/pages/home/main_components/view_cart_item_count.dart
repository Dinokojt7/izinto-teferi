import 'package:flutter/material.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';

class ViewCartItemCount extends StatefulWidget {
  const ViewCartItemCount({
    super.key,
    required this.totalItemCount,
  });
  final int totalItemCount;

  @override
  State<ViewCartItemCount> createState() => _ViewCartItemCountState();
}

class _ViewCartItemCountState extends State<ViewCartItemCount> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.transparent,
        onPressed: () {},
        child: Stack(
          children: [
            Image(
              image: AssetImage('assets/image/drop.png'),
              height: Dimensions.height30 * 1.7,
              //color: AppColors.secondary,
            ),
            Positioned(
              left: widget.totalItemCount == 1
                  ? 18
                  : widget.totalItemCount > 10
                      ? 15
                      : 17,
              top: 15,
              child: IntegerText(
                text: widget.totalItemCount.toString(),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                size: Dimensions.font16 / 1.1,
              ),
            )
          ],
        ),
      );
    });
  }
}
