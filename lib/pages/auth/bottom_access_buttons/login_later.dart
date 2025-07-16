import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/integers_and_doubles.dart';
import '../../home/home_page.dart';

class LoginLater extends StatelessWidget {
  const LoginLater({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xffCFC5A5),
              Color(0xff9A9483),
            ],
          ),
          border: Border.all(
            width: 1.3,
            color: const Color(0xff9A9483).withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(Dimensions.radius20 * 3),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: Dimensions.width15 / 1.05,
              horizontal: Dimensions.width15 / 1.05),
          child: Center(
            //register
            child: IntegerText(
              text: 'Sign In Later',
              size: Dimensions.font16 / 1.1,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
