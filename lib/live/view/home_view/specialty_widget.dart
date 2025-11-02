import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../models/popular_specialty_model.dart';
import '../../../utils/dimensions.dart';
import '../../widgets/text_widgets/small_black_text.dart';
import 'category_view/category_view.dart';
import 'category_view/controller/category_view_controller.dart';

class SpecialtyWidget extends StatefulWidget {
  final int index;
  final List<SpecialtyModel> homeItemList;
  final BuildContext context;

  const SpecialtyWidget({
    Key? key,
    required this.index,
    required this.homeItemList,
    required this.context,
  }) : super(key: key);

  @override
  State<SpecialtyWidget> createState() => _SpecialtyWidgetState();
}

class _SpecialtyWidgetState extends State<SpecialtyWidget> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewController>(
      builder: (context, _categoryViewController, child) {
        // SAFETY CHECK: Ensure index is valid
        final bool isValidIndex = widget.index < widget.homeItemList.length;

        if (!isValidIndex) {
          return Container(); // Return empty container if invalid index
        }

        void _handleTap() {
          setState(() {
            _isTapped = true;
          });

          Provider.of<CategoryViewController>(context, listen: false)
              .updateCategoryList(1, 1);

          Provider.of<CategoryViewController>(context, listen: false)
              .updateTabsControllerIndex(
                  widget.homeItemList[widget.index].name ?? "Unnamed",
                  widget.index);

          Provider.of<HomeViewController>(context, listen: false)
              .navigateToNestedWidget(context, CategoryView());

          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _isTapped = false;
              });
            }
          });
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            width: Dimensions.screenWidth / 2.5,
            height: Dimensions.height45 * 4,
            margin: EdgeInsets.only(
              left: Dimensions.width15 / 2,
              right: Dimensions.width15 / 2,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 0.5,
                  offset: Offset(0, 0.8),
                ),
              ],
              border: Border.all(
                width: 0.5,
                color: Colors.black.withOpacity(0.04),
              ),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              color: _isTapped ? Colors.grey.shade200 : Colors.white,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                onTap: _handleTap,
                child: buildSpecialtyWidget(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSpecialtyWidget() {
    // SAFETY CHECK again
    if (widget.index >= widget.homeItemList.length) {
      return Center(child: Text('Error'));
    }

    final item = widget.homeItemList[widget.index];
    final itemName = item.name ?? "Unnamed";
    final itemImage = item.img ?? 'assets/image/placeholder.png';
    final itemId = item.id ?? 0;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 8.0,
            right: 2.0,
            bottom: _getBottomPadding(widget.index),
          ),
          child: SmallBlackText(text: itemName),
        ),
        Positioned(
          top: _getTopPosition(widget.index),
          child: widget.index == 0
              ? Text(
                  'NEW',
                  style: TextStyle(
                    letterSpacing: 2,
                    overflow: TextOverflow.visible,
                    fontSize: Dimensions.height20 * 2.2,
                    fontFamily: 'Cabin',
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: _getLeftPadding(widget.index),
                      top: _getImageTopPadding(widget.index),
                      right: 0.0,
                    ),
                    child: Image(
                      height: _getImageHeight(itemId),
                      image: AssetImage(itemImage),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.error_outline, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
        )
      ],
    );
  }

  // Helper methods
  double _getBottomPadding(int index) {
    switch (index) {
      case 1:
        return 3;
      case 2:
        return 0;
      default:
        return 8.0;
    }
  }

  double _getTopPosition(int index) {
    switch (index) {
      case 0:
        return Dimensions.height45 * 1.5;
      case 1:
        return Dimensions.height45 / 1.2;
      default:
        return Dimensions.height20;
    }
  }

  double _getLeftPadding(int index) {
    switch (index) {
      case 1:
        return 5.0;
      case 3:
      case 4:
      case 5:
        return 14.0;
      default:
        return 0.0;
    }
  }

  double _getImageTopPadding(int index) {
    switch (index) {
      case 3:
      case 5:
        return 12.0;
      case 4:
        return 14.0;
      default:
        return 0.0;
    }
  }

  double _getImageHeight(int id) {
    switch (id) {
      case 2:
        return 90;
      case 3:
      case 4:
        return 65;
      case 5:
      case 6:
        return 70;
      default:
        return 56;
    }
  }
}
