import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/controllers/popular_specialty_controller.dart';
import 'package:izinto/live/view/user_settings_view/controller/user_settings_controller.dart';
import 'package:provider/provider.dart';
import '../utilities/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/integers_and_doubles.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({Key? key, required this.title, required this.activeScreen})
      : super(key: key);
  final String title;
  final int activeScreen;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PopularSpecialtyController>(
        builder: (popularSpecialties) {
      return popularSpecialties.isLoaded
          ? Consumer<UserSettingsController>(
              builder: (context, controller, child) {
              var isCurrentActiveTab =
                  controller.currentActiveTab == activeScreen;
              return Container(
                height: Dimensions.height45 / 1.1,
                decoration: BoxDecoration(
                  border: isCurrentActiveTab
                      ? Border.all(
                          width: 1,
                          color: Colors.grey.withOpacity(0.1),
                        )
                      : null,
                  borderRadius: BorderRadius.circular(Dimensions.radius30 * 2),
                  color: isCurrentActiveTab
                      ? LiveColors.accent.withOpacity(0.5)
                      : Colors.transparent,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Dimensions.width10 / 2,
                      horizontal: Dimensions.width10),
                  child: Center(
                    //register
                    child: IntegerText(
                      text: title,
                      size: Dimensions.font16 / 1.1,
                      fontWeight: FontWeight.w600,
                      color: Color(0Xff353839),
                    ),
                  ),
                ),
              );
            })
          : HomeButtonSkeleton(
              text: title,
            );
    });
  }
}

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
