import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/legal_documents_controller.dart';
import 'package:izinto/utils/dimensions.dart';
import '../../../../auxiliery_classes/generic_app_bar.dart';
import '../../../../auxiliery_classes/live_progress_indicator.dart';
import '../../../../utilities/generic_system_navigation.dart';
import 'legal_document_section.dart';

class LegalDocumentScreen extends StatefulWidget {
  final String documentType; // 'terms-of-use', 'privacy-policy', 'imprint'
  final String screenTitle;
  final String description;
  final Color primaryColor;
  final String lastUpdated;

  const LegalDocumentScreen({
    super.key,
    required this.documentType,
    required this.screenTitle,
    required this.description,
    this.primaryColor = Colors.blue,
    this.lastUpdated = 'December 2024',
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late LegalDocumentsController _documentsController;
  bool _initialLoadAttempted = false;

  void _applySystemChromeSettings() {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);
  }

  @override
  void initState() {
    super.initState();
    _documentsController = Get.find<LegalDocumentsController>();

    // Load documents when screen first loads, but only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialLoadAttempted && !_documentsController.isLoaded) {
        _loadDocuments();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.white.withOpacity(0.95),
          Brightness.dark,
          Colors.white,
          Brightness.dark);
    });
  }

  void _handleBackNavigation() {
    _applySystemChromeSettings();
    Navigator.of(context).pop();
  }

  void _loadDocuments() {
    setState(() {
      _initialLoadAttempted = true;
    });
    _documentsController.getLegalDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LegalDocumentsController>(builder: (documentsController) {
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
                          heading: widget.screenTitle,
                          hasMissingProfileData: false,
                        )
                      ],
                    ),
                    Expanded(
                      child: _buildContent(documentsController),
                    ),
                  ],
                ),
              ),
            ),
            if (documentsController.isLoading) LiveProgressIndicator(),
          ],
        ),
      );
    });
  }

  Widget _buildContent(LegalDocumentsController controller) {
    // Show loading state
    if (controller.isLoading) {
      return const SizedBox(); // Progress indicator is shown in the stack
    }

    // Show error state if we attempted to load but failed
    if (_initialLoadAttempted && controller.errorMessage.isNotEmpty) {
      return _buildErrorState(controller);
    }

    // Show content if loaded successfully
    if (controller.isLoaded) {
      return _buildDocumentContent(controller);
    }

    // Initial state - show loading or empty state
    return _buildInitialState();
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: Dimensions.font26 * 2,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            'Ready to Load Document',
            style: TextStyle(
              fontSize: Dimensions.font20 / 1.2,
              fontFamily: 'Poppins',
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            'Tap the button below to load the ${widget.screenTitle}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.1,
              fontFamily: 'Poppins',
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: Dimensions.height30),
          ElevatedButton(
            onPressed: _loadDocuments,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width30 * 1.1,
                vertical: Dimensions.height15 * 1.1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius15),
              ),
            ),
            child: Text(
              'Load Document',
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

  Widget _buildErrorState(LegalDocumentsController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
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
              'Unable to Load Document',
              style: TextStyle(
                fontSize: Dimensions.font20 / 1.2,
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
                fontSize: Dimensions.font16 / 1.1,
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: Dimensions.height30),
            ElevatedButton(
              onPressed: _loadDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width30 * 1.1,
                  vertical: Dimensions.height15 * 1.1,
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
      ),
    );
  }

  Widget _buildDocumentContent(LegalDocumentsController controller) {
    final document = controller.getDocumentByType(widget.documentType);

    if (document == null || document.items == null || document.items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: Dimensions.font26 * 2,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              '${widget.screenTitle} Not Available',
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                fontSize: Dimensions.font16 / 1.1,
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: Dimensions.height30),
            ElevatedButton(
              onPressed: _loadDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width30 * 1.1,
                  vertical: Dimensions.height15 * 1.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
              ),
              child: Text(
                'Reload',
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimensions.width20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeaderSection(),

          // Last Updated Info
          _buildLastUpdatedInfo(),

          // Document Content
          ...document.items!.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return LegalDocumentSection(
              item: item,
              level: 0,
              sectionNumber: index + 1,
            );
          }).toList(),

          SizedBox(height: Dimensions.height20 * 2),

          // Contact Footer
          _buildContactFooter(controller),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Dimensions.height10),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.3,
              fontFamily: 'Poppins',
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedInfo() {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height20),
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: widget.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radius20 / 2),
        border: Border.all(
          color: widget.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            size: Dimensions.font20,
            color: widget.primaryColor,
          ),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Updated',
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.1,
                    fontFamily: 'Poppins',
                    color: widget.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 2),
                Text(
                  widget.lastUpdated,
                  style: TextStyle(
                    fontSize: Dimensions.font16 / 1.1,
                    fontFamily: 'Poppins',
                    color: widget.primaryColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactFooter(LegalDocumentsController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need Help?',
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.1,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            'If you have any questions, please contact our support team:',
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.2,
              fontFamily: 'Poppins',
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          SizedBox(height: Dimensions.height15),
          if (controller.contactInfo.email != null)
            _buildContactItem(
              Icons.email,
              'Email',
              controller.contactInfo.email!,
            ),
          if (controller.contactInfo.phone != null) ...[
            SizedBox(height: Dimensions.height10),
            _buildContactItem(
              Icons.phone,
              'Phone/WhatsApp',
              controller.contactInfo.phone!,
            ),
          ],
          if (controller.contactInfo.supportHours != null) ...[
            SizedBox(height: Dimensions.height10),
            _buildContactItem(
              Icons.access_time,
              'Support Hours',
              controller.contactInfo.supportHours!,
            ),
          ],
          if (controller.contactInfo.website != null) ...[
            SizedBox(height: Dimensions.height10),
            _buildContactItem(
              Icons.language,
              'Website',
              controller.contactInfo.website!,
            ),
          ],
          if (controller.contactInfo.address != null) ...[
            SizedBox(height: Dimensions.height10),
            _buildContactItem(
              Icons.location_on,
              'Address',
              controller.contactInfo.address!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: Dimensions.font16 * 1.1,
          color: widget.primaryColor,
        ),
        SizedBox(width: Dimensions.width15 / 1.2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.2,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height20 / 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontFamily: 'Poppins',
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
