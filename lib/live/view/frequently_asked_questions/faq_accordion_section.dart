// faq_accordion_section.dart
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../../models/support_questions_model.dart';

class FAQAccordionSection extends StatefulWidget {
  final String categoryName;
  final List<QuestionsModel> questions;
  final bool isInitiallyExpanded;

  const FAQAccordionSection({
    super.key,
    required this.categoryName,
    required this.questions,
    this.isInitiallyExpanded = false,
  });

  @override
  State<FAQAccordionSection> createState() => _FAQAccordionSectionState();
}

class _FAQAccordionSectionState extends State<FAQAccordionSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.width15,
        vertical: Dimensions.height10 / 1.8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Category Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatCategoryName(widget.categoryName),
                        style: TextStyle(
                          fontSize: Dimensions.font20 / 1.2,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black.withOpacity(0.7),
                      size: Dimensions.font20 * 1.2,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Questions List
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.only(
                bottom: Dimensions.height15,
                left: Dimensions.width10,
                right: Dimensions.width10,
              ),
              child: Column(
                children: widget.questions.map((question) {
                  return _QuestionItem(question: question);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _formatCategoryName(String name) {
    // Convert "dry-cleaning" to "Dry Cleaning", etc.
    return name.split('-').map((word) {
          if (word.isNotEmpty) {
            return word[0].toUpperCase() + word.substring(1);
          }
          return word;
        }).join(' ') +
        " Related Questions";
  }
}

class _QuestionItem extends StatefulWidget {
  final QuestionsModel question;

  const _QuestionItem({required this.question});

  @override
  State<_QuestionItem> createState() => __QuestionItemState();
}

class __QuestionItemState extends State<_QuestionItem> {
  bool _isQuestionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Dimensions.height10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 0.8),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          // Question Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isQuestionExpanded = !_isQuestionExpanded;
                });
              },
              child: Container(
                padding: EdgeInsets.all(Dimensions.width15 * 0.8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indentation indicator

                    Expanded(
                      child: Text(
                        widget.question.title ?? '',
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.1,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Icon(
                      _isQuestionExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade400,
                      size: Dimensions.font20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Answer
          if (_isQuestionExpanded)
            Container(
              decoration: BoxDecoration(color: Colors.white),
              width: double.infinity,
              padding: EdgeInsets.only(
                left: Dimensions.width15 * 1.5,
                right: Dimensions.width15 * 0.8,
                bottom: Dimensions.height15 * 0.8,
                top: Dimensions.height10 / 2,
              ),
              child: Text(
                widget.question.text ?? '',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.2,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
