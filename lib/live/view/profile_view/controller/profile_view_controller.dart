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
// In ProfileViewController, add these methods:

// Update an existing address
  Future<void> updateAddress(
      int index, Map<String, dynamic> updatedAddress) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get the current addresses
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        List<dynamic> addresses = userDoc['addresses'] ?? [];

        // Update the specific address
        if (index < addresses.length) {
          addresses[index] = updatedAddress;

          // Update in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'addresses': addresses,
          });

          // Update local state
          _savedAddresses = List<Map<String, dynamic>>.from(addresses);

          // Show success message
          // You can use your snackbar utility here
        }
      }
    } catch (e) {
      print('Error updating address: $e');
      // Show error message
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // In ProfileViewController, update updateSelectedAddress method:
  void updateSelectedAddress(String street) {
    print('🔄 updateSelectedAddress called for: $street');
    print(
        '📊 Before update - selected addresses: ${_savedAddresses.where((addr) => addr['selected'] == true).length}');

    // Iterate over all addresses
    for (var address in _savedAddresses) {
      bool wasSelected = address['selected'] == true;
      address['selected'] = address['street'] == street;
      bool isNowSelected = address['selected'] == true;

      if (wasSelected != isNowSelected) {
        print(
            '📍 ${address['street']} selection changed: $wasSelected -> $isNowSelected');
      }
    }

    notifyListeners();
    print('✅ notifyListeners called');
    print(
        '📊 After update - selected addresses: ${_savedAddresses.where((addr) => addr['selected'] == true).length}');
  }

// Also update updateSelectedAddressInFirebase to call notifyListeners:
  Future<void> updateSelectedAddressInFirebase(String street) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      // First update local state
      updateSelectedAddress(street);

      // Then update Firebase
      CollectionReference addressesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses');

      QuerySnapshot querySnapshot = await addressesRef.get();

      for (var doc in querySnapshot.docs) {
        var addressData = doc.data() as Map<String, dynamic>;

        if (addressData['selected'] == true) {
          await addressesRef.doc(doc.id).update({'selected': false});
        }

        if (addressData['street'] == street) {
          await addressesRef.doc(doc.id).update({'selected': true});
        }
      }

      print('✅ Firebase updated for: $street');
    } else {
      print("❌ User is not authenticated.");
    }
  }

// Add a new address - UPDATED VERSION
  Future<void> addNewAddress(Map<String, dynamic> newAddress) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get current addresses
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        List<dynamic> addresses = userDoc['addresses'] ?? [];

        // Set all existing addresses to selected: false
        addresses = addresses.map((address) {
          return {
            ...address,
            'selected': false,
          };
        }).toList();

        // Add the new address with selected: true (or false if you prefer)
        // If you want the new address to be automatically selected:
        addresses.add({
          ...newAddress,
          'selected': true, // Set new address as selected
        });

        // Alternative: If you DON'T want new address to be automatically selected:
        // addresses.add({
        //   ...newAddress,
        //   'selected': false, // Keep existing selection
        // });

        // Update in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'addresses': addresses,
        });

        // Update local state
        _savedAddresses = List<Map<String, dynamic>>.from(addresses);
      }
    } catch (e) {
      print('Error adding address: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Delete an address
  Future<void> deleteAddress(int index) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        List<dynamic> addresses = userDoc['addresses'] ?? [];

        if (index < addresses.length) {
          addresses.removeAt(index);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'addresses': addresses,
          });

          _savedAddresses = List<Map<String, dynamic>>.from(addresses);
        }
      }
    } catch (e) {
      print('Error deleting address: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveNewAddress(Map<String, dynamic> newAddress) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Set all existing addresses to selected: false
      _savedAddresses = _savedAddresses.map((address) {
        return {
          ...address,
          'selected': false,
        };
      }).toList();

      // Add new address as selected
      _savedAddresses.add({
        ...newAddress,
        'selected': true,
      });

      notifyListeners();

      final String? userId = _auth.currentUser?.uid;

      if (userId != null && userId.isNotEmpty) {
        try {
          // First, update all existing addresses in Firebase to selected: false
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (userDoc.exists) {
            List<dynamic> firebaseAddresses = userDoc['addresses'] ?? [];

            // Update all existing addresses to selected: false
            firebaseAddresses = firebaseAddresses.map((address) {
              return {
                ...address,
                'selected': false,
              };
            }).toList();

            // Add the new address
            firebaseAddresses.add({
              ...newAddress,
              'selected': true,
              'timestamp': DateTime.now().toIso8601String(),
            });

            // Save the updated list
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({
              'addresses': firebaseAddresses,
            });
          }

          debugPrint("✅ Address saved to Firebase for user: $userId");
        } catch (e) {
          debugPrint("🔥 Failed to save address to Firebase: $e");
        }
      } else {
        debugPrint("⚠️ No user logged in. Skipping Firebase save.");
      }
    } catch (e) {
      debugPrint("Error in saveNewAddress: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to ensure only one address is selected
  void _ensureSingleSelection(String selectedStreet) {
    for (var address in _savedAddresses) {
      address['selected'] = address['street'] == selectedStreet;
    }
    notifyListeners();
  }

// In ProfileViewController - add this method
  Future<void> updateAllAddresses(List<dynamic> updatedAddresses) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update local state immediately
      _savedAddresses = List<Map<String, dynamic>>.from(updatedAddresses);

      // Update Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'addresses': updatedAddresses,
        });
      }

      print('✅ Addresses updated locally and in Firebase');
    } catch (e) {
      print('❌ Error updating addresses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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

  Future<Map<String, dynamic>?> getUserProfileData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.data();
    } catch (e) {
      print('Error getting user profile data: $e');
      return null;
    }
  }

  Future<bool> hasAddresses(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .limit(1) // Only get 1 document to check existence
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking addresses: $e');
      return false;
    }
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
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .get()
            .timeout(const Duration(seconds: 10));

        _savedAddresses = querySnapshot.docs.map((doc) {
          return doc.data();
        }).toList();

        // Ensure only one address is selected (fix any data inconsistencies)
        _ensureSingleSelectionLogic();
      } catch (e) {
        print('Error getting addresses: $e');
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

// Helper to fix multiple selected addresses
  void _ensureSingleSelectionLogic() {
    int selectedCount =
        _savedAddresses.where((addr) => addr['selected'] == true).length;

    if (selectedCount > 1) {
      // If multiple are selected, keep only the first one selected
      bool foundFirst = false;
      for (var address in _savedAddresses) {
        if (address['selected'] == true) {
          if (!foundFirst) {
            foundFirst = true;
            // Keep this one selected
          } else {
            address['selected'] = false; // Unselect the rest
          }
        }
      }
    } else if (selectedCount == 0 && _savedAddresses.isNotEmpty) {
      // If none are selected, select the first one
      _savedAddresses.first['selected'] = true;
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
              // Navigate to auth
              Navigator.pushAndRemoveUntil(
                sheetContext,
                MaterialPageRoute(builder: (context) => PhoneAuthView()),
                (route) => false,
              );
              // Show success message
              Future.delayed(Duration(milliseconds: 1500), () {
                GenericSnackBar().showCustomSnackBar(
                    null, sheetContext, 'Account deleted successfully', true);
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
