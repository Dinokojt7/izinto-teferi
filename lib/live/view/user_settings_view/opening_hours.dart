import 'package:flutter/material.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../widgets/buttons/blue_text_button.dart';
import '../../widgets/generic_header_row.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../address_view/controller/address_dropdown_controller.dart';
import '../address_view/saved_addresses.dart';
import '../checkout_view/view_widgets/checkout_page_address.dart';
import '../checkout_view/view_widgets/generic_white_container.dart';
import '../home_view/controller/home_view_controller.dart';
import '../profile_view/controller/profile_view_controller.dart';

class OpeningHours extends StatefulWidget {
  const OpeningHours({Key? key}) : super(key: key);

  @override
  State<OpeningHours> createState() => _OpeningHoursState();
}

class _OpeningHoursState extends State<OpeningHours> {
  Future<void> _loadGuestAddress() async {
    final addressController = context.read<MainAddressViewController>();
    await addressController.loadGuestAddressFromLocalStorage();

    if (await addressController.hasGuestAddress()) {
      // Force a rebuild after loading the address
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    _loadGuestAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    return Consumer<MainAddressViewController>(
        builder: (context, addressViewController, child) {
      // Also consume ProfileViewController for user addresses
      return Consumer<ProfileViewController>(
          builder: (context, _profileController, child) {
        /// Here's a list of addresses from the controller
        final List<dynamic> _addresses = _profileController.savedAddresses;

        /// Here's the selection of currently active address///
        var selectedAddresses =
            _addresses.where((address) => address['selected'] == true).toList();

        String street = '';
        String suburb = '';
        String zip = '';

        if (user != null && selectedAddresses.isNotEmpty) {
          street = selectedAddresses.first['street'] ?? '';
          street = selectedAddresses.first['suburb'] ?? '';
          street = selectedAddresses.first['zip'] ?? '';
        } else if (addressViewController.hasData) {
          street = addressViewController.street;
          street = addressViewController.suburb;
          street = addressViewController.zipCode;
        } else {
          street = 'Rivonia Blvd & Mutual Rd';
        }

        return Scaffold(
          backgroundColor: Colors.white.withOpacity(0.97),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
          ),
          body: SafeArea(
            child: Column(
              children: [
                GenericAppBar(
                  heading: 'Opening hours',
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 24.0, top: 25.0, right: 24.0),
                      child: Column(
                        children: [
                          GenericHeaderRow(
                            headingChild: HeadingStyleText(
                              text: 'Location',
                              weight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: Dimensions.height15 / 1.2,
                          ),
                          // Fixed address container with proper overflow handling
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(Dimensions.width15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(Dimensions.radius15)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Address text with flexible constraints
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: Dimensions.width10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            street,
                                            style: TextStyle(
                                              fontSize: Dimensions.font16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Poppins',
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            suburb,
                                            style: TextStyle(
                                              fontSize: Dimensions.font16 / 1.1,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey.shade700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (zip.isNotEmpty)
                                          Text(
                                            zip,
                                            style: TextStyle(
                                              fontSize: Dimensions.font16 / 1.1,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey.shade700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Change button with fixed width
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Dimensions.height45,
                          ),
                          GenericHeaderRow(
                            headingChild: HeadingStyleText(
                              text: 'Opening hours in this area',
                              weight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: Dimensions.height20,
                          ),
                          Consumer<ProfileViewController>(
                            builder: (context, controller, child) {
                              var operatingHours = controller.areaOpeningHours;
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: operatingHours.length,
                                itemBuilder: (context, index) {
                                  final Map<String, String> item =
                                      operatingHours[index];
                                  String day = item.keys.first;
                                  String time = item.values.first;

                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Day with flexible width
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '$day:',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black,
                                              fontSize: Dimensions.font20 / 1.3,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: Dimensions.width10),
                                        // Time with flexible width
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            time,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black,
                                              fontSize:
                                                  Dimensions.font20 / 1.29,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          // Disclaimer Section
                          SizedBox(height: Dimensions.height30),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(Dimensions.width15),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.05),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange,
                                      size: Dimensions.iconSize16,
                                    ),
                                    SizedBox(width: Dimensions.width10),
                                    Text(
                                      'Please Note',
                                      style: TextStyle(
                                        fontSize: Dimensions.font16 / 1.1,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimensions.height10),
                                Text(
                                  'These hours may vary during public holidays and special occasions. '
                                  'For precise operating times, please contact individual service providers '
                                  'for gas refill, laundry, pet care, and home care services.',
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
                          ),
                          SizedBox(height: Dimensions.height20),
                          // Bottom padding
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      });
    });
  }
}
