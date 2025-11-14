import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/utilities/generic_snackbar.dart';
import 'package:izinto/live/view/checkout_view/checkout_page.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/new_cart_controller.dart';
import '../../../../models/new_cart_model.dart';
import '../../../../utils/dimensions.dart';
import '../../../utilities/colors.dart';
import '../../../widgets/buttons/cart_action_button.dart';
import '../../../widgets/generic_header_row.dart';
import '../../../widgets/text_widgets/introduction_text.dart';
import '../controller/checkout_view_controller.dart';

class CallCheckout extends StatelessWidget {
  final int totalCartAmount;
  final VoidCallback onTap;
  const CallCheckout({
    super.key,
    required this.totalCartAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMinimumMet = totalCartAmount >= 150;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 2.0),
          child: Container(
            color: Colors.transparent,
            child: GenericHeaderRow(
              headingChild: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: IntroductionText(
                    text: 'R${totalCartAmount.toString()},00*'),
              ),
              actionButtonChild: CartActionButton(
                isCartCheckoutButton: true,
                backgroundColor: isMinimumMet
                    ? LiveColors.cartBlue
                    : LiveColors.standardBlue.withOpacity(0.05),
                isActive: isMinimumMet,
                description: 'Checkout',
                onTap: isMinimumMet
                    ? () => _handleCheckout(context)
                    : () {
                        GenericSnackBar().showCustomSnackBar(null, context,
                            'Basket total must be at least R150.00', false);
                      },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCheckout(BuildContext context) {
    final cartController = Get.find<NewCartController>();

    // Check if there are laundry items below minimum threshold
    final laundryValidation = _validateLaundryItems(cartController.getItems);

    if (laundryValidation.hasLowLaundryItems) {
      _showLaundryWarningBottomSheet(context, laundryValidation);
    } else {
      // No laundry issues, proceed normally
      _proceedToCheckout(context, null);
    }
  }

  LaundryValidationResult _validateLaundryItems(List<NewCartModel> cartItems) {
    int laundryTotal = 0;
    bool hasLaundryItems = false;
    List<NewCartModel> laundryItems = [];

    for (final item in cartItems) {
      final provider = item.provider?.toString().toLowerCase() ?? '';
      if (provider.contains('easy laundry') || provider.contains('laundry')) {
        hasLaundryItems = true;
        laundryItems.add(item);
        laundryTotal += (item.price ?? 0) * (item.quantity ?? 0);
      }
    }

    return LaundryValidationResult(
      hasLaundryItems: hasLaundryItems,
      hasLowLaundryItems: hasLaundryItems && laundryTotal < 150,
      laundryTotal: laundryTotal,
      laundryItems: laundryItems,
    );
  }

  void _showLaundryWarningBottomSheet(
      BuildContext context, LaundryValidationResult validation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildLaundryWarningSheet(context, validation),
    ).then((result) {
      // This handles when the user taps "Proceed to Checkout" in the bottom sheet
      if (result != null && result is LaundryValidationResult) {
        _proceedToCheckout(context, result);
      }
    });
  }

  Widget _buildLaundryWarningSheet(
      BuildContext context, LaundryValidationResult validation) {
    final cartController = Get.find<NewCartController>();
    final adjustedTotal = cartController.totalAmount - validation.laundryTotal;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: Dimensions.height20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Warning Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Text(
                  'Laundry Service Notice',
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10),

          Divider(
            color: Colors.grey.shade400,
            height: 1,
            thickness: 0.5,
          ),
          SizedBox(height: Dimensions.height10),

          // Warning Message
          Text(
            'Your laundry items (R${validation.laundryTotal},00) do not meet the minimum order requirement of R150,00 for mobile laundry service.',
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.1,
              fontFamily: 'Poppins',
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          SizedBox(height: Dimensions.height10),

          Text(
            'You can proceed to checkout, but laundry items will be excluded from your final order and kept in your cart.',
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.1,
              fontFamily: 'Poppins',
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          SizedBox(height: Dimensions.height30),

          // Order Summary
          Container(
            padding: EdgeInsets.all(Dimensions.width15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                    'Current Cart Total', 'R${cartController.totalAmount},00'),
                _buildSummaryRow('Laundry Items to exclude',
                    '-R${validation.laundryTotal},00',
                    isRed: true),
                Divider(
                    color: Colors.grey.shade400, height: Dimensions.height20),
                _buildSummaryRow(
                    'Order Total at Checkout', 'R$adjustedTotal,00',
                    isBold: true),
              ],
            ),
          ),

          SizedBox(height: Dimensions.height30),

          // Action Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: Container(
                  height: Dimensions.height45,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width15),

              // Proceed Button - FIXED: Now properly passes validation result
              Expanded(
                child: Container(
                  height: Dimensions.height45,
                  decoration: BoxDecoration(
                    color: LiveColors.cartBlue,
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Pass the validation info back to the parent and close the sheet
                      Navigator.of(context).pop(validation);
                    },
                    child: Text(
                      'Proceed',
                      style: TextStyle(
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isRed = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10 / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.1,
              fontFamily: 'Poppins',
              color: Colors.grey.shade600,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Dimensions.font16 / 1.1,
              fontFamily: 'Poppins',
              color: isRed
                  ? Colors.red
                  : (isBold ? Colors.black : Colors.grey.shade700),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(
      BuildContext context, LaundryValidationResult? validation) {
    // Store laundry info in checkout controller if provided
    if (validation != null) {
      final checkoutController =
          Provider.of<CheckoutViewController>(context, listen: false);
      checkoutController.setLaundryValidationInfo(validation);
    }

    // Use the original onTap callback which handles navigation
    onTap();
  }
}

class LaundryValidationResult {
  final bool hasLaundryItems;
  final bool hasLowLaundryItems;
  final int laundryTotal;
  final List<NewCartModel> laundryItems;

  LaundryValidationResult({
    required this.hasLaundryItems,
    required this.hasLowLaundryItems,
    required this.laundryTotal,
    required this.laundryItems,
  });
}
