import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';

class PlaceNotSupported extends StatelessWidget {
  const PlaceNotSupported({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Icon(
          Icons.arrow_back,
          size: Dimensions.iconSize26 * 1.6,
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'We\'re currently not available at\n',
                    style: TextStyle(
                      color: Colors.black87.withOpacity(0.9),
                      fontSize: Dimensions.font26 / 1.1,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.40,
                      height: 1.3,
                    ),
                  ),
                  TextSpan(
                    text: 'your selected location\n\n',
                    style: TextStyle(
                      color: Colors.black87.withOpacity(0.9),
                      fontSize: Dimensions.font26 / 1.1,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.40,
                      height: 1.4,
                    ),
                  ),
                  TextSpan(
                    text: 'Try using a different address instead.\n\n',
                    style: TextStyle(
                      color: Colors.black87.withOpacity(0.8),
                      fontSize: Dimensions.font16 / 1.2,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.10,
                      height: 1.3,
                    ),
                  ),
                  TextSpan(
                    text: 'You can also view areas that we service.\n\n',
                    style: TextStyle(
                      color: Colors.black87.withOpacity(0.8),
                      fontSize: Dimensions.font16 / 1.2,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.10,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: Dimensions.height20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: Dimensions.screenHeight / 13,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xffA0937D),
                        Color(0xffA0937D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: Center(
                    child: IntegerText(
                      text: 'TRY AGAIN',
                      size: Dimensions.font20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
