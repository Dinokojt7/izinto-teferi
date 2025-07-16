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

class AddressSettings extends StatefulWidget {
  const AddressSettings({Key? key}) : super(key: key);

  @override
  _AddressSettingsState createState() => _AddressSettingsState();
}

class _AddressSettingsState extends State<AddressSettings> {
  //Autocomplete variables
  String address = '';
  String autocompletePlace = '';
  Prediction? initialValue;

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
                      child: PlacesAutocomplete(
                        hideOnEmpty: false,
                        searchController: _controller,
                        apiKey: AppConstants.PLACES_API,
                        components: [Component(Component.country, "za")],
                        mounted: mounted,
                        showBackButton: false,
                        onGetDetailsByPlaceId: (PlacesDetailsResponse? result) {
                          if (result != null) {
                            setState(() {
                              autocompletePlace =
                                  result.result.formattedAddress ?? "";
                              var output = autocompletePlace.split(',');
                              searchResults = output;
                              print(output);
                            });
                            if (searchResults[1] == 'Midrand' ||
                                searchResults[1] == 'midrand') {
                              print('this approach is not working');
                              Get.to(() => const PlaceNotSupported(),
                                  transition: Transition.fade,
                                  duration: Duration(seconds: 1));
                            } else {
                              _getAddressFromSearch();
                              Get.to(() => const CarVenueSettings(),
                                  transition: Transition.fade,
                                  duration: Duration(seconds: 1));

                              setState(() {
                                autocompletePlace =
                                    result.result.formattedAddress ?? "";
                                var output = autocompletePlace.split(',');
                                searchResults = output;
                                print(output);
                              });
                            }
                          }
                        },
                      ),
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
                                components: [
                                  Component(Component.country, "za")
                                ],
                                canPopOnNextButtonTaped: true,
                                currentLatLng: LatLng(lat, long),
                                onNext: (GeocodingResult? result) {
                                  if (result != null) {
                                    setState(() {
                                      _getAddressFromSearch();
                                      address = result.formattedAddress ?? "";
                                      var output = autocompletePlace.split(',');
                                      searchResults = output;
                                    });
                                  }
                                },
                                onSuggestionSelected:
                                    (PlacesDetailsResponse? result) {
                                  if (result != null) {
                                    setState(() {
                                      _getAddressFromSearch();
                                      autocompletePlace =
                                          result.result.formattedAddress ?? "";
                                      var output = autocompletePlace.split(',');
                                      searchResults = output;
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
}

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
                          text: _country!,
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
