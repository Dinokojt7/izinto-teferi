import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/pet_care_specialty_controller.dart';
import 'package:izinto/controllers/new_cart_controller.dart';
import 'package:izinto/live/view/cart_view/cart_view_page.dart';
import 'package:izinto/live/view/home_view/controller/home_view_controller.dart';
import 'package:izinto/live/widgets/buttons/primary_blue_button.dart';
import 'package:izinto/live/widgets/specialty_stepper_row.dart';
import 'package:izinto/live/widgets/text_widgets/heading_style_text.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/utils/dimensions.dart';
import 'package:provider/provider.dart';

class PetGroomingView extends StatefulWidget {
  const PetGroomingView({Key? key}) : super(key: key);

  @override
  State<PetGroomingView> createState() => _PetGroomingViewState();
}

class _PetGroomingViewState extends State<PetGroomingView> {
  final Map<int, int> _quantities = {};

  int get _cartCount => _quantities.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: HeadingStyleText(text: 'Pet Grooming', size: Dimensions.font16, weight: FontWeight.w600),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GetBuilder<PetCareSpecialtyController>(
          builder: (controller) {
            final list = controller.getSafePetCareList();
            if (controller.isLoading && list.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (list.isEmpty) {
              return Center(
                child: PrimaryStyleText(text: 'No grooming options available right now.', color: Colors.black54),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
                  child: PrimaryStyleText(
                    text: 'Mobile & at-home grooming for your pet.',
                    size: Dimensions.font16 * 0.9,
                    color: Colors.black54,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.black.withOpacity(0.06)),
                    itemBuilder: (context, index) {
                      final specialty = list[index];
                      final qty = _quantities[specialty.id] ?? 0;
                      return SpecialtyStepperRow(
                        specialty: specialty,
                        quantity: qty,
                        onDecrement: qty > 0
                            ? () {
                                setState(() => _quantities[specialty.id!] = qty - 1);
                                Get.find<NewCartController>().addItem(specialty, -1);
                              }
                            : null,
                        onIncrement: () {
                          setState(() => _quantities[specialty.id!] = qty + 1);
                          Get.find<NewCartController>().addItem(specialty, 1);
                        },
                      );
                    },
                  ),
                ),
                if (_cartCount > 0) _buildBottomBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(Dimensions.width20, Dimensions.height15, Dimensions.width20, Dimensions.height15),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06)))),
      child: PrimaryBlueButton(
        text: 'View cart · $_cartCount item${_cartCount == 1 ? '' : 's'}',
        onTap: () => Provider.of<HomeViewController>(context, listen: false)
            .onIndependentPageNavigation(context, const CartViewPage()),
      ),
    );
  }
}
