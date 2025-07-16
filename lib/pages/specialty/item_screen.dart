import 'package:flutter/material.dart';
import '../../live/widgets/text_widgets/big_text.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/integers_and_doubles.dart';

class ItemScreen extends StatefulWidget {
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin:
          EdgeInsets.only(left: Dimensions.width20, right: Dimensions.width20),
      child: Column(
        children: [
          SizedBox(
            height: Dimensions.height15,
          ),
          Stack(
            children: [
              Container(
                height: Dimensions.screenHeight / 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.fontColor.withOpacity(0.2),
                      const Color(0xff9A9483),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        //color: AppColors.fontColor.withOpacity(0.1),
                        padding: EdgeInsets.only(
                            left: Dimensions.width20 * 1.5,
                            top: Dimensions.width20 / 1.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntegerText(
                              text: '25% OFF',
                              fontWeight: FontWeight.w600,
                              color: AppColors.buttonBackgroundColor,
                              size: Dimensions.font26 / 1.2,
                            ),
                            SizedBox(
                              height: Dimensions.width10 / 1.4,
                            ),
                            IntegerText(
                              text: 'First dry cleaning order',
                              fontWeight: FontWeight.w500,
                              color: AppColors.buttonBackgroundColor,
                              size: Dimensions.font16 / 1.2,
                            ),
                            SizedBox(
                              height: Dimensions.width10 / 1,
                            ),
                            Container(
                              height: Dimensions.height45 / 1.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radius30 * 2),
                                border: Border.all(
                                  width: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Dimensions.width10 / 2,
                                  horizontal: Dimensions.width10,
                                ),
                                child: IntegerText(
                                  text: 'USE CODE',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.buttonBackgroundColor,
                                  size: Dimensions.font16 / 1.12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        //color: Colors.blue,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: -20,
                              right: -10,
                              child: Container(
                                width: Dimensions.height30 * 5,
                                height: Dimensions.height30 * 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        Dimensions.radius30 * 6),
                                    topRight: Radius.circular(
                                        Dimensions.radius30 * 1.8),
                                  ),
                                  color: Colors.white.withOpacity(0.09),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -20,
                              left: -2,
                              child: Container(
                                width: Dimensions.height30 * 5,
                                height: Dimensions.height30 * 5,
                                child: Image(
                                    image: AssetImage('assets/image/dry.png')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: Dimensions.screenHeight / 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: Dimensions.height30 / 1,
                              width: Dimensions.width15,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomRight:
                                      Radius.circular(Dimensions.radius15 * 10),
                                  topRight:
                                      Radius.circular(Dimensions.radius15 * 10),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: Dimensions.height30 / 1,
                              width: Dimensions.width15,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft:
                                      Radius.circular(Dimensions.radius15 * 10),
                                  topLeft:
                                      Radius.circular(Dimensions.radius15 * 10),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: Dimensions.height20,
          ),
        ],
      ),
    );
  }
}

class LaundryBucketSize extends StatefulWidget {
  const LaundryBucketSize({Key? key}) : super(key: key);

  @override
  State<LaundryBucketSize> createState() => _LaundryBucketSizeState();
}

class _LaundryBucketSizeState extends State<LaundryBucketSize> {
  int selectedSize = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height45 / 1.1,
      decoration: BoxDecoration(
        color: Color(0xff9A9483).withOpacity(0.5),
        borderRadius: BorderRadius.circular(Dimensions.radius30 * 2),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedSize = 0;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.linear,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
              height: Dimensions.height45 / 1.1,
              decoration: BoxDecoration(
                color: selectedSize == 0 ? Color(0xff9A9483) : null,
                borderRadius: BorderRadius.circular(Dimensions.radius30 * 2),
              ),
              child: BigText(
                text: 'Large',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedSize = 1;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.linear,
              height: Dimensions.height45 / 1.1,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
              decoration: BoxDecoration(
                color: selectedSize == 1 ? Color(0xff9A9483) : null,
                borderRadius: BorderRadius.circular(Dimensions.radius30 * 2),
              ),
              child: BigText(
                text: 'Small',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LaundryBucketCount extends StatefulWidget {
  const LaundryBucketCount({Key? key}) : super(key: key);

  @override
  State<LaundryBucketCount> createState() => _LaundryBucketCountState();
}

class _LaundryBucketCountState extends State<LaundryBucketCount> {
  int totalCarSelection = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.screenWidth / 7,
      padding: EdgeInsets.only(
          left: Dimensions.width10 / 2, right: Dimensions.width10 / 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
              width: 1, color: const Color(0xff9A9483).withOpacity(0.8)),
          color: Colors.white),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          focusColor: Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          dropdownColor: Colors.white,
          value: totalCarSelection ?? 1,
          onChanged: (int? newValue) {
            setState(() {
              totalCarSelection = newValue!;
            });
          },
          items: <int>[
            1,
            2,
            3,
            4,
            5,
            6,
          ].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              onTap: () {
                setState(() {
                  totalCarSelection = value;
                });
              },
              value: value,
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: Dimensions.font16 / 1.05,
                  color: Color(0xFF5c524f),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
