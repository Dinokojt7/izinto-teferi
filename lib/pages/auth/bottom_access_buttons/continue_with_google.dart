import 'package:flutter/material.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';

import '../../../services/firebase_auth_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/big_text.dart';

class ContinueWithGoogle extends StatelessWidget {
  const ContinueWithGoogle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuthMethods().signInWithGoogle(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 1.3,
            color: Colors.grey.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(Dimensions.radius20 * 3),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: Dimensions.width15 / 1.05,
              horizontal: Dimensions.width15 / 1.2),
          child: Row(
            children: [
              Image(
                image: const AssetImage('assets/image/g.png'),
                width: Dimensions.height20 * 1.6,
              ),
              SizedBox(
                width: Dimensions.width10,
              ),
              Center(
                //register
                child: IntegerText(
                  text: 'Google Sign In',
                  size: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fontColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
