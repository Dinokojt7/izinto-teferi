import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:izinto/live/utilities/generic_snackbar.dart';
import 'package:provider/provider.dart';

import '../../../../services/map_function.dart';
import '../../../models/rudimentary_address_model.dart';
import '../../../utilities/generic_system_navigation.dart';
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
  String _street = '';
  String get street => _street;

  String _suburb = '';
  String get suburb => _suburb;

  String _zipCode = '';
  String get zipCode => _zipCode;

  String _town = '';
  String get town => _town;

  String _country = 'South Africa';
  String get country => _country;

  String _label = '';
  String get label => _label;

  String _customLabel = 'Add new label...';
  String get customLabel => _customLabel;

  String _additionalInfo = 'Additional info (building, floor...)';
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
    await _disposeSearchAddressLoader();
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
        : await _disposeSearchAddressLoader();
    disposeDialog();
    notifyListeners();
  }

  Future<void> setIsLoading() async {
    _isAddressDialogLoading = !_isAddressDialogLoading;
    notifyListeners();
  }

  Future<void> _disposeSearchAddressLoader() async {
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
    await _disposeSearchAddressLoader();
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
        print('Location permission denied');
        await _handleLocationError('Location permission denied');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied');
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
      print('Error getting location: $e');
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
      _suburb = placemark.subLocality ?? placemark.locality ?? '';
      _town = placemark.locality ?? placemark.subAdministrativeArea ?? '';
      _zipCode = placemark.postalCode ?? '';
      _country = placemark.country ?? 'South Africa';

      print(
          'Parsed address - Street: $_street, Suburb: $_suburb, Town: $_town, Zip: $_zipCode, Country: $_country');
    } catch (e) {
      print('Error assigning address values: $e');
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
      print('Error calculating distance: $e');
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
      print('Error in onAddressAutocomplete: $e');
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
      print('Error saving address: $error');
      _showErrorSnackBar(context, 'Failed to add address: $error');
    }
  }

  void _handleSaveSuccess(BuildContext context) {
    if (_navigationSource == 'guest') {
      SystemNavigation().applyCustomSystemChromeSettings(
          Colors.black, Brightness.light, Colors.black, Brightness.light);
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

  @override
  void dispose() {
    additionalDetailsController.dispose();
    addressLabelController.dispose();

    // Clear async loaders if running
    if (_startAddressSearch) {
      _disposeSearchAddressLoader();
    }

    super.dispose();
  }
}
