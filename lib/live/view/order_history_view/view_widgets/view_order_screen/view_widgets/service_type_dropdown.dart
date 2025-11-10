// service_type_dropdown.dart
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';
import '../../../../../utilities/service_type_utils.dart';

class ServiceTypeDropdown extends StatefulWidget {
  final List<String> serviceTypes;
  final String selectedServiceType;
  final Function(String) onServiceTypeChanged;
  final Map<String, dynamic> order;
  final VoidCallback onViewDetails;

  const ServiceTypeDropdown({
    Key? key,
    required this.serviceTypes,
    required this.selectedServiceType,
    required this.onServiceTypeChanged,
    required this.order,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  State<ServiceTypeDropdown> createState() => _ServiceTypeDropdownState();
}

class _ServiceTypeDropdownState extends State<ServiceTypeDropdown> {
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final hasMultipleTypes = widget.serviceTypes.length > 1;

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
              onTap: hasMultipleTypes ? _showServiceTypeDialog : null,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height15 / 2,
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Image.asset(
                        ServiceTypeUtils.getServiceTypeImage(
                            widget.selectedServiceType),
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
                        widget.selectedServiceType,
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
                        _isDropdownOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
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
                onTap: widget.onViewDetails,
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

  void _showServiceTypeDialog() {
    if (widget.serviceTypes.length <= 1) return;

    setState(() {
      _isDropdownOpen = true;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: Dimensions.height10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              child: Text(
                'Select Service Type',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.2,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            ...widget.serviceTypes
                .map((serviceType) => ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Image.asset(
                          ServiceTypeUtils.getServiceTypeImage(serviceType),
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        serviceType,
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      trailing: widget.selectedServiceType == serviceType
                          ? Icon(Icons.check, color: Colors.black)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onServiceTypeChanged(serviceType);
                        setState(() {
                          _isDropdownOpen = false;
                        });
                      },
                    ))
                .toList(),
            SizedBox(height: Dimensions.height20),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        _isDropdownOpen = false;
      });
    });
  }
}
