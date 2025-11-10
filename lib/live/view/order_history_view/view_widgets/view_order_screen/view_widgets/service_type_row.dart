// service_type_row.dart
import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';
import '../../../../../utilities/service_type_utils.dart';

class ServiceTypeRow extends StatelessWidget {
  final List<dynamic> items;
  final VoidCallback onTap;
  final String status;
  final bool isLoading;

  const ServiceTypeRow({
    Key? key,
    required this.items,
    required this.onTap,
    required this.isLoading,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serviceTypes = _getAllServiceTypes();
    final displayText = serviceTypes.join(', ');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Image stack
        Container(
          height: 60,
          width: 60,
          child: Stack(
            children: _buildServiceTypeImages(serviceTypes),
          ),
        ),

        // Service types text
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: Dimensions.font16 / 1.3,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // View Button
        status != 'cancelled'
            ? Container(
                height: Dimensions.height30 * 1.3,
                width: Dimensions.width30 * 3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radius15 * 1.3),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLoading ? null : onTap,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radius15 * 1.3),
                    splashColor: Colors.white.withOpacity(0.3),
                    highlightColor: Colors.white.withOpacity(0.2),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'View',
                              style: TextStyle(
                                fontSize: Dimensions.font16 / 1.3,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  List<String> _getAllServiceTypes() {
    final Set<String> serviceTypes = {};

    for (final item in items) {
      final provider = item['provider']?.toString();
      final serviceType = ServiceTypeUtils.getServiceTypeFromProvider(provider);
      serviceTypes.add(serviceType);
    }

    return serviceTypes.toList();
  }

  List<Widget> _buildServiceTypeImages(List<String> serviceTypes) {
    final List<Widget> stackedWidgets = [];
    final int displayCount = serviceTypes.length > 3 ? 3 : serviceTypes.length;

    for (int i = 0; i < displayCount; i++) {
      final serviceType = serviceTypes[i];
      final imagePath = ServiceTypeUtils.getServiceTypeImage(serviceType);
      final double offset = i * 15.0;

      stackedWidgets.add(
        Positioned(
          left: offset,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: ClipRRect(
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
            ),
          ),
        ),
      );
    }

    return stackedWidgets;
  }
}
