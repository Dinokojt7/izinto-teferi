import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';

class MiniCircularProgressIndicator extends StatelessWidget {
  final bool? hasOwnDialog;
  final Color? color;
  const MiniCircularProgressIndicator(
      {Key? key, this.hasOwnDialog = false, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: hasOwnDialog!
            ? Colors.transparent
            : Color(0xff000008).withOpacity(0.55),
        insetPadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Center(
                child: SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularCappedProgressIndicator(
                      //      value: _backgroundAnimation.value,
                      color: color,
                      strokeWidth: 3.0,
                      strokeCap: StrokeCap.round),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
