import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
      ),
      child: Center(
        child: Container(
          width: Dimensions.height20 * 5.4,
          height: Dimensions.height20 * 5.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 1,
                offset: Offset(1, 2),
              ),
              BoxShadow(
                color: Colors.black12,
                blurRadius: 1,
                offset: Offset(0, -1),
              ),
            ],
            border: Border.all(
              width: 2,
              color: Colors.white,
            ),
            color: Colors.white,
          ),
          child: Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Center(
                      child: CircularProgressIndicator(
                    color: const Color(0xffB09B71),
                  )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
