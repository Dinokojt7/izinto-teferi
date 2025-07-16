import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/dimensions.dart';
import 'apply_sub_column.dart';

class ApplySub extends StatelessWidget {
  final void Function(String?)? onSubmitted;
  final void Function() closeSubView;

  ApplySub({Key? key, this.onSubmitted, required this.closeSubView})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                  height: Dimensions.screenHeight / 5.2,
                  color: Colors.transparent),
            ),
            Expanded(
              child: Container(
                height: Dimensions.screenHeight / 5.2,
                color: Colors.transparent,
                child: ApplySubColumn(closeSubView: closeSubView),
              ),
            )
          ],
        ),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Dimensions.height10 / 2),
            height: Dimensions.screenHeight / 5.2,
            width: Dimensions.width30,
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: Dimensions.screenHeight / 15,
                  width: Dimensions.width10 / 11.5,
                  decoration: BoxDecoration(
                    color: Color(0xFFCFC5A5),
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                  ),
                ),
                Icon(
                  Icons.local_laundry_service_outlined,
                  color: Color(0xFFCFC5A5),
                  size: Dimensions.iconSize26 * 1.2,
                ),
                Container(
                  height: Dimensions.screenHeight / 15,
                  width: Dimensions.width10 / 11.5,
                  decoration: BoxDecoration(
                    color: Color(0xFFCFC5A5),
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
