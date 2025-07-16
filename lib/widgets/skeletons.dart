import 'package:flutter/material.dart';

import '../utils/dimensions.dart';

//Main skeleton design
class Skeleton extends StatelessWidget {
  Skeleton({
    Key? key,
    this.height,
    this.width,
    required this.color,
    this.margin,
    this.child,
    this.radiusGeometry,
  }) : super(key: key);

  final double? height, width;
  final Color color;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  BorderRadiusGeometry? radiusGeometry =
      BorderRadius.circular(Dimensions.radius20);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      child: child,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius:
            radiusGeometry ?? BorderRadius.circular(Dimensions.radius20),
      ),
      padding: const EdgeInsets.all(8),
    );
  }
}

//Car skeleton
class CarSkeleton extends StatelessWidget {
  const CarSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Skeleton(
            height: Dimensions.pageView / 1.4,
            color: Colors.black.withOpacity(0.04),
          ),
        ),
      ],
    );
  }
}

//Popular skeleton
class PopularSkeleton extends StatelessWidget {
  const PopularSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              Skeleton(
                width: 90,
                height: 15,
                color: Colors.black.withOpacity(0.04),
              ),
              SizedBox(
                width: Dimensions.width10,
              ),
              Skeleton(
                width: 90,
                height: 15,
                color: Colors.black.withOpacity(0.04),
              ),
            ],
          ),
          SizedBox(
            height: Dimensions.height20,
          ),
          Row(
            children: [
              Skeleton(
                width: Dimensions.screenWidth / 3.8,
                height: Dimensions.screenHeight / 8,
                color: Colors.black.withOpacity(0.04),
              ),
              SizedBox(
                width: 10,
              ),
              Skeleton(
                width: Dimensions.screenWidth / 3.8,
                height: Dimensions.screenHeight / 8,
                color: Colors.black.withOpacity(0.04),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//Laundry skeleton
class LaundrySkeleton extends StatelessWidget {
  const LaundrySkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: Dimensions.width10,
            top: Dimensions.height15,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: Dimensions.width20,
                  ),
                  Skeleton(
                    width: 70,
                    height: 15,
                    color: Colors.black.withOpacity(0.04),
                  ),
                  SizedBox(
                    width: Dimensions.width10 / 2,
                  ),
                  Skeleton(
                    width: 90,
                    height: 15,
                    color: Colors.black.withOpacity(0.04),
                  ),
                ],
              ),
              SizedBox(
                height: Dimensions.height20,
              ),
              Container(
                color: Colors.transparent,
                height: Dimensions.screenWidth / 1.3,
                width: Dimensions.screenWidth / 1.0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return Skeleton(
                        margin: EdgeInsets.only(
                            left: Dimensions.width15,
                            right: Dimensions.width15),
                        width: Dimensions.height20 * 12,
                        height: Dimensions.height20 * 14.6,
                        color: Colors.black.withOpacity(0.04),
                      );
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//Recommended skeleton
class RecommendedSkeleton extends StatelessWidget {
  const RecommendedSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Skeleton(
        height: Dimensions.pageView / 1.4,
        color: Colors.black.withOpacity(0.04),
      ),
    );
  }
}

//HomeButton skeleton
class HomeButtonSkeleton extends StatelessWidget {
  final String text;
  const HomeButtonSkeleton({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      radiusGeometry: BorderRadius.circular(Dimensions.radius30 * 2),
      height: Dimensions.height45 / 1.1,
      color: Colors.black.withOpacity(0.04),
      child: Center(
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewCartSkeleton extends StatelessWidget {
  const ViewCartSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      color: Colors.black.withOpacity(0.05),
      height: Dimensions.height45 / 1.1,
      width: Dimensions.height45 / 1.1,
    );
  }
}

class AppColumnSkeleton extends StatelessWidget {
  const AppColumnSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      color: Colors.black.withOpacity(0.04),
      width: Dimensions.height45 * 1.52,
      height: Dimensions.height45 * 1.4,
    );
  }
}

class TuneIconSkeleton extends StatelessWidget {
  const TuneIconSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      radiusGeometry: BorderRadius.circular(Dimensions.radius30 * 2),
      height: Dimensions.height20 / 1.1,
      width: Dimensions.height20 / 1.1,
      color: Colors.black.withOpacity(0.04),
    );
  }
}

class StreetTextSkeleton extends StatelessWidget {
  const StreetTextSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      width: 93,
      height: 10,
      color: Colors.black.withOpacity(0.04),
    );
  }
}

class AddressTextSkeleton extends StatelessWidget {
  const AddressTextSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      width: 90,
      height: 10,
      color: Colors.black.withOpacity(0.04),
    );
  }
}
