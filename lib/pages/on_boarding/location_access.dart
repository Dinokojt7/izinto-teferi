import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/pages/options/profile_settings.dart';

import '../../services/firebase_storage_service.dart';
import '../../services/location_manager.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/texts/big_text.dart';

class LocationAccess extends StatefulWidget {
  const LocationAccess({
    Key? key,
  }) : super(key: key);

  @override
  State<LocationAccess> createState() => _LocationAccessState();
}

class _LocationAccessState extends State<LocationAccess> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _address;
  String? _street;
  String? _area;
  String? _admin;
  String? _country;
  String? _zipCode;

  @override
  void initState() {
    super.initState();
    _getCurrentAddressMan();
  }

  Future<void> initiateCarSubItems() async {
    User? user = await _auth.currentUser;
    DateTime date = DateTime.now();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Subscriptions')
        .doc('car subscription')
        .set({
      'date': date,
      'remaining washes': 0,
      'selected term': '',
      'createdAt': date,
    });
  }

  Future<void> initiateSubItems() async {
    User? user = await _auth.currentUser;
    DateTime date = DateTime.now();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('Subscriptions')
        .doc('plan')
        .set({
      'date': date,
      'remainingKilograms': 0,
      'selected term': '',
      'createdAt': Timestamp.now(),
    });
  }

  void _getCurrentAddressMan() async {
    User? user = await _auth.currentUser;
    if (user != null) {
      Position position = await determinePosition();
      print(position.latitude);
      _address = await GetAddressFromLatLong(position);
      print(_address);

      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemark[0];
      _street = '${place.street}';
      _address = '${place.subLocality}';
      _area = '${place.locality}';
      _admin = '${place.administrativeArea}';
      _country = '${place.country}';
      _zipCode = '${place.postalCode}';
      setState(() {});
    }
  }

  GetAddressFromLatLong(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark);
    Placemark place = placemark[0];
    _street = '${place.street}';
    _address = '${place.subLocality}';
    _area = '${place.locality}';
    _admin = '${place.administrativeArea}';
    _country = '${place.country}';
    _zipCode = '${place.postalCode}';

    setState(() {});
    User? user = await _auth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('preffered address')
        .set({
      'street': _street,
      'area': _area,
      'address': _address,
      'province': _admin,
      'country': _country,
      'postal Code': _zipCode,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_street == '') {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.screenWidth / 16,
                  vertical: Dimensions.height45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_sharp,
                    color: Color(0xFFCFC5A5),
                    size: Dimensions.iconSize26 * 4,
                  ),
                  Text(
                    'Location Access',
                    style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                        fontSize: Dimensions.font20),
                  ),
                  SizedBox(
                    height: Dimensions.screenHeight / 30,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.screenWidth / 16,
                    ),
                    child: Text(
                      'Please allow access to location, so we can easily collect and deliver your laundry to your home.',
                      softWrap: true,
                      style: TextStyle(
                        fontFamily: 'Hind',
                        fontWeight: FontWeight.w500,
                        fontSize: Dimensions.font16,
                        color: AppColors.titleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: Dimensions.bottomHeightBar / 1.2,
          padding: EdgeInsets.only(
              top: Dimensions.height18,
              bottom: Dimensions.height15,
              left: Dimensions.width20,
              right: Dimensions.width20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radius20 * 2),
              topRight: Radius.circular(Dimensions.radius20 * 2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: GestureDetector(
              onTap: () {
                Get.to(() => ProfileSettings(isPhoneAuth: false,),
                    transition: Transition.fade,
                    duration: Duration(seconds: 2));
              },
              child: Container(
                height: Dimensions.screenHeight / 14,
                width: Dimensions.width30 * 15,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xffCFC5A5),
                      Color(0xff9A9483),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  // color: const Color(0xff8d7053),
                ),
                child: Center(
                  child: BigText(
                    text: 'Allow',
                    size: Dimensions.font20,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return ProfileSettings(isPhoneAuth: false,);
    }
  }
}
