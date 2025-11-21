import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/widgets/buttons/save_button.dart';
import 'package:provider/provider.dart';

import '../../../utils/dimensions.dart';
import '../../widgets/icons/back_arrow.dart';
import '../../widgets/text_widgets/description_text.dart';
import '../../widgets/text_widgets/introduction_text.dart';
import '../address_view/add_new_address.dart';
import '../address_view/controller/address_dropdown_controller.dart';

class GuestAccess extends StatefulWidget {
  const GuestAccess({Key? key}) : super(key: key);

  @override
  State<GuestAccess> createState() => _GuestAccessState();
}

class _GuestAccessState extends State<GuestAccess> {
  Color _statusBarColor = Colors.white.withOpacity(0.0001);

  @override
  void initState() {
    // SystemNavigation()
    //     .applyCustomSystemChromeSettings(Colors.white, Brightness.dark);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainAddressViewController>(
        builder: (context, addressViewController, child) {
      ///Button loader
      var _isLoading = addressViewController.startAddressSearch;
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: double.maxFinite,
          decoration: BoxDecoration(
            //color: Colors.brown,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/image/guest-access.jpg'),
            ),
          ),
          child: Column(
            children: [
              Flexible(flex: 4, child: Container()),
              Flexible(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radius30),
                      topRight: Radius.circular(Dimensions.radius30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                        vertical: Dimensions.height20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            BackArrow(
                              iconColor: Colors.black,
                              onTap: () {
                                setState(() {
                                  _statusBarColor = Colors.black;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Dimensions.height20,
                        ),
                        IntroductionText(
                            text:
                                'We handle your essential needs, wherever you are'),
                        SizedBox(
                          height: Dimensions.height20 * 1.5,
                        ),
                        DescriptionText(
                            maxLines: 3,
                            text:
                                'Add your address so we can check which services are available in your area, and how many minutes we can get to you. \u{1F680}'),
                        SizedBox(
                          height: Dimensions.height20 * 1.5,
                        ),
                        SaveButton(
                          isActive: true,
                          isLoading: _isLoading,
                          description: 'Add address',
                          isAuthScreen: false,
                          onTap: () async {
                            await addressViewController.initiateSearch(true);
                            await Get.to(
                                () => AddNewAddress(
                                      shouldReturnDarkStatus: false,
                                    ),
                                transition: Transition.fade,
                                duration: Duration(seconds: 1));
                            addressViewController.restartLoader();
                          },
                        )
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
