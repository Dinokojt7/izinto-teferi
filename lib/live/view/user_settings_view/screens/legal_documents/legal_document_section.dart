// legal_document_section.dart
import 'package:flutter/material.dart';
import 'package:izinto/models/legal_documents_model.dart';
import 'package:izinto/utils/dimensions.dart';

class LegalDocumentSection extends StatelessWidget {
  final LegalDocumentItem item;
  final int level;
  final int? sectionNumber;

  const LegalDocumentSection({
    super.key,
    required this.item,
    required this.level,
    this.sectionNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: Dimensions.height20,
        left: _getLeftPadding(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          if (item.title != null && item.title!.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: Dimensions.height10),
              child: Text(
                _formatTitle(item.title!),
                style: TextStyle(
                  fontSize: _getTitleFontSize(),
                  fontFamily: 'Poppins',
                  fontWeight: level == 0 ? FontWeight.w700 : FontWeight.w600,
                  color: Colors.black.withOpacity(_getTitleOpacity()),
                  height: 1.3,
                ),
              ),
            ),

          // Section Content
          if (item.content != null && item.content!.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: Dimensions.height15),
              child: Text(
                item.content!,
                style: TextStyle(
                  fontSize: _getContentFontSize(),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _getLeftPadding() {
    switch (level) {
      case 0:
        return 0;
      case 1:
        return Dimensions.width20;
      case 2:
        return Dimensions.width20 * 2;
      default:
        return Dimensions.width20 * 3;
    }
  }

  double _getTitleFontSize() {
    switch (level) {
      case 0:
        return Dimensions.font20 / 1.2;
      case 1:
        return Dimensions.font16 / 1.1;
      case 2:
        return Dimensions.font16 / 1.3;
      default:
        return Dimensions.font16 * 1.2;
    }
  }

  double _getContentFontSize() {
    switch (level) {
      case 0:
        return Dimensions.font16 / 1.2;
      case 1:
        return Dimensions.font16 / 1.03;
      case 2:
        return Dimensions.font16 * 1.1;
      default:
        return Dimensions.font16 / 1.2;
    }
  }

  double _getTitleOpacity() {
    switch (level) {
      case 0:
        return 0.9;
      case 1:
        return 0.8;
      case 2:
        return 0.7;
      default:
        return 0.6;
    }
  }

  String _formatTitle(String title) {
    if (sectionNumber != null && level > 0) {
      // Remove any existing numbers from the title to avoid duplication
      final cleanTitle = title.replaceAll(RegExp(r'^\d+\.\s*'), '');
      return '$sectionNumber. $cleanTitle';
    }
    return title;
  }
}
