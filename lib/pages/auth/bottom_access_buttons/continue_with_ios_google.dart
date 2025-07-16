import 'package:flutter/material.dart';

import '../../../services/firebase_auth_methods.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/big_text.dart';

class ContinueWithIosAndGoogle extends StatelessWidget {
  const ContinueWithIosAndGoogle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Dimensions.bottomHeightBar / 1.2,
        padding: EdgeInsets.only(
          top: Dimensions.height10,
          bottom: Dimensions.height10,
        ),
        decoration: BoxDecoration(
          border:
              Border.all(width: 1, color: Color(0xff966C3B).withOpacity(0.2)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radius20 * 2),
            topRight: Radius.circular(Dimensions.radius20 * 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await FirebaseAuthMethods().signInWithGoogle(context);
                },
                child: Container(
                  height: Dimensions.bottomHeightBar,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        height: Dimensions.height45 / 1.2,
                        image: AssetImage('assets/image/a.png'),
                      ),
                      SizedBox(
                        width: Dimensions.width20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: BigText(
                          size: Dimensions.font20,
                          color: Color(0Xff353839),
                          weight: FontWeight.w500,
                          text: 'Apple',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            VerticalDivider(color: Color(0xff9A9483).withOpacity(0.7)),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await FirebaseAuthMethods().signInWithGoogle(context);
                },
                child: Container(
                  height: Dimensions.bottomHeightBar,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        height: Dimensions.height45 / 1.2,
                        image: AssetImage('assets/image/g.png'),
                      ),
                      SizedBox(
                        width: Dimensions.width20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: BigText(
                          size: Dimensions.font20,
                          color: Color(0Xff353839),
                          weight: FontWeight.w500,
                          text: 'Google',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
