import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:izinto/models/subscription_model.dart';

class SubscriptionMethods {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Future<SubscriptionModel> getLaundrySubscription(String id)async{
  //   var snap = await _db.collection('users').doc(id).get();
  //
  //   return SubscriptionModel.fromJson(snap.)
  //
  // }

  streamUser(String id) async {
    return _db
        .collection('users')
        .doc(id)
        .snapshots()
        .map((snap) => SubscriptionModel.fromJson(snap.data() as Map));
  }

  //AUTH CHANGE USER STREAM
  Future<Future<DocumentSnapshot<Map<String, dynamic>>>> get status async {
    User? user = await _auth.currentUser;
    return _db.collection('users').doc(user?.uid).get();
    //return _firebaseFirestore.authStateChanges().map(_userFromFirebaseUser);
  }
}
