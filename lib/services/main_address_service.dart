import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AddressService extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<dynamic> _prefferedAddress() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('preffered address')
        .snapshots()
        .listen((userData) {
      update();
      (() {
        //     _address = userData['address'];
        //     _area = userData['area'];
        //     _street = userData['street'];
      });
    });
  }
}
