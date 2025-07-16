import 'package:cloud_firestore/cloud_firestore.dart';

final fireStore = FirebaseFirestore.instance;
final storesSpecialtiesRF = fireStore.collection('storesSpecialties');
DocumentReference storeRF({
  required String? storeId,
  required String? specialtyId,
}) =>
    storesSpecialtiesRF.doc(storeId).collection('stores').doc(specialtyId);
