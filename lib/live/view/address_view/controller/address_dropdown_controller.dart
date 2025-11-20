import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:izinto/live/utilities/generic_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/map_function.dart';
import '../../home_view/home_view.dart';
import '../../profile_view/controller/profile_view_controller.dart';
import '../save_address.dart';

class MainAddressViewController extends ChangeNotifier {
  // UI State Management
  bool _isDropdownOpen = false;
  bool get isDropdownOpen => _isDropdownOpen;

  bool _startAddressSearch = false;
  bool get startAddressSearch => _startAddressSearch;

  bool _isAddressDialogLoading = false;
  bool get isAddressDialogLoading => _isAddressDialogLoading;

  bool _isSaveAddressButtonLoading = false;
  bool get isSaveAddressButtonLoading => _isSaveAddressButtonLoading;

  bool _hasData = false;
  bool get hasData => _hasData;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  bool _hasNewLabel = false;
  bool get hasNewLabel => _hasNewLabel;

  bool _isValidAddress = false;
  bool get isValidAddress => _isValidAddress;

  bool _isGuestAccess = true;
  String _navigationSource = 'guest';

  // Location Data
  LatLng _initialPosition = const LatLng(-26.056, 28.060);
  LatLng get initialPosition => _initialPosition;

  double? _latitude;
  double? _longitude;
  String _address = '';

  // Address Components
  String _street = 'Rivonia Blvd';
  String get street => _street;

  String _suburb = 'Rivonia Village';
  String get suburb => _suburb;

  String _zipCode = '2499';
  String get zipCode => _zipCode;

  String _town = 'Sandton';
  String get town => _town;

  String _country = 'South Africa';
  String get country => _country;

  String _label = '';
  String get label => _label;

  String _customLabel = 'Add new label...';
  String get customLabel => _customLabel;

  String _additionalInfo = 'Additional info';
  String get additionalInfo => _additionalInfo;

  String _searchStatusText = '';
  String get searchStatusText => _searchStatusText;

  String _autocompletePlace = '';
  String get autocompletePlace => _autocompletePlace;

  List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;

  Map<String, dynamic> _newAddress = {};
  Map<String, dynamic> get newAddress => _newAddress;

  // Controllers
  TextEditingController additionalDetailsController = TextEditingController();
  TextEditingController addressLabelController = TextEditingController();

  // Loader Management
  Future<void> setInitialLoader() async {
    _startAddressSearch = true;
    await disposeSearchAddressLoader();
    notifyListeners();
  }

  Future<void> restartLoader() async {
    _startAddressSearch = false;
    notifyListeners();
  }

  Future<void> initiateSearch(bool isGuestAccess) async {
    await requestLocationPermission();
    isGuestAccess
        ? await setInitialLoader()
        : await disposeSearchAddressLoader();
    disposeDialog();
    notifyListeners();
  }

  Future<void> setIsLoading() async {
    _isAddressDialogLoading = !_isAddressDialogLoading;
    notifyListeners();
  }

  Future<void> disposeSearchAddressLoader() async {
    _isAddressDialogLoading = false;
    _isSaveAddressButtonLoading = false;
    notifyListeners();
  }

  Future<void> setSaveButtonLoader() async {
    _isSaveAddressButtonLoading = !_isSaveAddressButtonLoading;
    notifyListeners();
  }

  Future<void> setSaveButtonLoaderOff(context) async {
    final _profileController =
        Provider.of<ProfileViewController>(context, listen: false);
    await _profileController.resetAddressDetailsFields();
    _label = '';
    await setIsLoading();
    await disposeSearchAddressLoader();
    notifyListeners();
    await Get.to(
      () => SaveAddress(addressLabel: _autocompletePlace),
      transition: Transition.fade,
      duration: const Duration(seconds: 1),
    );
    _isSaveAddressButtonLoading = false;
    notifyListeners();
  }

  // Label Management
  Future<void> setTextInput() async {
    _isTyping = true;
    notifyListeners();
  }

  Future<void> clearInput() async {
    _isTyping = false;
    notifyListeners();
  }

  Future<void> setNewLabel() async {
    _isTyping = false;
    notifyListeners();
    if (addressLabelController.text.isNotEmpty) {
      final newLabel = addressLabelController.text;
      await setAddressLabel(newLabel, true);
      notifyListeners();
    }
  }

  Future<void> setAddressLabel(String labelName, bool isNewLabel) async {
    if (isNewLabel) {
      _hasNewLabel = true;
      _label = labelName;
    } else {
      _hasNewLabel = false;
      _customLabel = 'Add new label...';
      _label = labelName;
    }
    notifyListeners();
  }

  // Address Dialog Management
  void hasMadeSelection() {
    _hasData = true;
    notifyListeners();
  }

  void disposeDialog() {
    _hasData = false;
    notifyListeners();
  }

  // Location Permission and Initialization
  Future<void> requestLocationPermission() async {
    await setInitialLoader();

    try {
      final LocationPermission permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        await _handleLocationError('Location permission denied');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        await _handleLocationError('Location permission permanently denied');
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final LatLng latLng = LatLng(position.latitude, position.longitude);
      _initialPosition = latLng;
      notifyListeners();
    } catch (e) {
      await _handleLocationError('Error getting location: $e');
    }
  }

  Future<void> _handleLocationError(String error) async {
    _startAddressSearch = false;
    _isAddressDialogLoading = false;
    notifyListeners();
  }

  // Address Parsing and Assignment
  Future<void> _assignAddressValues(Placemark placemark) async {
    try {
      _street = _getStreetAddress(placemark);
      _suburb =
          placemark.subLocality ?? placemark.locality ?? 'Rivonia Village';
      _town =
          placemark.locality ?? placemark.subAdministrativeArea ?? 'Sandton';
      _zipCode = placemark.postalCode ?? '2499';
      _country = placemark.country ?? 'South Africa';

      print(
          'Parsed address - Street: $_street, Suburb: $_suburb, Town: $_town, Zip: $_zipCode, Country: $_country');
    } catch (e) {
      await _handleAddressParsingError('Failed to parse address: $e');
    }
  }

  String _getStreetAddress(Placemark placemark) {
    final List<String> streetParts = [];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      streetParts.add(placemark.street!);
    }

    if (placemark.name != null &&
        placemark.name!.isNotEmpty &&
        placemark.name != placemark.street) {
      streetParts.add(placemark.name!);
    }

    return streetParts.isNotEmpty ? streetParts.join(', ') : '';
  }

  bool _isWithinRadius(double userLat, double userLng) {
    try {
      final double distanceInMeters =
          Geolocator.distanceBetween(userLat, userLng, -26.056, 28.060);
      final double distanceInKm = distanceInMeters / 1000;
      return distanceInKm <= 20;
    } catch (e) {
      return false;
    }
  }

  // Main Address Autocomplete Method
  Future<void> onAddressAutocomplete(
      String address, double latitude, double longitude) async {
    try {
      _address = address;
      _latitude = latitude;
      _longitude = longitude;
      _autocompletePlace = address;

      // Get placemark from coordinates
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;
        await _assignAddressValues(placemark);

        // Validate address and set status
        _isValidAddress = _isWithinRadius(latitude, longitude);
        _searchStatusText = _isValidAddress
            ? '\u{1F60E} Yay we\'re available in your area!'
            : '\u{1F494} Oops! we\'re not available in this area!';

        // Update UI
        _hasData = true;
        notifyListeners();

        print(
            'Address successfully processed: $_street, $_suburb, $_town, $_zipCode');
      } else {
        await _handleAddressParsingError('No placemark found for coordinates');
      }
    } catch (e) {
      await _handleAddressParsingError('Failed to process address: $e');
    }
  }

  Future<void> _handleAddressParsingError(String error) async {
    _hasData = false;
    _street = '';
    _suburb = '';
    _town = '';
    _zipCode = '';
    _country = 'South Africa';
    _isValidAddress = false;
    _searchStatusText = 'Unable to process address';
    notifyListeners();
  }

  // Dropdown Management
  void selectLabel() {
    _isDropdownOpen = !_isDropdownOpen;
    notifyListeners();
  }

  void clearLabel() {
    _isDropdownOpen = false;
    notifyListeners();
  }

  Future<void> selectAddress(BuildContext context, Widget child) async {
    await Get.to(
      () => child,
      transition: Transition.fade,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> captureAddressDetails() async {
    _additionalInfo = additionalDetailsController.text;
    notifyListeners();
  }

  // Navigation Source Management
  void setNavigationSource(String source) {
    _navigationSource = source;
    notifyListeners();
  }

  bool setGuestAccessAddressSave() {
    _isGuestAccess = false;
    notifyListeners();
    return true;
  }

  // Address Saving
  Future<void> saveSelectedAddress(BuildContext context) async {
    try {
      final profileController =
          Provider.of<ProfileViewController>(context, listen: false);
      final addressController =
          Provider.of<MainAddressViewController>(context, listen: false);

      // Validate required fields
      if (addressController.street.isEmpty) {
        _showErrorSnackBar(context, 'Street address is required');
        return;
      }

      // Create new address from the form data
      final Map<String, dynamic> newAddress = {
        'street': addressController.street,
        'zip': addressController.zipCode,
        'suburb': addressController.suburb,
        'Town': addressController.town,
        'Country': addressController.country,
        'label': addressController.label.isNotEmpty
            ? addressController.label
            : 'Home',
        'selected': true,
        'additional info': addressController.additionalInfo,
      };

      // Save the new address
      await profileController.addNewAddress(newAddress);

      _handleSaveSuccess(context);
    } catch (error) {
      _showErrorSnackBar(context, 'Failed to add address: $error');
    }
  }

  void _handleSaveSuccess(BuildContext context) {
    if (_navigationSource == 'guest') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeView()),
        (Route<dynamic> route) => false,
      );
    } else {
      // For regular users - show snackbar and pop
      GenericSnackBar().showCustomSnackBar(
        null,
        context,
        'Address added successfully',
        false,
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Add to MainAddressViewController class

// Local storage keys
  static const String _guestAddressKey = 'guest_address';
  static const String _guestLocationKey = 'guest_location';

// Guest address persistence methods
  Future<void> saveGuestAddressToLocalStorage() async {
    try {
      final Map<String, dynamic> guestAddress = {
        'street': _street,
        'suburb': _suburb,
        'zipCode': _zipCode,
        'town': _town,
        'country': _country,
        'latitude': _latitude,
        'longitude': _longitude,
        'address': _address,
        'savedAt': DateTime.now().toIso8601String(),
      };

      final Map<String, dynamic> guestLocation = {
        'latitude': _latitude,
        'longitude': _longitude,
      };

      // Save to local storage (using shared_preferences or similar)
      await _saveToLocalStorage(_guestAddressKey, guestAddress);
      await _saveToLocalStorage(_guestLocationKey, guestLocation);
    } catch (e) {}
  }

  Future<void> loadGuestAddressFromLocalStorage() async {
    try {
      final Map<String, dynamic>? savedAddress =
          await _getFromLocalStorage(_guestAddressKey);

      if (savedAddress != null) {
        _street = savedAddress['street'] ?? '';
        _suburb = savedAddress['suburb'] ?? '';
        _zipCode = savedAddress['zipCode'] ?? '';
        _town = savedAddress['town'] ?? '';
        _country = savedAddress['country'] ?? 'South Africa';
        _latitude = savedAddress['latitude'];
        _longitude = savedAddress['longitude'];
        _address = savedAddress['address'] ?? '';

        // Validate the loaded address
        if (_latitude != null && _longitude != null) {
          _isValidAddress = _isWithinRadius(_latitude!, _longitude!);
          _searchStatusText = _isValidAddress
              ? '\u{1F60E} Yay we\'re available in your area!'
              : '\u{1F494} Oops! we\'re not available in this area!';
          _hasData = true;
        }

        notifyListeners();
      }
    } catch (e) {}
  }

  Future<void> clearGuestAddress() async {
    await _removeFromLocalStorage(_guestAddressKey);
    await _removeFromLocalStorage(_guestLocationKey);

    // Reset address fields
    _street = '';
    _suburb = '';
    _zipCode = '';
    _town = '';
    _country = 'South Africa';
    _latitude = null;
    _longitude = null;
    _address = '';
    _hasData = false;
    _isValidAddress = false;

    notifyListeners();
  }

// Helper methods for local storage (you'll need to implement these based on your storage solution)
  Future<void> _saveToLocalStorage(String key, dynamic value) async {
    // Example using shared_preferences - install package: shared_preference
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is Map<String, dynamic>) {
      await prefs.setString(key, json.encode(value));
    }

    // For now, using a simple Map in memory (will reset on app restart)
    // In production, use shared_preferences or hive for persistence
    _localStorage[key] = value;
  }

  Future<Map<String, dynamic>?> _getFromLocalStorage(String key) async {
    // Example using shared_preferences

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(key);
    if (data != null) {
      return Map<String, dynamic>.from(json.decode(data));
    }
    return null;

    // For memory storage
    return _localStorage[key];
  }

  Future<void> _removeFromLocalStorage(String key) async {
    // Example using shared_preferences
    /*
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
  */

    // For memory storage
    _localStorage.remove(key);
  }

// Temporary in-memory storage (replace with actual persistence)
  final Map<String, dynamic> _localStorage = {};

// Update the existing saveGuestAddress method
  Future<void> saveGuestAddress(BuildContext context) async {
    try {
      final addressController =
          Provider.of<MainAddressViewController>(context, listen: false);

      // Validate required fields
      if (addressController.street.isEmpty) {
        _showErrorSnackBar(context, 'Street address is required');
        return;
      }

      // Save to local storage for persistence
      await saveGuestAddressToLocalStorage();

      // Create new address from the form data
      final Map<String, dynamic> newAddress = {
        'street': addressController.street,
        'zip': addressController.zipCode,
        'suburb': addressController.suburb,
        'Town': addressController.town,
        'Country': addressController.country,
        'label': addressController.label.isNotEmpty
            ? addressController.label
            : 'Home',
        'selected': true,
        'additional info': addressController.additionalInfo,
        'latitude': _latitude,
        'longitude': _longitude,
        'isGuestAddress': true,
      };

      _newAddress = newAddress;

      _handleSaveSuccess(context);
    } catch (error) {
      _showErrorSnackBar(context, 'Failed to add address: $error');
    }
  }

// Add a method to check if guest has saved address
  Future<bool> hasGuestAddress() async {
    final savedAddress = await _getFromLocalStorage(_guestAddressKey);
    return savedAddress != null && savedAddress['street'] != null;
  }

  @override
  void dispose() {
    additionalDetailsController.dispose();
    addressLabelController.dispose();

    // Clear async loaders if running
    if (_startAddressSearch) {
      disposeSearchAddressLoader();
    }

    super.dispose();
  }
}
