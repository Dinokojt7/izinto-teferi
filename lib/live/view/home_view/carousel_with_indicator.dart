import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:izinto/live/view/home_view/view_widgets/moving_progress_indicator.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../../widgets/texts/big_text.dart';
import '../../../widgets/texts/small_text.dart';
import '../../utilities/colors.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/text_widgets/primary_style_text.dart';
import '../../widgets/text_widgets/big_mallanna.dart';
import '../profile_view/controller/profile_view_controller.dart';
import 'category_view/category_view.dart';
import 'category_view/controller/category_view_controller.dart';
import 'controller/home_view_controller.dart';
import 'main_address_view.dart';

class CarouselWithIndicator extends StatefulWidget {
  final List specialties;

  CarouselWithIndicator({required this.specialties});

  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _currentIndex = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewController>(
        builder: (context, _profileController, child) {
      final String _firstName = _profileController.firstName;

      ///Here's a list of addresses from the controller///
      final List<dynamic> _addresses = _profileController.savedAddresses;

      ///Here's the selection of currently active address///
      var selectedAddresses =
          _addresses.where((address) => address['selected'] == true).toList();

      var _street = '';
      // Iterate over the filtered addresses and use their values
      for (var address in selectedAddresses) {
        _street = address['street'];
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildWelcomeText(_firstName),
          SizedBox(height: Dimensions.height10 / 1.3),
          MainAddressView(),
          SizedBox(height: Dimensions.height30),
          CarouselSlider(
            items: widget.specialties.map((specialties) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      Provider.of<CategoryViewController>(context,
                              listen: false)
                          .updateCategoryList(2, 2);
                      Provider.of<HomeViewController>(context, listen: false)
                          .navigateToNestedWidget(context, CategoryView());
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(specialties.img!),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
            carouselController: _controller,
            options: CarouselOptions(
              height: Dimensions.screenHeight / 4,
              autoPlay: true,
              enlargeCenterPage: false,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          SizedBox(
            height: Dimensions.height10,
          ),
          Row(
            children: [
              DotsIndicator(
                dotsCount: widget.specialties.length > 0
                    ? widget.specialties.length
                    : 1,
                position: _currentIndex.toDouble(),
                decorator: DotsDecorator(
                  activeColor: LiveColors.primary,
                  color: Colors.black26,
                  size: const Size.square(8.5),
                  activeSize: Size(Dimensions.screenWidth / 7, 8),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          // Row(
          //   children: [
          //     MovingProgressIndicator(),
          //   ],
          // ),
          buildHeading(),
        ],
      );
    });
  }

  Widget buildWelcomeText(String firstName) => Padding(
        padding: EdgeInsets.only(
            left: Dimensions.width10,
            right: Dimensions.width10 / 2,
            top: Dimensions.height10 * 11),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: BigMallanna(
                    text1: 'HEY,',
                    text2: firstName != '' ? '$firstName!' : 'Welcome',
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height10),
          ],
        ),
      );

  Widget buildHeading() => Padding(
        padding: EdgeInsets.only(left: 6, top: Dimensions.height45 / 2),
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
}
