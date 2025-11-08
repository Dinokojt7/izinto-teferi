import 'package:flutter/material.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../widgets/buttons/blue_text_button.dart';
import '../../widgets/generic_header_row.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../address_view/saved_addresses.dart';
import '../checkout_view/view_widgets/checkout_page_address.dart';
import '../checkout_view/view_widgets/generic_white_container.dart';
import '../profile_view/controller/profile_view_controller.dart';

class OpeningHours extends StatelessWidget {
  const OpeningHours({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewController>(
        builder: (context, _profileController, child) {
      ///Here's a list of addresses from the controller///
      final List<dynamic> _addresses = _profileController.savedAddresses;

      ///Here's the selection of currently active address///
      var selectedAddresses =
          _addresses.where((address) => address['selected'] == true).toList();

      var street = '';
      var zip = '';
      var suburb = '';
      // Iterate over the filtered addresses and use their values
      for (var address in selectedAddresses) {
        street = address['street'];
        zip = address['zip'];
        suburb = address['suburb'];
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
                            text: 'Your delivery address',
                            weight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: Dimensions.height15 / 1.2,
                        ),
                        GenericWhiteContainer(
                          child: GenericHeaderRow(
                            headingChild: CheckoutPageAddress(
                              street: street,
                              zip: zip,
                              suburb: suburb,
                            ),
                            actionButtonChild: BlueTextButton(
                              text: 'Change',
                              onTap: () {
                                // Provider.of<CheckoutViewController>(context,
                                //         listen: false)
                                //     .onUserNavigation(
                                //         context, SavedAddresses());
                              },
                            ),
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
                              shrinkWrap:
                                  true, // Shrink the ListView to fit within its parent
                              physics:
                                  NeverScrollableScrollPhysics(), // Disable ListView's scrolling
                              itemCount: operatingHours
                                  .length, // Number of items in the list
                              itemBuilder: (context, index) {
                                // Get the current map (day and time)
                                final Map<String, String> item =
                                    operatingHours[index];

                                // Extract day and time from the map
                                String day = item.keys.first;
                                String time = item.values.first;

                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 8.0, 50.0, 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Distribute evenly
                                    children: [
                                      Text(
                                        '${day}:',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                          fontSize: Dimensions.font20 / 1.3,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        time,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                          fontSize: Dimensions.font20 / 1.29,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
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
  }
}
