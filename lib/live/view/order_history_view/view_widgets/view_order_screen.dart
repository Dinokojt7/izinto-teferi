import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auxiliery_classes/generic_app_bar.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../home_view/controller/home_view_controller.dart';

class ViewOrderScreen extends StatefulWidget {
  final String orderNumber;
  final Map<String, dynamic> order;
  final bool isFromCheckout;
  const ViewOrderScreen(
      {Key? key,
      required this.orderNumber,
      required this.order,
      this.isFromCheckout = false})
      : super(key: key);

  @override
  State<ViewOrderScreen> createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrderScreen> {
  void _applySystemChromeSettings() {
    SystemNavigation().applyCustomSystemChromeSettings(
        Colors.black, Brightness.light, Colors.black, Brightness.light);
  }

  void _handleBackNavigation() {
    _applySystemChromeSettings();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewController =
        Provider.of<HomeViewController>(context, listen: false);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (widget.isFromCheckout) {
            _applySystemChromeSettings();
            homeViewController.changeIndex(0, false);
          } else {
            _applySystemChromeSettings();
            Navigator.of(context).pop();
          }
        } else {
          _applySystemChromeSettings();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white.withOpacity(0.97),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Stack(
                    children: [
                      GenericAppBar(
                        removeLeading: widget.isFromCheckout,
                        onTap: _handleBackNavigation,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        heading: widget.orderNumber,
                      )
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
