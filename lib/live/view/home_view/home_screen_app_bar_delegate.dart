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
          return CarouselWithIndicator(
            specialties: recommendedSpecialties.recommendedSpecialtyList,
          );
        }),
      );

  Widget buildHeading() => Padding(
        padding: EdgeInsets.only(
            left: 6, top: Dimensions.height45 / 2, bottom: Dimensions.height10),
        child: Row(
          children: [
            PrimaryStyleText(
              family: 'Poppins',
              text: 'Popular',
              weight: FontWeight.w600,
            ),
            SizedBox(
              width: Dimensions.width10,
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 3),
              child: BigText(
                text: '.',
                color: Colors.black26,
                weight: FontWeight.w700,
              ),
            ),
            SizedBox(
              width: Dimensions.width10,
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 1),
              child: SmallText(
                family: 'Poppins',
                text: 'Services',
                maxLines: 1,
              ),
            )
          ],
        ),
      );

  Widget buildBackground(double shrinkOffset) => Opacity(
        opacity: disappear(shrinkOffset).clamp(0.0, 1.0),
        child: Container(
          height: expandedHeight * 1.5,
          child: Image.asset(
            'assets/image/wallpaper.png',
            width: double.maxFinite,
            fit: BoxFit.cover,
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
