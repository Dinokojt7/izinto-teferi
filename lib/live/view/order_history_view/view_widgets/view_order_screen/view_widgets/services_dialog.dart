// services_dialog.dart
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

class ServicesDialog extends StatelessWidget {
  final bool isDialogOpen;
  final List<String> serviceTypes;
  final Function(String) onServiceTypeSelected;
  final VoidCallback onClose;

  const ServicesDialog({
    Key? key,
    required this.isDialogOpen,
    required this.serviceTypes,
    required this.onServiceTypeSelected,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: isDialogOpen ? 180.0 : -300,
      left: Dimensions.width20,
      right: Dimensions.width20,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 250),
        opacity: isDialogOpen ? 1.0 : 0.0,
        child: Material(
          elevation: 2.0,
          borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 3,
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(Dimensions.width15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your order services',
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.4,
                  color: Colors.grey.shade400,
                  height: 1,
                ),
                // Service Type Options
                ...serviceTypes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final serviceType = entry.value;
                  return Column(
                    children: [
                      ServiceTypeListTile(
                        serviceType: serviceType,
                        onTap: () => onServiceTypeSelected(serviceType),
                      ),
                      if (index < serviceTypes.length - 1)
                        Divider(
                          thickness: 0.4,
                          color: Colors.grey.shade300,
                          height: 1,
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceTypeListTile extends StatelessWidget {
  final String serviceType;
  final VoidCallback onTap;

  const ServiceTypeListTile({
    Key? key,
    required this.serviceType,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _getServiceTypeImage(serviceType),
      ),
      title: Text(
        serviceType,
        style: TextStyle(
          fontSize: Dimensions.font16 / 1.2,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Dimensions.width15 / 2,
        vertical: Dimensions.height10 / 2,
      ),
    );
  }

  Widget _getServiceTypeImage(String serviceType) {
    String imagePath;
    switch (serviceType) {
      case 'Gas Refill':
        imagePath = 'assets/image/gas.png';
        break;
      case 'Laundry':
        imagePath = 'assets/image/laundry.png';
        break;
      case 'Home Care':
        imagePath = 'assets/image/home_care.png';
        break;
      case 'Pet Care':
        imagePath = 'assets/image/pet_care.png';
        break;
      case 'Car Wash':
        imagePath = 'assets/image/car_wash.png';
        break;
      default:
        imagePath = 'assets/wash-carpet.png';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.category,
            size: 20,
            color: Colors.grey.shade400,
          );
        },
      ),
    );
  }
}
