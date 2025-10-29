import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../utilities/generic_snackbar.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../../widgets/bottom_remove_sheet.dart';
import '../../../wrapper.dart';
import '../../auth_view/phone_auth_view.dart';

class ProfileViewController extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //User saved addresses
  List _savedAddresses = [];

  List get savedAddresses => _savedAddresses;
  String _defaultAdditionalInfoText = 'Additional info (building, floor...)';

  String get defaultAdditionalInfoText => _defaultAdditionalInfoText;
  bool _isUserInfoIncomplete = false;

  bool get isUserinfoIncomplete => _isUserInfoIncomplete;

  Future<void> saveNewAddress(Map<String, dynamic> newAddress) async {
    _savedAddresses.add(newAddress);
    notifyListeners();

    // 👇 Replace this with however you get the current user ID (can be null)
    final String? userId = _auth.currentUser?.uid;

    if (userId != null && userId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .add({
          ...newAddress,
          'timestamp': DateTime.now().toIso8601String(),
        });

        debugPrint("✅ Address saved to Firebase for user: $userId");
      } catch (e) {
        debugPrint("🔥 Failed to save address to Firebase: $e");
      }
    } else {
      debugPrint("⚠️ No user logged in. Skipping Firebase save.");
    }
  }

  void promptProfileForm() {
    _isUserInfoIncomplete = true;
    notifyListeners();
  }

  //User profile details
  bool _isNewUser = false;
  // Update hasMissingFields logic
  bool get hasMissingFields {
    return _firstName.isEmpty ||
        _lastName.isEmpty ||
        _phoneNumber.isEmpty ||
        _emailAddress.isEmpty;
  }

  // Update isNewUser logic
  bool get isNewUser => hasMissingFields;

  String _firstName = '';

  String get firstName => _firstName;
  String _lastName = '';

  String get lastName => _lastName;
  String _phoneNumber = '';

  String get phoneNumber => _phoneNumber;
  String _emailAddress = '';

  String get emailAddress => _emailAddress;
  String _promoCode = '';

  String get promoCode => _promoCode;

  //Marketing consent options
  String _emailMarketingText =
      'I agree to receive information and news from Izinto via e-mail.';

  String get emailMarketingText => _emailMarketingText;
  String _telephoneSurveyText =
      'I agree that Izinto may contact me for customer surveys via the telephone number I have provided.';

  String get telephoneSurveyText => _telephoneSurveyText;

  //Edit profile information
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isValid = false;

  bool get isValid => _isValid;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String _errorText = '';

  String get errorText => _errorText;

  Future<void> _onPageClose(BuildContext context) async {
    _isLoading = true;
    notifyListeners(); // Immediately notify listeners about the change

    ;
  }

  bool isEmail(String input) {
    // Regular expression for validating an email address
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input);
  }

  bool isValidPhone(String phoneNumber) {
    var _isValid = false;
    if (phoneNumber.startsWith('0')) {
      _isValid = phoneNumber.length == 10;
    } else if (phoneNumber.startsWith('+27')) {
      if (phoneNumber.startsWith('+270')) {
        _isValid = phoneNumber.length == 13;
      } else if (phoneNumber[3] != '1') {
        _isValid = phoneNumber.length == 12;
      } else {
        _isValid = false;
      }
    } else if (phoneNumber.startsWith('27')) {
      if (phoneNumber.startsWith('270')) {
        _isValid = phoneNumber.length == 12;
      } else if (phoneNumber[2] != '1') {
        _isValid = phoneNumber.length == 11;
      } else {
        _isValid = false;
      }
    } else if (phoneNumber[0] != '1') {
      _isValid = phoneNumber.length == 9;
    } else {
      _isValid = false;
    }
    return _isValid;
  }

  void showExitConfirmationDialog(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return BottomRemoveSheet(
          headerText: 'Unsaved Changes',
          description:
              'You have unsaved changes. Are you sure you want to leave?',
          action: 'Yes, Leave',
          isMiniaturized: true,
          isCartView: false,
          onTap: () {
            // Update system UI
            Future.delayed(const Duration(milliseconds: 200), () {
              SystemNavigation().applyCustomSystemChromeSettings(Colors.black,
                  Brightness.light, Colors.black, Brightness.light);
            });

            // Close bottom sheet
            Navigator.of(context).pop();

            // Check if we can pop normally
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(); // Normal back navigation
            } else {
              exit(0); // Force close app if at root
            }
          },
        );
      },
    );
  }

  Future<void> updateNewUser(firstName, lastName, emailAddress, phone,
      telephoneSurveyConsent, emailMarketingConsent) async {
    _firstName = firstName;
    _lastName = lastName;
    _emailAddress = emailAddress;
    _phoneNumber = phone;
    _telephoneSurveyConsent = telephoneSurveyConsent;
    _emailMarketingConsent = emailMarketingConsent;
    notifyListeners();
    return;
  }

  Future<void> updateUserData(context) async {
    var _emailString =
        emailController.text.isNotEmpty ? emailController.text : _emailAddress;
    var _firstNameString = firstNameController.text.trim().isNotEmpty
        ? firstNameController.text
        : _firstName;
    var _lastNameString = lastNameController.text.trim().isNotEmpty
        ? lastNameController.text
        : _lastName;
    var _phoneNumberString = phoneNumberController.text.isNotEmpty
        ? phoneNumberController.text
        : _phoneNumber;

    final bool hasValidEmail = isEmail(_emailString);
    final bool hasValidPhoneNumber = isValidPhone(_phoneNumberString);

    if (hasValidEmail) {
      if (_firstNameString != '') {
        if (_lastNameString != '') {
          if (hasValidPhoneNumber) {
            _onPageClose(context);
            await saveChanges(_firstNameString, _lastNameString,
                _phoneNumberString, _emailString);

            // Update state immediately
            _isLoading = false;
            _errorText = '';
            notifyListeners();

            // Navigate without delay
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Wrapper()),
                (route) => false,
              );
            }
          } else {
            GenericSnackBar().showCustomSnackBar(
                null, context, 'Phone number entered is not valid', false);
            _errorText = 'Phone number entered is not valid';
          }
        } else {
          GenericSnackBar().showCustomSnackBar(
              null, context, 'Please enter your last name', false);
        }
      } else {
        GenericSnackBar().showCustomSnackBar(
            null, context, 'Please enter your first name', false);
      }
    } else {
      GenericSnackBar().showCustomSnackBar(
          null, context, 'Email address is not valid', false);
      _errorText = 'Email address is not valid';
    }
    notifyListeners();
  }

  List<Map<String, String>> areaOpeningHours = [
    {"Monday": "07:00 AM - 18:00 PM"},
    {"Tuesday": "07:00 AM - 18:00 PM"},
    {"Wednesday": "07:00 AM - 18:00 PM"},
    {"Thursday": "07:00 AM - 18:00 PM"},
    {"Friday": "07:00 AM - 18:00 PM"},
    {"Saturday": "08:00 AM - 18:00 PM"},
    {"Sunday": "08:00 AM - 18:00 PM"},
  ];

  Future<void> getAddresses() async {
    User? user = await _firebaseAuth.currentUser;
    _isLoading = true;
    notifyListeners();

    if (user != null) {
      try {
        // Add timeout to prevent hanging
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .get()
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException('Address fetch timed out after 10 seconds');
        });

        _savedAddresses = querySnapshot.docs.map((doc) {
          return doc.data();
        }).toList();
      } on TimeoutException catch (e) {
        print('Timeout getting addresses: $e');
        // Handle timeout - maybe show error to user or use cached data
        _savedAddresses = []; // Reset or keep previous addresses?
      } on FirebaseException catch (e) {
        print('Firebase error getting addresses: $e');
        // Handle Firebase specific errors
        _savedAddresses = [];
      } catch (e) {
        print('Unexpected error getting addresses: $e');
        // Handle any other errors
        _savedAddresses = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Function to update selected address based on index
  void updateSelectedAddress(String street) {
    // Iterate over all addresses
    for (var address in _savedAddresses) {
      // Set selected to false for the currently selected address
      if (address['selected'] == true) {
        address['selected'] = false;
      }
      // Set selected to true for the corresponding selection in the ui
      if (address['street'] == street) {
        address['selected'] = true;
      }
    }

    notifyListeners();
  }

  Future<void> updateSelectedAddressInFirebase(String street) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      // Reference the user's addresses collection
      CollectionReference addressesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses');

      // Fetch all address documents
      QuerySnapshot querySnapshot = await addressesRef.get();

      // Iterate through the documents to find and update the selected field
      for (var doc in querySnapshot.docs) {
        var addressData = doc;

        if (addressData['selected'] == true) {
          // Set previously selected address's 'selected' field to false
          await addressesRef.doc(doc.id).update({'selected': false});
        }

        if (addressData['street'] == street) {
          // Set the new selected address's 'selected' field to true
          await addressesRef.doc(doc.id).update({'selected': true});
        }
      }

      notifyListeners(); // Notify listeners to reflect changes in the UI
    } else {
      print("User is not authenticated.");
    }
  }

  Future<void> removeUserData() async {
    final cart = await Get.find<CartController>();
    cart.clear();
    cart.clearCartHistory();
    _firstName = '';
    _lastName = '';
    _emailAddress = '';
    _phoneNumber = '';
    notifyListeners();
  }

  // Add these marketing consent fields
  bool _emailMarketingConsent = false;
  bool get emailMarketingConsent => _emailMarketingConsent;

  bool _telephoneSurveyConsent = false;
  bool get telephoneSurveyConsent => _telephoneSurveyConsent;

  // Update enableChanges to sync with isNewUser
  void enableChanges() {
    var _emailString =
        emailController.text.isNotEmpty ? emailController.text : _emailAddress;
    var _firstNameString = firstNameController.text.trim().isNotEmpty
        ? firstNameController.text
        : _firstName;
    var _lastNameString = lastNameController.text.trim().isNotEmpty
        ? lastNameController.text
        : _lastName;
    var _phoneNumberString = phoneNumberController.text.isNotEmpty
        ? phoneNumberController.text
        : _phoneNumber;

    if (_firstNameString != '' &&
        _lastNameString != '' &&
        _phoneNumberString != '' &&
        _emailString != '') {
      _isValid = true;
      _isUserInfoIncomplete = false;
    } else {
      _isValid = false;
      _isUserInfoIncomplete = true;
    }
    notifyListeners();
  }

  // Add marketing consent methods
  void updateEmailMarketingConsent(bool value) {
    _emailMarketingConsent = value;
    notifyListeners();
  }

  void updateTelephoneSurveyConsent(bool value) {
    _telephoneSurveyConsent = value;
    notifyListeners();
  }

  // Update saveChanges to include marketing consents
  Future<void> saveChanges(String firstName, String lastName,
      String phoneNumber, String emailAddress) async {
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
      'name': firstName,
      'phone': phoneNumber,
      'surname': lastName,
      'email': emailAddress,
      'isNewUser': false,
      'emailMarketingConsent': _emailMarketingConsent,
      'telephoneSurveyConsent': _telephoneSurveyConsent,
      'marketingConsentUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Add delete account method
  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = _auth.currentUser;

      if (user != null) {
        // Delete user data from Firestore first
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // Delete user from Firebase Auth
        await user.delete();

        // Clear local data
        await removeUserData();

        return true; // Success
      }
      return false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Add confirm delete dialog
  void confirmDeleteAccount(BuildContext sheetContext) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: sheetContext,
      builder: (BuildContext context) {
        return BottomRemoveSheet(
          headerText: 'Delete Account',
          description:
              'Are you sure you want to delete your account? This action cannot be undone.',
          action: 'Delete Account',
          isMiniaturized: false,
          isCartView: false,
          onTap: () async {
            Navigator.of(sheetContext).pop(); // Close bottom sheet
            bool success = await deleteAccount();

            if (success) {
              // Show success message first
              GenericSnackBar().showCustomSnackBar(
                  null, sheetContext, 'Account deleted successfully', true);

              // Then navigate after a short delay
              Future.delayed(Duration(milliseconds: 1500), () {
                Navigator.pushAndRemoveUntil(
                  sheetContext,
                  MaterialPageRoute(builder: (context) => PhoneAuthView()),
                  (route) => false,
                );
              });
            } else {
              GenericSnackBar().showCustomSnackBar(
                  null, sheetContext, 'Error deleting account', false);
            }
          },
        );
      },
    );
  }

  // Update getData to load marketing consents
  Future<void> getData() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      _firstName = userData['name'] ?? '';
      _lastName = userData['surname'] ?? '';
      _emailAddress = userData['email'] ?? '';
      _promoCode = userData['promo code'] ?? '';
      _phoneNumber = userData['phone'] ?? '';
      _isNewUser = userData['isNewUser'] ?? true;
      _emailMarketingConsent = userData['emailMarketingConsent'] ?? false;
      _telephoneSurveyConsent = userData['telephoneSurveyConsent'] ?? false;
      enableChanges();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
