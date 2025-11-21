
import 'package:flutter/material.dart';

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
