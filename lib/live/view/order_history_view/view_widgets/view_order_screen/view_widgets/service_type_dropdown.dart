// service_type_dropdown.dart (updated)
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';
import '../../../../../utilities/service_type_utils.dart';

class ServiceTypeDropdown extends StatelessWidget {
  final List<String> serviceTypes;
  final String selectedServiceType;
  final Function(String) onServiceTypeChanged;
  final Map<String, dynamic> order;
  final VoidCallback onViewDetails;
  final VoidCallback onShowServicesDialog; // New callback

  const ServiceTypeDropdown({
    Key? key,
    required this.serviceTypes,
    required this.selectedServiceType,
    required this.onServiceTypeChanged,
    required this.order,
    required this.onViewDetails,
    required this.onShowServicesDialog, // New parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasMultipleTypes = serviceTypes.length > 1;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 0.7,
            offset: Offset(0, 1.7),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Left part - Service Type Selection (Expandable)
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: hasMultipleTypes ? onShowServicesDialog : null,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height15,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Service type image
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Image.asset(
                        ServiceTypeUtils.getServiceTypeImage(
                            selectedServiceType),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.category,
                            size: 16,
                            color: Colors.grey.shade400,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Expanded(
                      child: Text(
                        selectedServiceType,
                        style: TextStyle(
                          fontSize: Dimensions.font16 / 1.3,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasMultipleTypes)
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Right part - View Details Button
          Expanded(
            flex: 1,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onViewDetails,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(Dimensions.radius15),
                  bottomRight: Radius.circular(Dimensions.radius15),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height15,
                  ),
                  child: Center(
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: Dimensions.font16 / 1.3,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
