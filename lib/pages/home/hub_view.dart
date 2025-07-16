import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/pages/car_specialty/car_specialty_detail.dart';

import '../../routes/route_helper.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/big_text.dart';
import '../../widgets/texts/small_text.dart';

class HubView extends StatelessWidget {
  const HubView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        width: double.maxFinite,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  // border: Border(
                  //   bottom: BorderSide(color: Theme.of(context).dividerColor),
                  // ),
                  ),
              width: double.maxFinite,
              padding: EdgeInsets.only(top: Dimensions.height20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BigText(
                      size: Dimensions.height18 + Dimensions.height18,
                      text: 'Services',
                      color: const Color(0Xff353839),
                      weight: FontWeight.w600,
                    ),
                    SizedBox(
                      width: Dimensions.width10,
                    ),
                    const Divider(
                      color: Colors.black26,
                      height: 20,
                    ),
                    SizedBox(
                      width: Dimensions.width30,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Select a service for an On-Demand experience',
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.04,
                          fontFamily: 'Hind',
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CarSpecialtyDetail()));
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 6, color: Colors.white),
                                      boxShadow: [
                                        BoxShadow(
                                          spreadRadius: 0,
                                          blurRadius: 1,
                                          color: Color(0xff39A9483),
                                        ),
                                      ],
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        scale: 1.3,
                                        opacity: 0.9,
                                        fit: BoxFit.contain,
                                        image:
                                            AssetImage('assets/image/car-wash'
                                                '.png'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: Dimensions.screenWidth / 30,
                              ),
                              SmallText(
                                text: 'Car Wash',
                                color: Color(0xff39A9483),
                                fontWeight: FontWeight.w900,
                                size: Dimensions.font16,
                                height: 1.4,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),

                    //sign up page
                  ],
                ),
              ),
            ),
            //Second row
          ],
        ),
      )),
    );
  }
}
