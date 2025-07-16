import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:izinto/firebase_ref/loading_status.dart';
import 'package:izinto/models/recommended_specialty_model.dart';

import '../firebase_ref/references.dart';

class DataUploader extends GetxController {
  @override
  void onReady() {
    uploadData();
    super.onReady();
  }

  final loadingStatus = LoadingStatus.loading.obs; //loadingStatus is obs

  Future<void> uploadData() async {
    loadingStatus.value = LoadingStatus.loading; //its value is 0
    final fireStore = FirebaseFirestore.instance;
    final manifestContent = await DefaultAssetBundle.of(Get.context!)
        .loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    //load json file print path
    final specialtiesInAssets = manifestMap.keys
        .where((path) =>
            path.startsWith('assets/DB/specialties') && path.contains('.json'))
        .toList();
    List<RecommendedSpecialtyModel> storesSpecialties = [];
    for (var specialty in specialtiesInAssets) {
      String stringSpecialtyContent = await rootBundle.loadString(specialty);
      storesSpecialties.add(RecommendedSpecialtyModel.fromJson(
          json.decode(stringSpecialtyContent)));
    }
    // print('Items number ${storesSpecialties[1].description}');
    var batch = fireStore.batch();

    //This part we're creating documents and fields in our firebase database
    for (var specialty in storesSpecialties) {
      batch.set(storesSpecialtiesRF.doc(specialty.id), {
        "title": specialty.name,
        "description": specialty.description,
        "stores_count": specialty.stores.length
      });

      for (var stores in specialty.stores) {
        final storePath =
            storeRF(specialtyId: specialty.id, storeId: stores.id);
        batch.set(storePath, {
          "title": stores.title,
          "thumbnail": stores.thumbnail,
          "DisplayLogo": stores.displayLogo,
          "description": stores.description,
          "location": stores.location,
        });

        for (var specialties in stores.specialties) {
          batch.set(storePath.collection('specialties').doc(specialties.name), {
            "id": specialties.id,
            "name": specialties.name,
            "introduction": specialties.introduction,
            "price": specialties.price,
            "createAt": specialties.createAt,
            "turnaroundTime": specialties.turnaroundTime,
            "img": specialties.img,
            "location": specialties.location,
            "type": specialties.type,
            "material": specialties.material,
            "provider": specialties.provider,
            "quantity": specialties.quantity,
            "time": specialties.time
          });
        }
      }
    }

    await batch.commit();
    loadingStatus.value = LoadingStatus.completed;
  }
}
