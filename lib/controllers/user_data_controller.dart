import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDataController extends ChangeNotifier {
  //instances
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //values
  String _name = '';
  String _surname = '';
  String _email = '';
  String _address = 'Edenburg';
  String _area = 'Rivonia';
  String _street = '17 Autumn Rd';

  String get name => _name;
  String get surname => _surname;
  String get email => _email;
  String get address => _address;
  String get area => _area;
  String get street => _street;

  Future<void> getData() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      _name = '${userData['name']} !';
      _surname = userData['surname'];
      _email = userData['email'];
      notifyListeners(); // Notify listeners after updating the data
    });
  }
}
