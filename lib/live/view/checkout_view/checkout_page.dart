import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/auxiliery_classes/generic_app_bar.dart';
import 'package:izinto/live/view/address_view/saved_addresses.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/checkout_page_address.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/delivery_options_settings.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/widgets/generic_header_row.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/generic_white_container.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/rider_tip_section.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/select_payment_pending.dart';
import 'package:izinto/live/widgets/buttons/blue_text_button.dart';
import 'package:izinto/live/widgets/buttons/main_action_button.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/live_progress_indicator.dart';
import '../../utilities/colors.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/icons/back_arrow.dart';
import '../../widgets/hyperText_row.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../../widgets/text_widgets/primary_style_text.dart';
import '../home_view/controller/home_view_controller.dart';
import 'view_widgets/order_summary_details.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
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
      return Consumer<CheckoutViewController>(
          builder: (context, _controller, child) {
        final String _deliveryNote = _controller.defaultDeliveryNote;
        return Stack(
          children: [
            Scaffold(
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
                      heading: 'Checkout',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 24.0, top: 25.0, right: 24.0),
                              child: Column(
                                children: [
                                  GenericHeaderRow(
                                    headingChild: HeadingStyleText(
                                      text: 'Delivery address',
                                      weight: FontWeight.w600,
                                    ),
                                    actionButtonChild: BlueTextButton(
                                      text: 'Change',
                                      onTap: () {
                                        Get.to(
                                          () => SavedAddresses(),
                                          transition: Transition.circularReveal,
                                          duration: Duration(milliseconds: 500),
                                        );
                                        Future.delayed(
                                            const Duration(milliseconds: 210),
                                            () async {
                                          setState(() {
                                            SystemNavigation()
                                                .applyCustomSystemChromeSettings(
                                                    Colors.white,
                                                    Brightness.dark,
                                                    Colors.white,
                                                    Brightness.dark);
                                          });
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height15 / 1.2,
                                  ),
                                  GenericWhiteContainer(
                                    child: CheckoutPageAddress(
                                      street: street,
                                      zip: zip,
                                      suburb: suburb,
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),
                                  GenericWhiteContainer(
                                    bottomPadding: 0.0,
                                    rightPadding: 0.0,
                                    child: DeliveryOptionsSettings(),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),
                                  GenericWhiteContainer(
                                    topPadding: Dimensions.height18,
                                    bottomPadding: Dimensions.height18,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Expanded(
                                          child: HeadingStyleText(
                                        text: _deliveryNote,
                                        size: Dimensions.font20 / 1.35,
                                        family: 'Poppins',
                                        weight: FontWeight.w300,
                                        color: Colors.black,
                                      )),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height45 / 1.2,
                                  ),
                                  GenericHeaderRow(
                                    headingChild: HeadingStyleText(
                                      text: 'Rider tip',
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: Dimensions.height10 / 2,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 24.0),
                              child: RiderTipSection(),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Padding(
                              padding: EdgeInsets.only(left: 24.0, right: 24.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: HeadingStyleText(
                                          text:
                                              'Your tip will go directly to your rider as part of their salary!',
                                          size: Dimensions.font20 / 1.6,
                                          family: 'Poppins',
                                          weight: FontWeight.w300,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: Dimensions.height30),
                                  GenericHeaderRow(
                                    headingChild: HeadingStyleText(
                                      text: 'Order summary',
                                      weight: FontWeight.w600,
                                    ),
                                    actionButtonChild: BlueTextButton(
                                      text: 'Add promo code',
                                      onTap: () {},
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),
                                  GenericWhiteContainer(
                                    topPadding: 10.0,
                                    bottomPadding: 10.0,
                                    child: OrderSummaryDetails(),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height30,
                                  ),
                                  GenericHeaderRow(
                                    headingChild: HeadingStyleText(
                                      text: 'Payment method',
                                      weight: FontWeight.w600,
                                    ),
                                    actionButtonChild: BlueTextButton(
                                      text: 'Change',
                                      onTap: () {},
                                    ),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height20 / 1.2,
                                  ),
                                  GenericWhiteContainer(
                                    topPadding: 10.0,
                                    bottomPadding: 10.0,
                                    child: SelectPaymentPending(),
                                  ),
                                  SizedBox(
                                    height: Dimensions.height30,
                                  ),
                                  HyperTextRow(
                                    preText: 'Izinto',
                                    firstLink: 'Terms & Conditions',
                                    middleText: 'and ',
                                    secondLink: 'Privacy Policy',
                                  ),
                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                height: Dimensions.bottomHeightBar / 1.15,
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 24.0, top: 15.0, right: 24.0, bottom: 15.0),
                    child: SaveButton(
                      isActive: true,
                      description: 'Add payment method to order',
                      isAuthScreen: false,
                      onTap: () {},
                    )),
              ),
            ),
            if (_controller.isLoadingIndicator) LiveProgressIndicator(),
          ],
        );
      });
    });
  }
}
