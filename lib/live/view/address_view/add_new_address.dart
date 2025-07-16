import 'package:flutter/material.dart';
import 'package:izinto/live/auxiliery_classes/live_progress_indicator.dart';
import 'package:provider/provider.dart';
import '../../utilities/generic_system_navigation.dart';
import '../../widgets/lock_screen.dart';
import '../profile_view/controller/profile_view_controller.dart';
import 'view_widgets/map_location_picker.dart';
import '../../../services/map_function.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/dimensions.dart';
import '../../widgets/icons/back_arrow.dart';
import 'controller/address_dropdown_controller.dart';

class AddNewAddress extends StatefulWidget {
  final bool shouldReturnDarkStatus;
  const AddNewAddress({Key? key, required this.shouldReturnDarkStatus})
      : super(key: key);

  @override
  State<AddNewAddress> createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  Color _statusBarColor = Colors.white.withOpacity(0.05);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainAddressViewController>(
        builder: (context, _controller, child) {
      final _isLoading = _controller.isAddressDialogLoading;
      return WillPopScope(
        onWillPop: () async {
          if (widget.shouldReturnDarkStatus) {
            setState(() {
              _statusBarColor = Colors.black.withOpacity(0.05);
            });
            SystemNavigation().applyCustomSystemChromeSettings(
              Colors.black,
              Brightness.light,
              Colors.transparent,
              Brightness.light,
            );
          }
          return true;
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white.withOpacity(0.94),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: _statusBarColor,
                automaticallyImplyLeading: false,
                toolbarHeight: 0,
              ),
              body: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    buildHeader(context, widget.shouldReturnDarkStatus),

                    /// Google map view
                    Expanded(
                      child: Container(
                        width: double.maxFinite,
                        color: Colors.transparent,
                        child: MapLocationPicker(
                          apiKey: AppConstants.PLACES_API,
                          canPopOnNextButtonTaped: true,
                          currentLatLng: const LatLng(-26.056, 28.060),
                          onNext: (GeocodingResult? result) {
                            if (result != null) {
                              // setState(() {
                              //   address = result.formattedAddress ?? "";
                              // });
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (_isLoading) LockScreen()
          ],
        ),
      );
    });
  }

  Padding buildHeader(BuildContext context, bool shouldReturnLightStatus) {
    final addressController =
        Provider.of<MainAddressViewController>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width20,
          top: Dimensions.height20,
          right: Dimensions.width20,
          bottom: 0.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: BackArrow(
                  iconColor: Colors.black45,
                  onTap: () {
                    addressController.restartLoader();
                    if (shouldReturnLightStatus) {
                      setState(() {
                        _statusBarColor = Colors.white;
                      });
                    } else {
                      setState(() {
                        _statusBarColor = Colors.black;
                      });
                    }
                    //Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logos/retro-logo.png', // Image path from item list
                width: 30.0,
                height: 30.0, alignment: Alignment.topCenter,
              )
            ],
          )
        ],
      ),
    );
  }
}
