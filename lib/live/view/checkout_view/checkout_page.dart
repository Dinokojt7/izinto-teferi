import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/auxiliery_classes/generic_app_bar.dart';
import 'package:izinto/live/view/address_view/saved_addresses.dart';
import 'package:izinto/live/view/checkout_view/controller/checkout_view_controller.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/checkout_page_address.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/delivery_options_settings.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/payment_method_selector.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/payment_success_screen.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/select_payment_pending.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/selected_payment_method.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/service_tip_section.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/widgets/generic_header_row.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/generic_white_container.dart';
import 'package:izinto/live/widgets/buttons/blue_text_button.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../auxiliery_classes/live_progress_indicator.dart';
import '../../utilities/colors.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/hyperText_row.dart';
import '../../widgets/text_widgets/heading_style_text.dart';
import '../home_view/controller/home_view_controller.dart';
import 'view_widgets/order_summary_details.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.black, Brightness.light, Colors.black, Brightness.light);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewController>(
      builder: (context, _profileController, child) {
        final List<dynamic> _addresses = _profileController.savedAddresses;

        // Safe way to find selected address
        Map<String, dynamic> selectedAddress = {};
        try {
          final selectedAddresses = _addresses
              .where((address) => address['selected'] == true)
              .toList();

          if (selectedAddresses.isNotEmpty) {
            selectedAddress =
                Map<String, dynamic>.from(selectedAddresses.first);
          } else if (_addresses.isNotEmpty) {
            selectedAddress = Map<String, dynamic>.from(_addresses.first);
          }
        } catch (e) {
          print('Error processing addresses: $e');
          selectedAddress = {};
        }

        return Consumer<CheckoutViewController>(
          builder: (context, _controller, child) {
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
                                      // Address Section
                                      GenericHeaderRow(
                                        headingChild: HeadingStyleText(
                                          text: 'Address',
                                          weight: FontWeight.w600,
                                        ),
                                        actionButtonChild: BlueTextButton(
                                          text: 'Change',
                                          onTap: () {
                                            Get.to(
                                              () => SavedAddresses(),
                                              transition:
                                                  Transition.circularReveal,
                                              duration:
                                                  Duration(milliseconds: 500),
                                            );
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 210),
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
                                          height: Dimensions.height15 / 1.2),
                                      GenericWhiteContainer(
                                        child: CheckoutPageAddress(
                                          street:
                                              selectedAddress['street'] ?? '',
                                          zip: selectedAddress['zip'] ?? '',
                                          suburb:
                                              selectedAddress['suburb'] ?? '',
                                        ),
                                      ),
                                      SizedBox(height: Dimensions.height20),

                                      // Delivery Options
                                      GenericWhiteContainer(
                                        bottomPadding: 0.0,
                                        rightPadding: 0.0,
                                        child: DeliveryOptionsSettings(),
                                      ),
                                      SizedBox(height: Dimensions.height20),

                                      // Delivery Notes
                                      GenericWhiteContainer(
                                        topPadding: Dimensions.height18,
                                        bottomPadding: Dimensions.height18,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: TextField(
                                            controller: _controller
                                                .deliveryNotesController,
                                            onChanged:
                                                _controller.updateDeliveryNote,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText:
                                                  _controller.deliveryNote,
                                              hintStyle: TextStyle(
                                                fontSize:
                                                    Dimensions.font20 / 1.35,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontSize:
                                                  Dimensions.font20 / 1.35,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w300,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: Dimensions.height45 / 1.2),

                                      // Service Tip Section
                                      GenericHeaderRow(
                                        headingChild: HeadingStyleText(
                                          text: 'Service Tip',
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: Dimensions.height10 / 2),
                                Padding(
                                  padding: EdgeInsets.only(left: 24.0),
                                  child: ServiceTipSection(),
                                ),
                                SizedBox(height: Dimensions.height10),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 24.0, right: 24.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: HeadingStyleText(
                                              text:
                                                  'Your tip will go directly to your service provider as part of their salary!',
                                              size: Dimensions.font20 / 1.6,
                                              family: 'Poppins',
                                              weight: FontWeight.w300,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: Dimensions.height30),

                                      // Order Summary
                                      GenericHeaderRow(
                                        headingChild: HeadingStyleText(
                                          text: 'Order Summary',
                                          weight: FontWeight.w600,
                                        ),
                                        // actionButtonChild: BlueTextButton(
                                        //   text: 'Add promo code',
                                        //   onTap: () {
                                        //     // TODO: Implement promo code functionality
                                        //   },
                                        // ),
                                      ),
                                      SizedBox(height: Dimensions.height20),
                                      GenericWhiteContainer(
                                        topPadding: 10.0,
                                        bottomPadding: 10.0,
                                        child: OrderSummaryDetails(),
                                      ),
                                      SizedBox(height: Dimensions.height30),

                                      // Payment Method
                                      GenericHeaderRow(
                                        headingChild: HeadingStyleText(
                                          text: 'Payment Method',
                                          weight: FontWeight.w600,
                                        ),
                                        actionButtonChild: _controller
                                                .selectedPaymentMethod
                                                .isNotEmpty
                                            ? BlueTextButton(
                                                text: 'Change',
                                                onTap: () {
                                                  _showPaymentMethodSelector(
                                                      context);
                                                },
                                              )
                                            : Container(),
                                      ),
                                      SizedBox(
                                          height: Dimensions.height20 / 1.2),
                                      GenericWhiteContainer(
                                        topPadding: 10.0,
                                        bottomPadding: 10.0,
                                        child: _controller.selectedPaymentMethod
                                                .isNotEmpty
                                            ? SelectedPaymentMethod()
                                            : GestureDetector(
                                                onTap: () {
                                                  _showPaymentMethodSelector(
                                                      context);
                                                },
                                                child: SelectPaymentPending(),
                                              ),
                                      ),
                                      SizedBox(height: Dimensions.height30),
                                      HyperTextRow(
                                        preText: 'Izinto',
                                        firstLink: 'Terms & Conditions',
                                        middleText: 'and ',
                                        secondLink: 'Privacy Policy',
                                      ),
                                      SizedBox(height: Dimensions.height20),
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
                        isActive: _controller.isFormValid,
                        description:
                            'Proceed with payment - R${_controller.orderTotal},00',
                        isAuthScreen: false,
                        onTap: _controller.isFormValid
                            ? () {
                                _processOrder(context, selectedAddress);
                              }
                            : () {
                                // Optional: Show message when form is not valid
                                Get.snackbar(
                                  'Incomplete Information',
                                  'Please select a payment method to continue.',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              },
                      ),
                    ),
                  ),
                ),
                if (_controller.isLoadingIndicator) LiveProgressIndicator(),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentMethodSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PaymentMethodSelector(),
    );
  }

// For Option 1 (returning order):
  void _processOrder(BuildContext context, Map<String, dynamic> address) async {
    final checkoutController =
        Provider.of<CheckoutViewController>(context, listen: false);

    try {
      final order = await checkoutController.submitOrder(address);

      // Navigate directly to success screen
      setState(() {
        SystemNavigation().applyCustomSystemChromeSettings(
            Colors.white, Brightness.dark, Colors.white, Brightness.dark);
      });
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => CashPaymentSuccessScreen(
              order: order,
            )),
            (Route<dynamic> route) => false, // removes everything
      );

    } catch (error) {
      Get.snackbar(
        'Order Failed',
        'Error: ${error.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }
}
