// lib/live/view/cart_view/all_recommendations_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/recommendation_controller.dart';
import 'package:izinto/live/view/cart_view/view_widgets/recommended_service_widget.dart';
import 'package:izinto/live/view/home_view/category_view/service_widget.dart';
import 'package:izinto/live/widgets/generic_header_row.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../auxiliery_classes/generic_app_bar.dart';

class AllRecommendationsPage extends StatelessWidget {
  const AllRecommendationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recommendationController = Get.find<RecommendationController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                GenericAppBar(
                  elevation: 1.5,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  heading: 'Recommendations',
                )
              ],
            ),
            Expanded(
              child: Container(
                height: double.maxFinite,
                child: Padding(
                  padding: EdgeInsets.only(left: 24.0, top: 25.0, right: 24.0),
                  child: Column(
                    children: [
                      SizedBox(height: Dimensions.height20),
                      // In AllRecommendationsPage, add empty state handling
                      Expanded(
                        child: GetBuilder<RecommendationController>(
                          builder: (controller) {
                            final recommendations = controller.recommendations;

                            if (recommendations.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No recommendations available',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 22.0,
                                crossAxisSpacing: Dimensions.width15,
                                childAspectRatio:
                                    0.4, // ✅ Increased from 0.5 to 0.6
                              ),
                              itemCount: recommendations.length,
                              itemBuilder: (context, index) {
                                // ✅ Safe index access
                                if (index >= recommendations.length) {
                                  return Container();
                                }
                                return RecommendedServiceWidget(
                                  index: index,
                                  homeItemList: recommendations,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
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
