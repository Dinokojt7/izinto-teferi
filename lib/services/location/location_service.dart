import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';

import 'location_model.dart';

class LocationServer {
  UserLocation? _currentLocation;
  Location location = Location();

  //Continuously update location
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>.broadcast();

  LocationServer() {
    location.requestPermission().then((value) {
      location.onLocationChanged.listen((locationData) {
        if (locationData != null) {
          _locationController.add(UserLocation(
              longitude: locationData.latitude!,
              latitude: locationData.longitude!));
        }
      });
    });
  }

  Stream<UserLocation> get locationStream => _locationController.stream;

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
          longitude: userLocation.latitude!, latitude: userLocation.longitude!);
    } catch (e) {
      print('Could not get this location: $e');
    }

    return _currentLocation!;
  }
}
