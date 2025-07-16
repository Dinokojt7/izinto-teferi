import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:izinto/models/popular_specialty_model.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  //collection reference
  final CollectionReference izintoCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference addressCollection =
      FirebaseFirestore.instance.collection('addresses');

  final CollectionReference laundryCollection =
      FirebaseFirestore.instance.collection('laundry');

  //These parameters must be put in a consistent sequence otherwise they will be mixed up in the database
  Future updateUserData(
      String? name,
      String? surname,
      String? phone,
      String? email,
      String? subStatus,
      double? iTokens,
      String? promoCode) async {
    return await izintoCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'surname': surname,
      'phone': phone,
      'email': email,
      'loyalty': iTokens,
      'createdAt': Timestamp.now(),
      'promo code': promoCode
    });
  }

  // specialties list from snapshot
  List<SpecialtyModel> _laundryListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return SpecialtyModel(
        name: doc['name'] ?? '',
        id: doc['id'] ?? 0,
        introduction: doc['introduction'] ?? '',
        price: doc['price'] ?? 0,
        createAt: doc['createAt'] ?? '',
        turnaroundTime: doc['turnaroundTime'] ?? '',
        type: doc['type'] ?? '',
        time: doc['time'] ?? '',
        img: doc['img'] ?? '',
        material: doc['material'] ?? '',
        location: doc['location'] ?? 0.0,
        provider: doc['provider'] ?? '',
      );
    }).toList();
  }

  // get izinto streams

  Stream<List<SpecialtyModel>> get specialties {
    return laundryCollection.snapshots().map(_laundryListFromSnapshot);
  }
}
