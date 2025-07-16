import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import 'controller/category_view_controller.dart';
import 'material_tabs_container.dart';
import 'material_tabs_header.dart';

class CategoryViewHeaderSection extends StatelessWidget {
  final List specialties;
  final int pageId;

  CategoryViewHeaderSection({required this.specialties, required this.pageId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MaterialTabsHeader(),
        MaterialTabsContainer(categoryPageId: pageId),
      ],
    );
  }
}
