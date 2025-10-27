import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/live/view/home_view/main_address_view.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import '../../../controllers/recommended_specialty_controller.dart';
import '../../../utils/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/big_text.dart';
import '../../../widgets/texts/small_text.dart';
import '../../utilities/colors.dart';
import '../../widgets/text_widgets/big_mallanna.dart';
import 'carousel_with_indicator.dart';

class HomeScreenAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  HomeScreenAppBarDelegate({
    required this.expandedHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final size = Dimensions.screenHeight / 4;
    final top = expandedHeight - shrinkOffset - size * 1.40;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        buildBackground(shrinkOffset),
        buildAppBar(shrinkOffset),
        if (shrinkOffset < expandedHeight - kToolbarHeight - 30)
          Positioned(
            top: top,
            left: Dimensions.width10 * 1.5,
            right: Dimensions.width10 * 1.5,
            child: buildFloating(shrinkOffset),
          ),
      ],
    );
  }

  double appear(double shrinkOffset) {
    const double threshold = 50.0;
    if (shrinkOffset < threshold) {
      return 0.0;
    } else {
      return Curves.easeInOut
          .transform((shrinkOffset - threshold) / (expandedHeight - threshold));
    }
  }

  double disappear(double shrinkOffset) {
    const double threshold = 100.0;
    if (shrinkOffset < threshold) {
      return 1.0;
    } else {
      return Curves.easeInOut.transform(
          1 - (shrinkOffset - threshold) / (expandedHeight - threshold));
    }
  }

  Widget buildFloating(double shrinkOffset) => Opacity(
        opacity: disappear(shrinkOffset),
        child: GetBuilder<RecommendedSpecialtyController>(
            builder: (recommendedSpecialties) {
          return GestureDetector(
            child: CarouselWithIndicator(
              specialties: recommendedSpecialties.recommendedSpecialtyList,
            ),
          );
        }),
      );

  Widget buildBackground(double shrinkOffset) => Opacity(
        opacity: disappear(shrinkOffset).clamp(0.0, 1.0),
        child: SizedBox(
          height: expandedHeight -
              Dimensions.height10, // keep your header height cleanly managed
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              // 🔹 Oversized image that bleeds above & below
              Positioned(
                top: -expandedHeight *
                    0.1, // pushes image upward (adds visible area above)
                bottom: -expandedHeight * 0.1, // extends below too
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/image/wallpaper.png',
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
              ),

              // 🔹 Optional soft gradient fade to white or transparent
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.2, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildAppBar(double shrinkOffset) => Opacity(
        opacity: appear(shrinkOffset).clamp(0.0, 1.0),
        child: AppBar(
          title: shrinkOffset >= expandedHeight - kToolbarHeight - 30
              ? MainAddressView()
              : SizedBox.shrink(),
          centerTitle: true,
        ),
      );

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + Dimensions.height45 * 1.3;
}
