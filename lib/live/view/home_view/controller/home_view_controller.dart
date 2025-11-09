import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/live/view/profile_view/controller/profile_view_controller.dart';
import 'package:izinto/live/widgets/bottom_remove_sheet.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/bottom_delete_sheet.dart';
import '../../../utilities/generic_snackbar.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../auth_view/phone_auth_view.dart';
import '../../checkout_view/checkout_page.dart';

class HomeViewController extends ChangeNotifier {
  List carWashDetails = [
    {
      'image': 'assets/image/service-detail7.png',
      'heading': 'Car wash on demand!',
      'description': 'Book a wash from anywhere!'
    },
    {
      'image': 'assets/image/service-detail4.png',
      'heading': 'Access premium services!',
      'description': 'Unlimited wash types!'
    },
    {
      'image': 'assets/image/service-detail5.png',
      'heading': 'Experience real convenience!',
      'description': 'Expert car wash!'
    },
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Color _navigationBarColor = Colors.white;
  Color get navigationBarColor => _navigationBarColor;
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  //Global nav menu index controller
  Future<void> changeIndex(int index, bool isScaffoldNav) async {
    if (isScaffoldNav) {
      _currentIndex = index;
      notifyListeners();
    } else {
      _isLoadingIndicator = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2), () async {
        _currentIndex = index;
        _isLoadingIndicator = false;
        notifyListeners();
      });
    }
  }

  bool _isLoadingIndicator = false;
  bool get isLoadingIndicator => _isLoadingIndicator;

  onTapNav(int index) async {
    await changeIndex(index, true);
    _selectedIndex = _currentIndex;
    notifyListeners();
  }

  Future<void> onAccess(Color color) async {
    _navigationBarColor = color;
    notifyListeners();
  }

  Future<void> onUserNavigation(BuildContext context, Widget child) async {
    _isLoadingIndicator = true;
    notifyListeners(); //

    await Future.delayed(const Duration(seconds: 3), () async {
      _isLoadingIndicator = false;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => child,
        ),
      );
      notifyListeners();
    });
  }

  Future<void> onIndependentPageNavigation(
      BuildContext context, Widget child) async {
    _isLoadingIndicator = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3), () async {
      await Get.to(() => child,
          transition: Transition.fade, duration: Duration(seconds: 1));
      _isLoadingIndicator = false;
      notifyListeners();
    });
  }

  Future<void> onPopNavigation(BuildContext context, Widget child) async {
    // SystemNavigation()
    //     .applyCustomSystemChromeSettings(Colors.white, Brightness.dark);
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => child), (route) => false);
    // Get.to(() => child,
    //     transition: Transition.fade, duration: Duration(seconds: 1));
  }

  /// Detail page with custom transition animation
  void navigateToNestedWidget(BuildContext context, Widget child) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  /// Function to copy text to the clipboard
  void copyPromoCodeToClip(BuildContext context, String promoCode) {
    Clipboard.setData(ClipboardData(text: promoCode));
    // Show a snackBar to notify the user
    GenericSnackBar().showCustomSnackBar(
        null, context, 'Promo code $promoCode copied', true);
  }

  //SIGN OUT
  bool _isLogOutLoading = false;
  bool get isLogOutLoading => _isLogOutLoading;

  void confirmRemove(
    context,
  ) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return BottomRemoveSheet(
          headerText: 'Sign out',
          description: 'Are you sure you want to logout?',
          action: 'Continue',
          isMiniaturized: false,
          isCartView: false,
          onTap: () async {
            _isLogOutLoading = true;
            notifyListeners();

            try {
              // Close the bottom sheet first
              Navigator.of(context).pop();

              // Remove user data and sign out
              var removeUserData =
                  Provider.of<ProfileViewController>(context, listen: false)
                      .removeUserData();
              await removeUserData;
              await _auth.signOut();

              // Navigate to PhoneAuthView and remove all routes
              Future.delayed(const Duration(milliseconds: 300), () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => PhoneAuthView()),
                  (route) => false,
                ); // Apply system chrome settings
                SystemNavigation().applyCustomSystemChromeSettings(Colors.white,
                    Brightness.dark, Colors.white, Brightness.dark);
              });
            } on FirebaseAuthException catch (e) {
              GenericSnackBar()
                  .showCustomSnackBar(null, context, e.message!, true);
            } finally {
              _isLogOutLoading = false;
              notifyListeners();
            }
          },
        );
      },
    );
  }
}
