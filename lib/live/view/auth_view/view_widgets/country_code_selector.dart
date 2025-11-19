import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';

class CountryCodeSelector extends StatefulWidget {
  @override
  _CountryCodeSelectorState createState() => _CountryCodeSelectorState();
}

class _CountryCodeSelectorState extends State<CountryCodeSelector> {
  // Example list of countries with flags and codes
  final List<Map<String, String>> countries = [
    {'name': 'South Africa', 'code': '+27', 'flag': '🇿🇦'},
    {'name': 'Botswana', 'code': '+267', 'flag': '🇧🇼'},
  ];

  String? selectedCountryCode;

  @override
  void initState() {
    super.initState();
    selectedCountryCode = countries[0]['code']; // Default to the first country
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height45 * 1.4,
      padding:
          EdgeInsets.symmetric(horizontal: 16.0, vertical: Dimensions.height10),
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(0.03),
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCountryCode,
          icon: Icon(
            Icons.keyboard_arrow_down_outlined,
            color: Colors.black,
          ),
          onChanged: (String? newValue) {
            setState(() {
              selectedCountryCode = newValue;
            });
          },
          items: countries
              .map<DropdownMenuItem<String>>((Map<String, String> country) {
            return DropdownMenuItem<String>(
              value: country['code'],
              child: Row(
                children: [
                  Text(
                    country['flag']!,
                  ),
                  SizedBox(width: 3.0),
                  Text(
                    country['code']!,
                    style: TextStyle(
                        fontSize: Dimensions.font20 / 1.3,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 1.0),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
