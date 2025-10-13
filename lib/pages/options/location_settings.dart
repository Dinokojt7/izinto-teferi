import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../services/map_function.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/location/address_details_view.dart';
import '../../widgets/miscellaneous/place_not_supported.dart';
import '../../widgets/texts/small_text.dart';
import '../../live/view/address_view/view_widgets/map_location_picker.dart';

// Custom classes to replace google_maps_webservice types
class CustomPrediction {
  final String? placeId;
  final String? description;
  final String? mainText;
  final String? secondaryText;

  CustomPrediction({
    this.placeId,
    this.description,
    this.mainText,
    this.secondaryText,
  });

  factory CustomPrediction.fromJson(Map<String, dynamic> json) {
    return CustomPrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']?['main_text'],
      secondaryText: json['structured_formatting']?['secondary_text'],
    );
  }
}

class CustomPlacesDetails {
  final String? formattedAddress;
  final double? lat;
  final double? lng;

  CustomPlacesDetails({
    this.formattedAddress,
    this.lat,
    this.lng,
  });

  factory CustomPlacesDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']?['location'];
    return CustomPlacesDetails(
      formattedAddress: json['formatted_address'],
      lat: geometry?['lat'],
      lng: geometry?['lng'],
    );
  }
}

class CustomComponent {
  final String component;
  final String value;

  CustomComponent(this.component, this.value);

  String toString() => '$component:$value';
}

class AddressSettings extends StatefulWidget {
  const AddressSettings({Key? key}) : super(key: key);

  @override
  _AddressSettingsState createState() => _AddressSettingsState();
}

class _AddressSettingsState extends State<AddressSettings> {
  //Autocomplete variables
  String address = '';
  String autocompletePlace = '';
  CustomPrediction? initialValue;

  final _controller = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('addresses');
  late Stream<QuerySnapshot> _streamUserInfo;
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';
  String _area = '';
  String _address = '';
  String _country = '';
  String _admin = '';
  String _currentStreet = '';
  String _currentAddress = '';
  String _currentArea = '';
  String _currentAdmin = '';
  String _currentCountry = '';
  String _currentZip = '';
  String _queryStreet = '';
  String _queryZipCode = '';
  String _queryCity = '';
  String _venueType = '';
  bool _isLoading = false;
  double lat = 0;
  double long = 0;

  var searchResults = [];

  @override
  void initState() {
    _prefferedAddress();
    super.initState();
    _streamUserInfo = _referenceUserInfo.snapshots();
    _deleteCurrentSelectedAddress();
    _currentLocation();
  }

  _getLatLong() async {
    User? user = await _firebaseAuth.currentUser;
    if (user != null) {
      Position position = await determinePosition();
      print(position.latitude);
      lat = position.latitude;
      long = position.longitude;
    }
  }

  _deleteCurrentSelectedAddress() async {
    // Get a reference to the document to be deleted
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('selected address')
        .delete();
  }

  void _currentLocation() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('current address')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          _currentAddress = userData['address'];
          _currentArea = userData['area'];
          _currentStreet = userData['street'];
          _currentCountry = userData['country'];
          _currentAdmin = userData['province'];
          _currentZip = userData['postal Code'];
        });
    });
  }

  void _prefferedAddress() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('preffered address')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          _venueType = userData['venueType'];
          _address = userData['address'];
          _area = userData['area'];
          _street = userData['street'];
          _country = userData['country'];
          _admin = userData['province'];
          _zipCode = userData['postal code'];
        });
    });
  }

  _getAddressFromSearch() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('selected address')
        .set({
      'street': searchResults[0],
      'address': searchResults[1],
      'area': searchResults[2],
      'province': searchResults[1],
      'country': searchResults[4],
      'postal Code': searchResults[3],
      'createdAt': Timestamp.now(),
    });
  }

  _getAddressFromCurrent() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('selected address')
        .set({
      'street': _currentStreet,
      'address': _currentAddress,
      'area': _currentArea,
      'province': _currentAdmin,
      'country': _currentCountry,
      'postal Code': _currentZip,
      'createdAt': Timestamp.now(),
    });
  }

  // Custom search method to replace PlacesAutocomplete
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    try {
      // Use geocoding package for local search
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        // Get place details from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          setState(() {
            autocompletePlace = _formatAddressFromPlacemark(placemark);
            var output = autocompletePlace.split(',');
            searchResults = output;
            print(output);
          });

          // Check if location is supported
          if (searchResults.length > 1 &&
              (searchResults[1]?.toLowerCase().contains('midrand') == true)) {
            print('this approach is not working');
            Get.to(() => const PlaceNotSupported(),
                transition: Transition.fade, duration: Duration(seconds: 1));
          } else {
            _getAddressFromSearch();
            Get.to(() => const CarVenueSettings(),
                transition: Transition.fade, duration: Duration(seconds: 1));
          }
        }
      }
    } catch (e) {
      print("Search error: $e");
    }
  }

  String _formatAddressFromPlacemark(Placemark placemark) {
    List<String> addressParts = [];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      addressParts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      addressParts.add(placemark.postalCode!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressParts.add(placemark.country!);
    }

    return addressParts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: _streamUserInfo,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          print(
            snapshot.error.toString(),
          );
          Center(
            child: Text(
              (snapshot.error.toString()),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.active) {
          QuerySnapshot querySnapshot = snapshot.data;
          return Stack(
            children: [
              Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_sharp),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  iconTheme: IconThemeData(
                      weight: 900,
                      color: AppColors.fontColor,
                      size: Dimensions.font20 * 1.5),
                  titleTextStyle: TextStyle(
                      fontSize: Dimensions.font20 * 1.5,
                      color: AppColors.fontColor,
                      fontWeight: FontWeight.w700),
                  title: Text('Addresses'),
                  centerTitle: false,
                  backgroundColor: Colors.white,
                ),
                body: Column(
                  children: [
                    Container(
                      height: 72,
                      child: _buildCustomSearchField(),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Text(
                            'Current location',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font20,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _getAddressFromCurrent();
                        Get.to(() => const CarVenueSettings(),
                            transition: Transition.fade,
                            duration: Duration(seconds: 1));
                      },
                      child: Container(
                        width: Dimensions.screenWidth / 1.08,
                        margin: EdgeInsets.symmetric(
                          horizontal: Dimensions.screenWidth / 100,
                          vertical: Dimensions.screenWidth / 70,
                        ),
                        padding: EdgeInsets.only(
                            top: Dimensions.height10,
                            bottom: Dimensions.height10,
                            left: Dimensions.screenWidth / 50,
                            right: Dimensions.screenWidth / 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 1,
                              offset: Offset(1, 2),
                            ),
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 1,
                              offset: Offset(0, -1),
                            ),
                          ],
                          border: Border.all(
                            width: 2,
                            color: Colors.white,
                          ),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius15),
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AppIcon(
                              icon: (Icons.location_on),
                              backgroundColor: Colors.white,
                              iconSize:
                                  Dimensions.height20 + Dimensions.height10,
                              size: Dimensions.height10 + Dimensions.height30,
                              iconColor: Color(0xff9A9483),
                            ),
                            Wrap(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await _getAddressFromCurrent();
                                    Get.to(() => const CarVenueSettings(),
                                        transition: Transition.fade,
                                        duration: Duration(seconds: 1));
                                  },
                                  child: CurrentLocation(
                                      currentStreet: _currentStreet,
                                      currentAddress: _currentAddress,
                                      currentArea: _currentArea,
                                      currentAdmin: _currentAdmin,
                                      currentZip: _currentZip),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: Dimensions.screenWidth / 40,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Text(
                            'Active Address',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font20,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),

                    //Active address
                    _street == ''
                        ? Container(
                            width: Dimensions.screenWidth / 1.08,
                            margin: EdgeInsets.symmetric(
                              horizontal: Dimensions.screenWidth / 100,
                              vertical: Dimensions.screenWidth / 70,
                            ),
                            padding: EdgeInsets.only(
                                top: Dimensions.height10,
                                bottom: Dimensions.height10,
                                left: Dimensions.screenWidth / 50,
                                right: Dimensions.screenWidth / 40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2.5,
                                  offset: Offset(1, 2),
                                ),
                              ],
                              border: Border.all(
                                  width: 1,
                                  color: Color(0xff9A9484).withOpacity(0.4)),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                            ),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                AppIcon(
                                  icon: (Icons.location_on),
                                  backgroundColor: Colors.white,
                                  iconSize:
                                      Dimensions.height20 + Dimensions.height10,
                                  size:
                                      Dimensions.height10 + Dimensions.height30,
                                  iconColor: Color(0xff9A9483),
                                ),
                                Wrap(
                                  children: [
                                    CurrentLocation(
                                        currentStreet: _currentStreet,
                                        currentAddress: _currentAddress,
                                        currentArea: _currentArea,
                                        currentAdmin: _currentAdmin,
                                        currentZip: _currentZip),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: Dimensions.screenWidth / 1.08,
                            margin: EdgeInsets.symmetric(
                              horizontal: Dimensions.screenWidth / 100,
                              vertical: Dimensions.screenWidth / 70,
                            ),
                            padding: EdgeInsets.only(
                                top: Dimensions.height10,
                                bottom: Dimensions.height10,
                                left: Dimensions.screenWidth / 50,
                                right: Dimensions.screenWidth / 40),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1,
                                  color: Color(0xff9A9484).withOpacity(0.4)),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                            ),
                            child: AddressDisplay(
                                venueType: _venueType,
                                street: _street,
                                address: _address,
                                area: _area,
                                admin: _admin,
                                country: _country),
                          ),
                    Spacer(),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xffA0937D)),
                      ),
                      child: const Text('Pick location'),
                      onPressed: () async {
                        await _getLatLong();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return MapLocationPicker(
                                apiKey: AppConstants.PLACES_API,
                                canPopOnNextButtonTaped: true,
                                currentLatLng: LatLng(lat, long),
                                onNext: (dynamic result) {
                                  if (result != null) {
                                    setState(() {
                                      _getAddressFromSearch();
                                      if (result is CustomGeocodingResult) {
                                        address = result.formattedAddress ?? "";
                                      }
                                    });
                                  }
                                },
                                onSuggestionSelected: (dynamic result) {
                                  if (result != null) {
                                    setState(() {
                                      _getAddressFromSearch();
                                      if (result is CustomPlacesDetails) {
                                        autocompletePlace =
                                            result.formattedAddress ?? "";
                                        var output =
                                            autocompletePlace.split(',');
                                        searchResults = output;
                                      }
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Spacer()
                  ],
                ),
              ),
            ],
          );
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: const Color(0xffB09B71),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomSearchField() {
    return Container(
      margin: EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search for an address...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              setState(() {
                autocompletePlace = '';
                searchResults = [];
              });
            },
          ),
        ),
        onSubmitted: (value) {
          _performSearch(value);
        },
      ),
    );
  }
}

// CurrentLocation and AddressDisplay classes remain the same as in your original code
class CurrentLocation extends StatelessWidget {
  const CurrentLocation({
    super.key,
    required String currentStreet,
    required String currentAddress,
    required String currentArea,
    required String currentAdmin,
    required String currentZip,
  })  : _currentStreet = currentStreet,
        _currentAddress = currentAddress,
        _currentArea = currentArea,
        _currentAdmin = currentAdmin,
        _currentZip = currentZip;

  final String _currentStreet;
  final String _currentAddress;
  final String _currentArea;
  final String _currentAdmin;
  final String _currentZip;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 3.0),
              child: IntegerText(
                text: _currentStreet,
                color: Color(0xff9A9483),
                fontWeight: FontWeight.w600,
                size: Dimensions.font16 / 1.1,
                height: 1.4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3.0),
              child: Wrap(
                children: [
                  IntegerText(
                    text: _currentAddress,
                    overFlow: TextOverflow.fade,
                    color: AppColors.titleColor,
                    height: 1.5,
                    size: Dimensions.font16 / 1.1,
                  ),
                  SizedBox(
                    width: Dimensions.width10 / 2,
                  ),
                  IntegerText(
                    text: '.',
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 0.9,
                  ),
                  SizedBox(
                    width: Dimensions.width10 / 2,
                  ),
                  IntegerText(
                    text: _currentArea,
                    maxLines: 1,
                    color: AppColors.titleColor,
                    height: 1.5,
                    size: Dimensions.font16 / 1.1,
                    overFlow: TextOverflow.fade,
                  ),
                  SizedBox(
                    width: Dimensions.width10 / 2,
                  ),
                  IntegerText(
                    text: '.',
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 0.9,
                  ),
                  SizedBox(
                    width: Dimensions.width10 / 2,
                  ),
                  IntegerText(
                    text: _currentAdmin,
                    color: AppColors.titleColor,
                    height: 1.5,
                    size: Dimensions.font16 / 1.1,
                    overFlow: TextOverflow.fade,
                  ),
                  SizedBox(
                    width: Dimensions.width10 / 2,
                  ),
                  IntegerText(
                    text: '.',
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 0.9,
                  ),
                  SizedBox(
                    width: Dimensions.width10 / 2,
                  ),
                  IntegerText(
                    text: _currentZip,
                    color: AppColors.titleColor,
                    height: 1.5,
                    size: Dimensions.font16 / 1.1,
                    overFlow: TextOverflow.fade,
                  ),
                  SizedBox(
                    width: Dimensions.width10 / 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AddressDisplay extends StatelessWidget {
  const AddressDisplay({
    Key? key,
    required String venueType,
    required String street,
    required String address,
    required String area,
    required String admin,
    required String country,
  })  : _venueType = venueType,
        _street = street,
        _address = address,
        _area = area,
        _admin = admin,
        _country = country,
        super(key: key);

  final String _venueType;
  final String _street;
  final String _address;
  final String _area;
  final String _admin;
  final String _country;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppIcon(
          icon: (_venueType == 'House'
              ? Icons.home_outlined
              : _venueType == 'Estate/Complex'
                  ? Icons.apartment_rounded
                  : Icons.store_mall_directory_outlined),
          backgroundColor: Colors.white,
          iconSize: Dimensions.height20 + Dimensions.height10,
          size: Dimensions.height10 + Dimensions.height30,
          iconColor: Color(0xff9A9483),
        ),
        Wrap(
          children: [
            Wrap(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: SmallText(
                        text: _venueType,
                        color: Color(0xff9A9483),
                        fontWeight: FontWeight.w600,
                        size: Dimensions.font16,
                        height: 1.4,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Wrap(
                        children: [
                          IntegerText(
                            text: _street,
                            overFlow: TextOverflow.fade,
                            color: AppColors.titleColor,
                            height: 1.5,
                            size: Dimensions.font16 / 1.1,
                          ),
                          SizedBox(
                            width: Dimensions.width10 / 2,
                          ),
                          IntegerText(
                            text: '.',
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                            height: 0.9,
                          ),
                          SizedBox(
                            width: Dimensions.width10 / 2,
                          ),
                          IntegerText(
                            text: _address,
                            maxLines: 1,
                            color: AppColors.titleColor,
                            height: 1.5,
                            size: Dimensions.font16 / 1.1,
                            overFlow: TextOverflow.fade,
                          ),
                          SizedBox(
                            width: Dimensions.width10 / 2,
                          ),
                          IntegerText(
                            text: '.',
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                            height: 0.9,
                          ),
                          SizedBox(
                            width: Dimensions.width10 / 2,
                          ),
                          IntegerText(
                            text: _area,
                            color: AppColors.titleColor,
                            height: 1.5,
                            size: Dimensions.font16 / 1.1,
                            overFlow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      children: [
                        IntegerText(
                          text: _admin,
                          color: AppColors.titleColor,
                          height: 1.5,
                          size: Dimensions.font16 / 1.1,
                          overFlow: TextOverflow.fade,
                        ),
                        SizedBox(
                          width: Dimensions.width10 / 2,
                        ),
                        IntegerText(
                          text: '.',
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          height: 0.9,
                        ),
                        SizedBox(
                          width: Dimensions.width10 / 2,
                        ),
                        IntegerText(
                          text: _country,
                          color: AppColors.titleColor,
                          height: 1.5,
                          size: Dimensions.font16 / 1.1,
                          overFlow: TextOverflow.fade,
                        ),
                        SizedBox(
                          width: Dimensions.width10 / 2,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          width: Dimensions.screenWidth / 40,
        ),
      ],
    );
  }
}
