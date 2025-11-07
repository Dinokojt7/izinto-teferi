import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/laundry_support_questions_controller.dart';
import 'package:izinto/utils/dimensions.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../auxiliery_classes/live_progress_indicator.dart';
import '../../utilities/generic_system_navigation.dart';
import 'faq_accordion_section.dart';

class FrequentlyAskedQuestions extends StatefulWidget {
  const FrequentlyAskedQuestions({Key? key}) : super(key: key);

  @override
  State<FrequentlyAskedQuestions> createState() =>
      _FrequentlyAskedQuestionsState();
}

class _FrequentlyAskedQuestionsState extends State<FrequentlyAskedQuestions> {
  void _applySystemChromeSettings() {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);
  }

  void _handleBackNavigation() {
    _applySystemChromeSettings();
    Navigator.of(context).pop();
  }

  void _retryLoading() {
    Get.find<LaundrySupportQuestionsController>().getLaundrySupportQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LaundrySupportQuestionsController>(
        builder: (questionsController) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            final focus = FocusScope.of(context);
            if (!focus.hasPrimaryFocus && focus.focusedChild != null) {
              focus.unfocus();
              return;
            }
            _handleBackNavigation();
          } else {
            _applySystemChromeSettings();
          }
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white.withOpacity(0.97),
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
                          onTap: _handleBackNavigation,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          heading: 'FAQ',
                          hasMissingProfileData: false,
                        )
                      ],
                    ),
                    Expanded(
                      child: _buildContent(questionsController),
                    ),
                  ],
                ),
              ),
            ),
            if (!questionsController.isLoaded &&
                questionsController.errorMessage.isEmpty)
              LiveProgressIndicator(),
          ],
        ),
      );
    });
  }

  Widget _buildContent(LaundrySupportQuestionsController controller) {
    if (!controller.isLoaded && controller.errorMessage.isEmpty) {
      return const SizedBox(); // Progress indicator is shown in stack
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Dimensions.font26 * 2,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Failed to load questions',
              style: TextStyle(
                fontSize: Dimensions.font20,
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: Dimensions.height30),
            ElevatedButton(
              onPressed: _retryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width30,
                  vertical: Dimensions.height15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildQuestionsList(controller);
  }

  Widget _buildQuestionsList(LaundrySupportQuestionsController controller) {
    if (controller.laundrySupportCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.question_answer_outlined,
              size: Dimensions.font26 * 2,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'No questions available',
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        top: Dimensions.height20,
        bottom: Dimensions.height20 * 1.3,
      ),
      itemCount: controller.laundrySupportCategories.length,
      itemBuilder: (context, index) {
        final category = controller.laundrySupportCategories[index];
        return FAQAccordionSection(
          categoryName: category.categoryName ?? 'Uncategorized',
          questions: category.questions ?? [],
          isInitiallyExpanded: false,
        );
      },
    );
  }
}
