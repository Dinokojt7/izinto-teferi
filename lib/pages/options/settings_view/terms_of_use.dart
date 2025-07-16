import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:izinto/pages/options/settings_view/terms_Panel.dart';
import 'package:izinto/pages/options/settings_view/terms_of_use_text.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';

class TermsOfUse extends StatefulWidget {
  const TermsOfUse({Key? key}) : super(key: key);

  @override
  State<TermsOfUse> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  void _scrollToSection(String section) {
    // Find the position of the section within the text
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double sectionPosition = renderBox
        .localToGlobal(Offset.zero)
        .dy; // Update the logic here based on your text layout and design

    // Scroll to the section with smooth animation
    _scrollController.animateTo(
      sectionPosition,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    void _showTermsPanel(String title, String text) {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20))),
          isScrollControlled: true,
          useSafeArea: true,
          context: context,
          builder: (context) {
            return TermsPanel(title: title, text: text);
          });
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Dimensions.bottomHeightBar,
        elevation: 0.4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: IconThemeData(
          weight: 900,
          color: AppColors.fontColor,
          size: Dimensions.height18 + Dimensions.height18,
        ),
        titleTextStyle: TextStyle(
            fontSize: Dimensions.height18 + Dimensions.height18,
            color: AppColors.fontColor,
            fontWeight: FontWeight.w700),
        title: Text('Terms of use'),
        centerTitle: false,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller:
              _scrollController, // Assign the ScrollController to the SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${TermsText.introHeading}',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.font20),
              ),
              SmallText(
                text: TermsText.intro,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                size: Dimensions.font16,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '\n'),
                    TextSpan(
                      text: '${TermsText.userRepresentationHeading}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(TermsText.userRepresentationHeading,
                              TermsText.userRepresentationText);
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${TermsText.userContent}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(
                              TermsText.userContent, TermsText.userContentText);
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${TermsText.ThirdPartyInteractions}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(TermsText.ThirdPartyInteractions,
                              TermsText.ThirdPartyInteractionsText);
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${TermsText.Indemnification}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(TermsText.Indemnification,
                              TermsText.IndemnificationText);
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${TermsText.DisclaimerOfWarranties}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(TermsText.DisclaimerOfWarranties,
                              TermsText.DisclaimerOfWarrantiesText);
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${TermsText.InternetDelays}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(TermsText.InternetDelays,
                              TermsText.InternetDelaysText);
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${TermsText.LimitationOfLiability}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(TermsText.LimitationOfLiability,
                              TermsText.LimitationOfLiabilityText);
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${TermsText.NonPersonalInformation}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(TermsText.NonPersonalInformation,
                              TermsText.NonPersonalInformationText);
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${TermsText.CreditCartAcquiringAndSecurity}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(
                              TermsText.CreditCartAcquiringAndSecurity,
                              TermsText.CreditCartAcquiringAndSecurityText);
                        },
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${TermsText.Payments}',
                      style: TextStyle(
                          fontSize: Dimensions.font20,
                          color: const Color(0xff966C3B),
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsPanel(
                              TermsText.Payments, TermsText.PaymentsText);
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
