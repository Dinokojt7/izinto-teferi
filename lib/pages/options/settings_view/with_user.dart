import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import 'package:izinto/pages/options/settings_view/settings_tiles.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/big_text.dart';
import '../../../widgets/bottom_delete_sheet.dart';
import '../../../widgets/texts/integers_and_doubles.dart';
import 'get_help_popup.dart';
import '../../../widgets/texts/small_text.dart';
import '../../subscriptions/subscriptions.dart';
import 'terms_of_use.dart';
import '../location_settings.dart';
import '../profile_settings.dart';

class SettingsViewWithUser extends StatefulWidget {
  const SettingsViewWithUser({
    Key? key,
    required String name,
    required String surname,
    required this.isLoading,
    required this.iTokens,
    required this.planStatus,
    required this.showDialog,
  })  : _name = name,
        _surname = surname,
        super(key: key);

  final String _name;
  final String _surname;
  final bool isLoading;
  final double iTokens;
  final int planStatus;
  final ValueNotifier<bool> showDialog;

  @override
  State<SettingsViewWithUser> createState() => _SettingsViewWithUserState();
}

class _SettingsViewWithUserState extends State<SettingsViewWithUser> {
  final String quarterlyAmount = '';

  final String byAnnualAmount = '';

  @override
  Widget build(BuildContext context) {
    var tokens = widget.iTokens.toString();
    final displayTokens = tokens.substring(0, 3);
    void _showSubscriptionPanel() {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20))),
          isScrollControlled: true,
          useSafeArea: true,
          context: context,
          builder: (context) {
            return SubscriptionPage(
              quarterlyAmount: quarterlyAmount,
              byAnnualAmount: byAnnualAmount,
            );
          });
    }

    _showLogOutPanel() {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext context) {
          return BottomDeleteSheet(
            expected: 'Logout',
            headerText: 'Are you sure you want to Log out?',
            action: 'Log out',
          );
        },
      );
    }

    _showDeletePanel(BuildContext context) {
      showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return BottomDeleteSheet(
            expected: 'Delete account',
            headerText: 'Delete your account?',
            action: 'Delete',
          );
        },
      );
    }

    _showSheetDelete(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: Dimensions.screenHeight / 4,
                width: Dimensions.screenWidth / 1.03,
              ),
            ),
          );
        },
      );
    }

    return SafeArea(
      child: Container(
        width: double.maxFinite,
        child: Column(
          children: [
            //Second row
            Container(
              decoration: BoxDecoration(
                  // border: Border(
                  //   bottom: BorderSide(color: Theme.of(context).dividerColor),
                  // ),
                  ),
              width: double.maxFinite,
              padding: EdgeInsets.only(
                top: Dimensions.height20,
                left: Dimensions.width10,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Wrap(
                      children: [
                        BigText(
                          overFlow: TextOverflow.ellipsis,
                          size: Dimensions.height20 + Dimensions.height20,
                          text: widget._name,
                          // text: FirebaseAuth
                          //     .instance.currentUser!.displayName!,
                          color: const Color(0Xff353839),
                          weight: FontWeight.bold,
                        ),
                        SizedBox(
                          width: Dimensions.width10,
                        ),
                        BigText(
                          overFlow: TextOverflow.fade,
                          size: Dimensions.height20 + Dimensions.height20,
                          text: widget._surname,
                          // text: FirebaseAuth
                          //     .instance.currentUser!.displayName!,
                          color: const Color(0Xff353839),
                          weight: FontWeight.bold,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 4),
                            elevation: 0,
                            backgroundColor: Color(0xff9A9484).withOpacity(0.9),
                            behavior: SnackBarBehavior.floating,
                            content: Text(tokens == '0.0'
                                ? 'You have no rewards earned.'
                                : 'You have ${displayTokens} rewards earned.'),
                          ),
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xff9A9483), Color(0xffB09B71)]),
                          border: Border.all(width: 2, color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.blur_circular_outlined,
                            color: Colors.white,
                            size: Dimensions.iconSize24 * 2.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: Dimensions.screenHeight / 50,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //Subscription
                    GestureDetector(
                      onTap: () {
                        widget.showDialog.value = !widget.showDialog.value;
                        // planStatus == 0 ? _showSubscriptionPanel() : null;
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: Dimensions.width20,
                          left: Dimensions.width20,
                          right: Dimensions.width20,
                        ),
                        child: Container(
                          width: Dimensions.screenWidth,
                          padding: EdgeInsets.only(
                            top: Dimensions.height10 * 1.3,
                            left: Dimensions.width30,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2.5,
                                offset: Offset(-2, -1), // Top-left shadow
                              ),
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2.5,
                                offset: Offset(1, 2), // Bottom-right shadow
                              ),
                            ],
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius20),
                          ),
                          height: 90,
                          child: Wrap(
                            children: [
                              Column(
                                children: [
                                  Wrap(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: widget.planStatus == 0
                                                  ? 'View subscription plans\n'
                                                  : 'Remaining capacity: ${widget.planStatus}kg\n',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: widget.planStatus == 0
                                                    ? Dimensions.font20
                                                    : Dimensions.font20 / 1.1,
                                                fontFamily: 'Poppins',
                                                letterSpacing: 0.10,
                                                height: 1.3,
                                              ),
                                            ),
                                            TextSpan(
                                              text: widget.planStatus == 0
                                                  ? 'Explore options and design\n'
                                                  : 'You\'ve subscribed to the laundry plan\n',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize:
                                                    Dimensions.font16 / 1.15,
                                                fontFamily: 'Hind',
                                                letterSpacing: 0.10,
                                                height: 1.3,
                                              ),
                                            ),
                                            TextSpan(
                                              text: widget.planStatus == 0
                                                  ? 'your plan'
                                                  : 'select subscription payment in cart',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize:
                                                    Dimensions.font16 / 1.15,
                                                fontFamily: 'Hind',
                                                letterSpacing: 0.10,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: widget.planStatus == 0
                                    ? Dimensions.screenWidth / 10
                                    : Dimensions.screenWidth / 12,
                              ),
                              Image(
                                image: AssetImage(
                                    'assets/image/laundry-detergent.png'),
                                width: Dimensions.screenWidth / 7,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    Divider(
                      indent: 18,
                      endIndent: 28,
                      color: Colors.black26,
                      height: 20,
                    ),

                    //profile
                    GestureDetector(
                      onTap: () {
                        Get.to(
                            () => ProfileSettings(
                                  isPhoneAuth: false,
                                ),
                            transition: Transition.fade,
                            duration: Duration(seconds: 1));
                      },
                      child: SettingsTile(
                        icon: Icons.person,
                        title: 'Account',
                      ),
                    ),

                    //saved addressed
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const AddressSettings(),
                            transition: Transition.fade,
                            duration: Duration(seconds: 1));
                      },
                      child: SettingsTile(
                        icon: Icons.location_on_sharp,
                        title: 'Addresses',
                      ),
                    ),

                    //divider
                    Divider(
                      indent: 18,
                      endIndent: 28,
                      color: Colors.black26,
                      height: 20,
                    ),

                    //help
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const GetHelpPopUp(),
                            transition: Transition.rightToLeft,
                            duration: Duration(milliseconds: 100));
                      },
                      child: SettingsTile(
                        icon: Icons.help,
                        title: 'Help',
                      ),
                    ),

                    //terms & conditions
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const TermsOfUse(),
                            transition: Transition.rightToLeft,
                            duration: Duration(milliseconds: 100));
                      },
                      child: SettingsTile(
                        icon: Icons.info,
                        title: 'Terms of use',
                      ),
                    ),

                    Divider(
                      indent: 18,
                      endIndent: 28,
                      color: Colors.black26,
                      height: 20,
                    ),

                    //sign out
                    GestureDetector(
                      onTap: () {
                        _showLogOutPanel();
                      },
                      child: SettingsTile(
                        icon: Icons.logout_outlined,
                        title: 'Log out',
                      ),
                    ),

                    //sized box
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: SizedBox(
                        width: Dimensions.width20,
                      ),
                    ),

                    //app info
                    Padding(
                      padding: EdgeInsets.only(
                          left: Dimensions.width30,
                          top: Dimensions.height10 / 2,
                          right: Dimensions.width10 / 2,
                          bottom: Dimensions.height20 / 4),
                      child: Row(
                        children: [
                          SmallText(text: 'App version: 1 . 0 . 0'),
                        ],
                      ),
                    ),

                    //sized box
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: SizedBox(
                        height: Dimensions.height20,
                      ),
                    ),

                    //delete account
                    Padding(
                      padding: EdgeInsets.only(
                          left: Dimensions.width20,
                          right: Dimensions.width20,
                          bottom: Dimensions.height20),
                      child: GestureDetector(
                        onTap: () {
                          _showSheetDelete(context);
                        },
                        child: Container(
                          height: Dimensions.screenHeight / 13,
                          width: double.maxFinite,
                          margin:
                              EdgeInsets.only(bottom: 10, top: 10, right: 10),
                          padding: EdgeInsets.only(
                              left: 10, bottom: 8, right: 10, top: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius15),
                            border: Border.all(width: 0.5, color: Colors.red),
                          ),
                          child: widget.isLoading
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 6,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: BigText(
                                    text: 'Delete account',
                                    size: Dimensions.font20,
                                    weight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    //sized box
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: SizedBox(
                        width: Dimensions.width20,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LaundrySubscriptionDetails extends StatefulWidget {
  final int planStatus;
  const LaundrySubscriptionDetails({Key? key, required this.planStatus})
      : super(key: key);

  @override
  State<LaundrySubscriptionDetails> createState() =>
      _LaundrySubscriptionDetailsState();
}

class _LaundrySubscriptionDetailsState
    extends State<LaundrySubscriptionDetails> {
  DateTime nextDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d MMMM H:mm').format(nextDate);
    return Column(
      children: [
        SizedBox(
          height: Dimensions.screenWidth / 80,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IntegerText(
              text: formattedDate,
              color: Colors.black,
              fontWeight: FontWeight.w500,
              size: Dimensions.font16,
              height: 1.4,
            ),
            IntegerText(
              text: '${widget.planStatus}(kg)',
              color: Colors.black,
              fontWeight: FontWeight.w500,
              size: Dimensions.font16,
              height: 1.4,
            ),
          ],
        ),
        SizedBox(
          height: Dimensions.screenWidth / 80,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 1,
                    offset: Offset(1, 1),
                    color: AppColors.mainBlackColor.withOpacity(0.2),
                  ),
                  BoxShadow(
                    blurRadius: 1,
                    offset: Offset(-1, -1),
                    color: AppColors.iconColor1.withOpacity(0.1),
                  ),
                ],
                borderRadius: BorderRadius.circular(Dimensions.radius20 / 2),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xffCFC5A5),
                    Color(0xff9A9483),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_laundry_service_outlined,
                    color: Colors.white,
                    size: Dimensions.iconSize16,
                  ),
                  SizedBox(
                    width: Dimensions.width10,
                  ),
                  Text(
                    'Active',
                    style: TextStyle(
                        fontFamily: 'Hind',
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            IntegerText(
              text: '13 Washes',
              color: Colors.black,
              fontWeight: FontWeight.w500,
              size: Dimensions.font16,
              height: 1.4,
            ),
          ],
        ),
      ],
    );
  }
}
