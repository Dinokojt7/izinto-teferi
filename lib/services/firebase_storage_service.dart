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
  final CollectionReference promoCodeCollection =
      FirebaseFirestore.instance.collection('promo_codes'); // Add this

  //These parameters must be put in a consistent sequence otherwise they will be mixed up in the database
  Future updateUserData(
    String? name,
    String? surname,
    String? phone,
    String? email,
    String? subStatus,
    double? iTokens,
    String? promoCode, {
    bool termsAccepted = false,
    DateTime? termsAcceptedAt,
  }) async {
    // First, create the user document
    await izintoCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'surname': surname,
      'phone': phone,
      'email': email,
      'loyalty': iTokens,
      'termsAccepted': termsAccepted,
      'isNewUser': true,
      'telephoneSurveyConsent': false,
      'emailMarketingConsent': false,
      'termsAcceptedAt': termsAcceptedAt ?? FieldValue.serverTimestamp(),
      'createdAt': Timestamp.now(),
      'promo code': promoCode,
      'wallet': 0, // Initialize wallet
    });

    // Then, save the promo code to promo_codes collection
    if (promoCode != null && promoCode.isNotEmpty) {
      await _savePromoCodeToCollection(promoCode);
    }
  }

  // Save promo code to promo_codes collection
  Future<void> _savePromoCodeToCollection(String promoCode) async {
    try {
      await promoCodeCollection.doc(promoCode).set({
        'code': promoCode,
        'ownerUserId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'timesUsed': 0,
        'totalRewardsGiven': 0,
      });
      print('✅ Promo code saved to promo_codes collection: $promoCode');
    } catch (e) {
      print('❌ Error saving promo code to collection: $e');
    }
  }

  // specialties list from snapshot
  List<SpecialtyModel> _laundryListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return SpecialtyModel(
        name: doc['name'] ?? '',
        id: doc['id'] ?? 0,
        introduction: doc['introduction'] ?? '',
        price: doc['price'] ?? 0,
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
