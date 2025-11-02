import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/live/utilities/generic_snackbar.dart';
import 'package:izinto/live/view/cart_view/view_widgets/cart_heading.dart';
import 'package:izinto/live/view/cart_view/view_widgets/cart_product_view.dart';
import 'package:izinto/live/view/cart_view/view_widgets/cart_recommended_section.dart';
import 'package:izinto/models/user.dart';
import 'package:provider/provider.dart';
import '../../../controllers/cart_controller.dart';
import '../../../pages/cart/cart_processes_and_widgets/no_items.dart';
import '../../auxiliery_classes/generic_app_bar.dart';
import '../../widgets/generic_center_dialog.dart';
import '../auth_view/phone_auth_view.dart';
import '../checkout_view/checkout_page.dart';
import '../checkout_view/view_widgets/call_checkout.dart';
import '../home_view/controller/home_view_controller.dart';
import '../home_view/sliver_home_page.dart';

class CartViewPage extends StatelessWidget {
  const CartViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewCartController>(builder: (_cartController) {
      final homeViewController =
          Provider.of<HomeViewController>(context, listen: false);
      final user = Provider.of<UserModel?>(context);
      // Total cart items count
      final String quantityText =
          _cartController.totalItems == 1 ? 'item' : 'items';
      final String totalItemCount =
          '${_cartController.totalItems} $quantityText';
      // List of all items in the cart
      var _cartList = _cartController.getItems;
      // Total cart value
      final int _totalAmount = _cartController.totalAmount;
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
              // App Bar
              GenericAppBar(
                heading: 'Your cart',
                removeLeading: true,
              ),
              // Scrollable content
              _cartList.length != 0
                  ? Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Cart Heading
                            CartHeading(
                              totalInCartItems: totalItemCount,
                              viewContext: context,
                            ),
                            // Cart Items List
                            _cartList.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _cartList.length,
                                    itemBuilder: (_, index) {
                                      return CartProductView(
                                        cartList: _cartList,
                                        index: index,
                                      );
                                    },
                                  )
                                : NoItems(),
                            // Recommended Section
                            CartRecommendedSection(),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: GenericCenterDialog(
                        emoji: '\u{1F494}',
                        heading: 'No items selected',
                        description:
                            'Browse services and make a reservation to checkout.',
                        buttonText: 'Start browsing',
                        callBack: () {
                          homeViewController.changeIndex(0, false);
                        },
                      ),
                    ),
              // Checkout Button
              _cartList.length != 0
                  ? CallCheckout(
                      totalCartAmount: _totalAmount,
                      onTap: () {
                        if (user == null) {
                          GenericSnackBar().showCustomSnackBar(() {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            homeViewController.onPopNavigation(
                                context, PhoneAuthView());
                          }, context, 'Please login to continue', false);
                        } else {
                          homeViewController.onIndependentPageNavigation(
                              context, CheckoutPage());
                        }
                      },
                    )
                  : Container(),
            ],
          ),
        ),
        // bottomNavigationBar: GenericBottomAppBar(),
      );
    });
  }
}
