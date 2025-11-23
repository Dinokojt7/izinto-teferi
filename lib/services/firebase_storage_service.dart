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
      FirebaseFirestore.instance.collection('promo_codes');

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
    try {
      // First, create the user document
      await izintoCollection.doc(uid).set({
        'uid': uid,
        'name': name ?? '',
        'surname': surname ?? '',
        'phone': phone ?? '',
        'email': email ?? '',
        'loyalty': iTokens ?? 0.0,
        'termsAccepted': termsAccepted,
        'isNewUser': true,
        'telephoneSurveyConsent': false,
        'emailMarketingConsent': false,
        'termsAcceptedAt': termsAcceptedAt ?? FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'promo code': promoCode ?? '',
        'wallet': surname == 'Reviewer' ? 120 : 0.0, // Initialize wallet
        'authProvider': 'phone', // Track authentication method
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Then, save the promo code to promo_codes collection if provided
      if (promoCode != null && promoCode.isNotEmpty) {
        await _savePromoCodeToCollection(promoCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Save promo code to promo_codes collection with enhanced error handling
  Future<void> _savePromoCodeToCollection(String promoCode) async {
    try {
      // Check if promo code already exists to avoid duplicates
      final existingCode = await promoCodeCollection.doc(promoCode).get();

      if (existingCode.exists) {
        return;
      }

      await promoCodeCollection.doc(promoCode).set({
        'code': promoCode,
        'ownerUserId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'timesUsed': 0,
        'totalRewardsGiven': 0.0,
        'ownerName': '', // Will be updated when user completes profile
        'ownerPhone': '', // Will be updated when user completes profile
        'lastUsedAt': null,
      });
    } catch (e) {
      // Don't rethrow - we don't want promo code failure to break user creation
    }
  }

  // Update promo code with user info when profile is completed
  Future<void> updatePromoCodeWithUserInfo({
    required String promoCode,
    required String userName,
    required String userSurname,
    required String userPhone,
  }) async {
    try {
      await promoCodeCollection.doc(promoCode).update({
        'ownerName': '$userName $userSurname',
        'ownerPhone': userPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  // Check if promo code exists
  Future<bool> checkPromoCodeExists(String promoCode) async {
    try {
      final doc = await promoCodeCollection.doc(promoCode).get();
      return doc.exists;
    } catch (e) {
      return false;
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
