import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../services/map_function.dart';
import '../../../models/rudimentary_address_model.dart';
import '../../../utilities/generic_system_navigation.dart';
import '../../home_view/home_view.dart';
import '../save_address.dart';

class MainAddressViewController extends ChangeNotifier {
  bool _isDropdownOpen = false;
  bool get isDropdownOpen => _isDropdownOpen;

  //Add current user position
  late LatLng _initialPosition;
  LatLng get initialPosition => _initialPosition;

  //Initiate address search loader
  bool _startAddressSearch = false;
  bool get startAddressSearch => _startAddressSearch;

  Future<void> setInitialLoader() async {
    _startAddressSearch = true;
    _disposeSearchAddressLoader();
    notifyListeners();
  }

  Future<void> restartLoader() async {
    _startAddressSearch = false;
    notifyListeners();
  }

  Future<void> initiateSearch(bool isGuestAccess) async {
    await requestLocationPermission();
    isGuestAccess ? setInitialLoader() : _disposeSearchAddressLoader();
    disposeDialog();
    notifyListeners();
  }

  //Add address page loader
  bool _isAddressDialogLoading = false;
  bool get isAddressDialogLoading => _isAddressDialogLoading;

  Future<void> setIsLoading() async {
    _isAddressDialogLoading = !_isAddressDialogLoading;
    notifyListeners();
  }

  Future<void> _disposeSearchAddressLoader() async {
    _isAddressDialogLoading = false;
    _isSaveAddressButtonLoading = false;
    notifyListeners();
  }

  //Save address page loader
  bool _isSaveAddressButtonLoading = false;
  bool get isSaveAddressButtonLoading => _isSaveAddressButtonLoading;

  Future<void> setSaveButtonLoader() async {
    _isSaveAddressButtonLoading = !_isSaveAddressButtonLoading;
    notifyListeners();
  }

  Future<void> setSaveButtonLoaderOff() async {
    setIsLoading();
    await _disposeSearchAddressLoader();
    notifyListeners();
    await Get.to(
        () => SaveAddress(
              addressLabel: _autocompletePlace,
            ),
        transition: Transition.fade,
        duration: Duration(seconds: 1));
    _isSaveAddressButtonLoading = false;
    notifyListeners();
  }

  //Search address
  //TextEditingController searchController = TextEditingController();
  String _autocompletePlace = '';
  String get autocompletePlace => _autocompletePlace;
  List _searchResults = [];
  List get searchResults => _searchResults;
  bool _hasData = false;
  bool get hasData => _hasData;

  //Selected address values
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
  bool _isValidAddress = false;
  bool get isValidAddress => _isValidAddress;

  TextEditingController additionalDetailsController = TextEditingController();
  TextEditingController addressLabelController = TextEditingController();

  //For labeling address
  bool _isTyping = false;
  bool get isTyping => _isTyping;
  bool _hasNewLabel = false;
  bool get hasNewLabel => _hasNewLabel;

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
      var newLabel = addressLabelController.text;
      await setAddressLabel(newLabel, true);

      notifyListeners();
    }
  }

  Future<void> setAddressLabel(String labelName, isNewLabel) async {
    if (isNewLabel) {
      _hasNewLabel = true;
      _label = labelName;
      notifyListeners();
    } else {
      _hasNewLabel = false;
      _customLabel = 'Add new label...';
      _label = labelName;
      notifyListeners();
    }
  }

  ///Show address details dialog
  void hasMadeSelection() {
    _hasData = true;
    notifyListeners();
  }

  ///Dispose address details dialog
  void disposeDialog() {
    _hasData = false;
    notifyListeners();
  }

  Future<void> _assignAddressValues(output) async {
    ///From the format of street, suburb, town, zip code, country we set these parameters

    if (output.length >= 4) {
      for (String addressEntry in output) {
        if (addressEntry.toLowerCase().contains(' rd') ||
            addressEntry.toLowerCase().contains(' road') ||
            addressEntry.toLowerCase().contains(' ave') ||
            addressEntry.toLowerCase().contains(' avenue') ||
            addressEntry.toLowerCase().contains(' st') ||
            addressEntry.toLowerCase().contains(' street')) {
          _street = addressEntry;
          _suburb = output[2];
          _town = output[3];
          _zipCode = output[4];
        } else {
          _street = output[0];
          _suburb = output[1];
          _town = output[2];
          _zipCode = output[3];
          print('Check zip: $zipCode');
        }
      }
    } else if (output.length < 4) {
      _street = output[0];
      _suburb = output[1];
    }
  }

  bool _isWithinRadius(double userLat, double userLang) {
    //Calculate the distance between the user's location and base address
    double distanceInMeters =
        Geolocator.distanceBetween(userLat, userLang, -26.056, 28.060);

    //Convert distance to kilometers
    double distanceInKm = distanceInMeters / 1000;

    //Return true if the distance is within radius, false otherwise
    return distanceInKm <= 20;
  }

  Future<void> requestLocationPermission() async {
    await setInitialLoader();
    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    LatLng latLng = LatLng(position.latitude, position.longitude);
    _initialPosition = latLng;
  }

  Future<void> onAddressAutocomplete(String placesDetails, lat, lng) async {
    _autocompletePlace = placesDetails;
    final userLat = lat;
    final userLng = lng;
    var output = autocompletePlace.split(',');
    _searchResults = output;
    print('Here are the available address values: $output');

    await _assignAddressValues(output);
    _isValidAddress = await _isWithinRadius(userLat!, userLng!);
    if (_isValidAddress) {
      _searchStatusText = '\u{1F60E} We deliver to you!';
    } else {
      _searchStatusText = '\u{1F494} We don\'t deliver to you yet!';
    }
    hasMadeSelection();

    notifyListeners();
  }

  void selectLabel() {
    _isDropdownOpen = !_isDropdownOpen;
    notifyListeners();
  }

  void clearLabel() {
    _isDropdownOpen = false;
    notifyListeners();
  }

  Future<void> selectAddress(context, child) async {
    await Get.to(() => child,
        transition: Transition.fade, duration: Duration(seconds: 1));
  }

  Future<void> captureAddressDetails() async {
    _additionalInfo = additionalDetailsController.text;
    notifyListeners();
  }

  ///Newly added address for unauthenticated user
  Map<String, dynamic> _newAddress = {};
  Map<String, dynamic> get newAddress => _newAddress;

  Future<void> saveSelectedAddress() async {
    if (_autocompletePlace != '') {
      await setSaveButtonLoader();
      _newAddress = {
        'street': _street,
        'zip': _zipCode,
        'suburb': _suburb,
        'Town': _town,
        'Country': _country,
        'label': _label,
        'selected': true,
        'additional info': _additionalInfo,
      };

      print('Pre-saved address: $_newAddress');

      notifyListeners();
    } else {
      print('address not available');
    }
  }

  @override
  void dispose() {
    additionalDetailsController.dispose();
    addressLabelController.dispose();

    // Clear async loaders if running
    if (_startAddressSearch) {
      _disposeSearchAddressLoader();
      requestLocationPermission();
    }

    super.dispose();
  }

// {
// 'street': 'b. d. Hauptfeuerwache 1',
// 'zip': '20099',
// 'suburb': 'Hamburg',
// 'Town': 'Johannesburg',
// 'Country': 'South Africa',
// 'label': 'Office',
// 'selected': false,
// 'additional info': null
// },

// _getAddressFromElement() async {
//   User? user = await _firebaseAuth.currentUser;
//   FirebaseFirestore.instance
//       .collection('users')
//       .doc(user?.uid)
//       .collection("Addresses")
//       .doc('selected address')
//       .set({
//     'street': _searchResults[0],
//     'address': _searchResults[1],
//     'area': _searchResults[2],
//     'province': _searchResults[1],
//     'country': _searchResults[4],
//     'postal Code': _searchResults[3],
//     'createdAt': Timestamp.now(),
//   });
// }

// @override
// void dispose() {
//   searchController.dispose();
//   _searchController.dispose();
//   super.dispose();
// }
}

// void _showAddNewLabelDialog() {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       String? customLabel;
//       return AlertDialog(
//         title: Text('Add New Label'),
//         content: TextField(
//           onChanged: (value) {
//             customLabel = value;
//           },
//           decoration: InputDecoration(
//             hintText: 'Enter label',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               if (customLabel != null && customLabel!.isNotEmpty) {
//                 // setState(() {
//                 //   selectedOption = customLabel;
//                 // });
//               }
//               Navigator.of(context).pop();
//             },
//             child: Text('ADD'),
//           ),
//         ],
//       );
//     },
//   );
// }
