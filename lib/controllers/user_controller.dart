import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/app_constants.dart';

class UserController extends ChangeNotifier {
  String publicKeyTest = AppConstants.THE_HILL;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void _getData() async {
    User? user = await _firebaseAuth.currentUser;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      // setState(() {
      //   _name = userData['name'];
      //   _surname = userData['surname'];
      //   _email = userData['email'];
      // });
    });

    void _prefferedAddress() async {
      User? user = await _firebaseAuth.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection("Addresses")
          .doc('preffered address')
          .snapshots()
          .listen((userData) {
        // setState(() {
        //   _address = userData['address'];
        // });
      });
    }

    Future<String> _verifyOnServer(String reference) async {
      const String url = 'https://api.paystack.co/transaction/verify/';
      while (true) {
        try {
          Map<String, String> headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${publicKeyTest}'
          };
          http.Response response =
              await http.get(Uri.parse(url + reference), headers: headers);

          final Map body = json.decode(response.body);
          // print('Check response: ${response.statusCode} of ${response.body}');
          final String status = body['data']['status'];
          if (response.statusCode == 200) {


            return status;
            break;
          }
        } catch (e) {
          // print('This is the problem: $e');
          // return '$e';

          return 'awaiting payment';
        }
        // Pause for a short duration before making the next request
        await Future.delayed(Duration(seconds: 5));
      }
    }
  }
}
// Future.delayed(const Duration(seconds: 5), () {
// setState(() {
// isLoadingButton = false;
// showExitConfirmationDialog(carWashReference, 'Car Wash');
// showExitConfirmationDialog(laundryReference, 'Laundry');
// });
// //   if (_carWashInitialization == 5) {
// //     showExitConfirmationDialog(carWashReference, 'Car Wash');
// //   }
// if (_laundryInitialization() == 5) {
// showExitConfirmationDialog(laundryReference, 'Laundry');
// }
// });
//
//
// showExitConfirmationDialog(reference, type) async {
//   final String verify = await _verifyOnServer(reference);
//   if (verify == 'success') {
//     sendSubscription(type);
//     updateConfirmation(2, type);
//   } else {
//     updateConfirmation(0, type);
//   }
