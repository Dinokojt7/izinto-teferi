import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../models/new_specialty_model.dart';
import '../../../models/popular_specialty_model.dart';
import '../../../utils/dimensions.dart';
import '../../widgets/text_widgets/small_black_text.dart';
import 'category_view/category_view.dart';
import 'category_view/controller/category_view_controller.dart';

class SpecialtyWidget extends StatefulWidget {
  final int index;
  final List<NewSpecialtyModel> homeItemList;
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // ADD THIS METHOD BACK:
  Widget _buildSkeletonWidget() {
    return Stack(
      children: [
        // Skeleton for text
        Padding(
          padding: EdgeInsets.only(left: 8.0, right: 2.0, bottom: 8.0),
          child: Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        // Skeleton for image
        Positioned(
          top: Dimensions.height45 * 1.2,
          left: 20,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewController>(
      builder: (context, _categoryViewController, child) {
        // Safe index check
        final bool isValidIndex = widget.index < widget.homeItemList.length;

        void _handleTap() {
          if (!isValidIndex || _isLoading) return;

          setState(() {
            _isTapped = true;
          });

          if (isValidIndex) {
            Provider.of<CategoryViewController>(context, listen: false)
                .updateCategoryList(0, 0);
            Provider.of<CategoryViewController>(context, listen: false)
                .updateTabsControllerIndex(
                    widget.homeItemList[widget.index].name!, widget.index);
          }

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
            width: Dimensions.screenWidth / 2,
            height: Dimensions.height45 * 4.2,
            margin: EdgeInsets.only(
              left: Dimensions.width10 / 1.2,
              right: Dimensions.width10 / 1.2,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 0.5,
                  offset: Offset(0, 0.8),
                ),
              ],
              border: Border.all(
                width: 0.5,
                color: Colors.black.withOpacity(0.04),
              ),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              color: _isTapped
                  ? Colors.grey.shade200
                  : (_isLoading ? Colors.grey.shade100 : Colors.white),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                onTap: _isLoading ? null : _handleTap,
                child: _isLoading
                    ? _buildSkeletonWidget()
                    : buildSpecialtyWidget(isValidIndex),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSpecialtyWidget(bool isValidIndex) {
    if (!isValidIndex) {
      return _buildSkeletonWidget(); // AND HERE FOR INVALID INDEX
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
            top: Dimensions.height10 / 3,
            right: 2.0,
            bottom: _getBottomPadding(widget.index),
          ),
          child: SmallBlackText(
            text: itemName,
            size: Dimensions.font16 / 1.3,
          ),
        ),
        Positioned(
          top: _getTopPosition(widget.index),
          child: widget.index == 0
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(6.0, 0.0, 8.0, 12.0),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      letterSpacing: 2,
                      overflow: TextOverflow.visible,
                      fontSize: Dimensions.height20 * 1.8,
                      fontFamily: 'Cabin',
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
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
      case 5:
        return 10.0;
      case 3:
        return 18.0;
      case 4:
        return 12.0;
      default:
        return 0.0;
    }
  }

  double _getImageTopPadding(int index) {
    switch (index) {
      case 5:
      case 3:
        return 12.0;
      case 4:
        return 14.0;
      default:
        return 0.0;
    }
  }

  double _getImageHeight(int? id) {
    switch (id) {
      case 5:
        return 70;
      case 6:
        return 75;
      case 3:
        return 75;
      case 4:
        return 65;
      case 2:
        return 90;
      default:
        return 56;
    }
  }
}
