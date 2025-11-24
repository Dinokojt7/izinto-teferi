import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';
import '../../../auxiliery_classes/generic_app_bar.dart';
import '../../../utilities/generic_system_navigation.dart';

class ServiceAreas extends StatefulWidget {
  const ServiceAreas({Key? key}) : super(key: key);

  @override
  State<ServiceAreas> createState() => _ServiceAreasState();
}

class _ServiceAreasState extends State<ServiceAreas> {
  // List of all service areas with corrected names
  final List<String> _serviceAreas = const [
    'Fourways',
    'Olive Dale',
    'Douglasdale',
    'North Riding',
    'Kyalami',
    'Waterfall',
    'Lonehill',
    'Paulshof',
    'Sunninghill',
    'Rivonia',
    'Buccleuch',
    'Woodmead',
    'Sandton',
    'Alexandra',
    'Lethabong',
    'Parkmore',
    'Rosebank',
    'Houghton',
    'Cresta',
    'Randburg',
    'Parkhurst',
    'Parkview',
    'Parktown',
    'Braamfontein',
    'Auckland Park',
    'Melville',
    'Westdene',
    'Edenvale',
    'East Gate',
    'Orchards',
    'Linksfield',
    'Orange Grove',
    'Kensington',
    'Ormonde',
    'Robertsham',
    'Turffontein',
    'Rosettenville'
  ];

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.white.withOpacity(0.95),
          Brightness.dark,
          Colors.white,
          Brightness.dark);
    });
  }

  void _onTap() {
    //  _applySystemChromeSettings();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.97),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Stack(
              children: [
                GenericAppBar(
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  heading: 'Service Areas',
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(left: 24.0, top: 25.0, right: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Information Section
                      _buildServiceInfoSection(),
                      SizedBox(
                          height: Dimensions.height20), // Service Areas Section
                      _buildServiceAreasSection(),
                      SizedBox(height: Dimensions.height30),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildServiceAreasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Service Areas',
          style: TextStyle(
            fontSize: Dimensions.font20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
        ),
        SizedBox(height: Dimensions.height20),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.width15),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We currently service the following areas in Johannesburg:',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.2,
                  color: Colors.grey.shade700,
                  fontFamily: 'Poppins',
                  height: 1.4,
                ),
              ),
              SizedBox(height: Dimensions.height15),

              // Areas Grid
              Wrap(
                spacing: Dimensions.width10,
                runSpacing: Dimensions.height10,
                children: _serviceAreas.map((area) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width15 / 1.2,
                      vertical: Dimensions.height10 / 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      area,
                      style: TextStyle(
                        fontSize: Dimensions.font16 / 1.2,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfoSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: Dimensions.iconSize16,
              ),
              SizedBox(width: Dimensions.width10),
              Text(
                'Service Coverage',
                style: TextStyle(
                  fontSize: Dimensions.font16 / 1.1,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            'We provide comprehensive laundry, home care, and gas services across all listed areas. '
            'Our radius covers major suburbs in Johannesburg North and surrounding regions. '
            'Service availability may vary based on specific location within each area.',
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.3,
              color: Colors.grey.shade700,
              fontFamily: 'Poppins',
              height: 1.4,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
