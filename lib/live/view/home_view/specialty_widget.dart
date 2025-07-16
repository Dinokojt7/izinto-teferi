import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';

import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../widgets/text_widgets/small_black_text.dart';
import 'category_view/category_view.dart';
import 'category_view/controller/category_view_controller.dart';
import 'category_view/mockup_category_view.dart';

class SpecialtyWidget extends StatefulWidget {
  final int index;
  final List homeItemList;
  final BuildContext context;
  const SpecialtyWidget(
      {Key? key,
      required this.index,
      required this.homeItemList,
      required this.context})
      : super(key: key);

  @override
  State<SpecialtyWidget> createState() => _SpecialtyWidgetState();
}

class _SpecialtyWidgetState extends State<SpecialtyWidget> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewController>(
        builder: (context, _categoryViewController, child) {
      final pageId = _categoryViewController.selectedListIndex;
      void _handleTap() {
        setState(() {
          _isTapped = true;
        });
        Provider.of<CategoryViewController>(context, listen: false)
            .updateCategoryList(1, 1);
        Provider.of<CategoryViewController>(context, listen: false)
            .updateTabsControllerIndex(
                widget.homeItemList[widget.index].name, widget.index);

        Provider.of<HomeViewController>(context, listen: false)
            .navigateToNestedWidget(context, CategoryView()
                // MockupCategoryView(
                //   pageId: pageId,
                );

        // Optional: Reset border visibility after a short delay
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            _isTapped = false;
          });
        });
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
            width: Dimensions.screenWidth / 3,
            height: Dimensions.height45 * 4,
            margin: EdgeInsets.only(
                left: Dimensions.width15, right: Dimensions.width15),
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
                    // splashColor: Colors.purple,
                    // highlightColor: Colors.brown,
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    onTap: _handleTap,
                    child: buildSpecialtyWidget(pageId)))),
      );
    });
  }

  Widget buildSpecialtyWidget(int pageId) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: 8.0,
              right: 2.0,
              bottom: widget.index == 1
                  ? 3
                  : widget.index == 2
                      ? 0
                      : 8.0),
          child: SmallBlackText(
            text: widget.homeItemList[widget.index].name,
          ),
        ),
        Positioned(
          top: widget.index == 0
              ? Dimensions.height45 * 1.5
              : widget.index == 1
                  ? Dimensions.height45 / 1.2
                  : Dimensions.height20,
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
                        left: widget.index == 1
                            ? 5.0
                            : widget.index == 5
                                ? 18.0
                                : widget.index == 3
                                    ? 18.0
                                    : widget.index == 4
                                        ? 18.0
                                        : 0.0,
                        top: widget.index == 5
                            ? 12.0
                            : widget.index == 3
                                ? 12.0
                                : widget.index == 4
                                    ? 14.0
                                    : 0.0,
                        right: 0.0),
                    child: Image(
                      height: widget.homeItemList[widget.index].id == 5
                          ? 70
                          : widget.homeItemList[widget.index].id == 6
                              ? 70
                              : widget.homeItemList[widget.index].id == 3
                                  ? 65
                                  : widget.homeItemList[widget.index].id == 4
                                      ? 65
                                      : widget.homeItemList[widget.index].id ==
                                              2
                                          ? 90
                                          : 56,
                      image: AssetImage(widget.homeItemList[widget.index].img),
                    ),
                  ),
                ),
        )
      ],
    );
  }
}
