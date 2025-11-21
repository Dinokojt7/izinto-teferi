// lib/live/view/favorites_view/favorites_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/favorite_controller.dart';
import 'package:izinto/live/view/favourites_view/view_widgets/favourite_item_view.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:izinto/live/widgets/generic_header_row.dart';
import 'package:izinto/live/widgets/generic_center_dialog.dart';
import 'package:izinto/live/widgets/no_user_page.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../widgets/texts/small_text.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../widgets/buttons/blue_text_button.dart';
import '../../widgets/text_widgets/heading_style_text.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    // Handle no user case
    if (user == null) {
      return NoUserPage(
        title: 'Favorites',
        message: 'Log in to see your favorites.',
        isSettingView: false,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.97),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: GetBuilder<FavoriteController>(
        builder: (favoriteController) {
          try {
            final favorites = favoriteController.getFavoriteItems();
            final favoritesCount = favoriteController.favoritesCount;

            return Column(
              children: [
                // App Bar
                GenericAppBar(
                  heading: 'Favorites',
                  removeLeading: true,
                ),

                // Content based on favorites availability
                Expanded(
                  child: _buildFavoritesContent(
                    context,
                    favorites,
                    favoritesCount,
                    favoriteController,
                  ),
                ),
              ],
            );
          } catch (e) {

            return _buildErrorView();
          }
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Column(
      children: [
        GenericAppBar(
          heading: 'Favorites',
          removeLeading: true,
        ),
        Expanded(
          child: GenericCenterDialog(
            emoji: '\u{1F914}',
            heading: 'Something went wrong',
            description:
                'There was an error loading your favorites. Please try again.',
            buttonText: 'Try Again',
            callBack: () {
              Get.find<FavoriteController>().update();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesContent(
    BuildContext context,
    List<dynamic> favorites,
    int favoritesCount,
    FavoriteController favoriteController,
  ) {
    final _homeViewController =
        Provider.of<HomeViewController>(context, listen: false);

    if (favorites.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(
            top: Dimensions.height30, bottom: Dimensions.height20),
        child: GenericCenterDialog(
          emoji: '\u{1F9E1}',
          heading: 'No favorites yet',
          description:
              'Tap the heart icon on any service to add it to your favorites and easily find it later.',
          buttonText: 'Browse services',
          callBack: () {
            _homeViewController.changeIndex(0, false);
          },
        ),
      );
    }

    // Show favorites list as individual items
    return Column(
      children: [
        // Header section
        _buildHeadingSection(context, favoritesCount, favoriteController),
        SizedBox(height: Dimensions.height10),

        // Favorites list with error boundary
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height10,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              try {
                final item = favorites[index];
                if (item == null) {
                  return _buildErrorItem(index);
                }
                return FavoriteItemView(
                  item: item,
                  index: index,
                );
              } catch (e) {

                return _buildErrorItem(index);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorItem(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height10),
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.orange),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: Text(
              'Unable to load favorite item ${index + 1}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadingSection(
    BuildContext context,
    int favoritesCount,
    FavoriteController favoriteController,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimensions.width20,
        top: Dimensions.height20,
        right: Dimensions.width20,
      ),
      child: GenericHeaderRow(
        headingChild: Row(
          children: [
            HeadingStyleText(
              text: 'Favourite items',
              weight: FontWeight.w600,
            ),
            SizedBox(width: Dimensions.width10),
            SmallText(
              height: 1.5,
              color: Colors.black,
              size: Dimensions.font16 / 1.5,
              text: '$favoritesCount ${favoritesCount != 1 ? 'items' : 'item'}',
            ),
          ],
        ),
        actionButtonChild: BlueTextButton(
          text: 'Remove all',
          onTap: () {
            favoriteController.clearFavoritesData(
              context,
              'Remove all favorites?',
              'Remove All',
              true,
              null,
              null,
            );
          },
        ),
      ),
    );
  }
}
