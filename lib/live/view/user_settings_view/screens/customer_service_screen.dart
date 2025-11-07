// customer_service_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/legal_documents_controller.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/utils/dimensions.dart';

import '../../../auxiliery_classes/generic_app_bar.dart';

class CustomerServiceScreen extends StatefulWidget {
  const CustomerServiceScreen({Key? key}) : super(key: key);

  @override
  State<CustomerServiceScreen> createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LegalDocumentsController>(builder: (documentsController) {
      return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.95),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: Column(
          children: [
            GenericAppBar(
              heading: 'Customer service',
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Container(
                  padding: EdgeInsets.all(Dimensions.width10),
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
                      if (documentsController.contactInfo.email != null)
                        _buildContactItem(
                          Icons.email,
                          'Email',
                          documentsController.contactInfo.email!,
                        ),
                      if (documentsController.contactInfo.phone != null) ...[
                        SizedBox(height: Dimensions.height10),
                        _buildContactItem(
                          Icons.phone,
                          'Phone/WhatsApp',
                          documentsController.contactInfo.phone!,
                        ),
                      ],
                      if (documentsController.contactInfo.supportHours !=
                          null) ...[
                        SizedBox(height: Dimensions.height10),
                        _buildContactItem(
                          Icons.access_time,
                          'Support Hours',
                          documentsController.contactInfo.supportHours!,
                        ),
                      ],
                      if (documentsController.contactInfo.website != null) ...[
                        SizedBox(height: Dimensions.height10),
                        _buildContactItem(
                          Icons.language,
                          'Website',
                          documentsController.contactInfo.website!,
                        ),
                      ],
                      if (documentsController.contactInfo.address != null) ...[
                        SizedBox(height: Dimensions.height10),
                        _buildContactItem(
                          Icons.location_on,
                          'Address',
                          documentsController.contactInfo.address!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: Dimensions.font16 * 1.1,
          color: LiveColors.cartBlue,
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
