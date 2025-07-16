import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/user.dart';
import 'package:device_info_plus/device_info_plus.dart';

class UserHelper {
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  static saveUser(User user) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = int.parse(packageInfo.buildNumber);
    Map<String, dynamic> userData = {
      'name': user.displayName,
      'email': user.email,
      //'last_login': user.metadata.lastSignInTime.toString(),
      'created_at': FieldValue.serverTimestamp(),
      'role': 'user',
      'build_number': buildNumber,
    };

    final userRef = _db.collection('users').doc(user.uid);
    if ((await userRef.get()).exists) {
      await userRef.update({
        //'last_login': user.metadata.lastSignInTime.millisecondsSinceEpoch,
        'build_number': buildNumber,
      });
    } else {
      await userRef.set(userData);
    }
    await _saveDevice(user);
  }

  static _saveDevice(User user) async {
    DeviceInfoPlugin devicePlugin = DeviceInfoPlugin();
    String? deviceId;

    final _deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> deviceData;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final deviceInfo = await devicePlugin.androidInfo;

      deviceId = _deviceInfoPlugin.androidInfo.toString();
      deviceData = {
        'os_version': deviceInfo.version.sdkInt.toString(),
        'platform': 'android',
        'model': deviceInfo.model,
        "device": deviceInfo.device
      };
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final deviceInfo = await devicePlugin.iosInfo;

      deviceId = deviceInfo.identifierForVendor;
      deviceData = {
        'os_version': deviceInfo.systemVersion,
        'platform': 'ios',
        'model': deviceInfo.model,
        "device": deviceInfo.name,
      };

      final nowMs = DateTime.now().millisecondsSinceEpoch;

      final deviceRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('devices')
          .doc(deviceId);
      if ((await deviceRef.get()).exists) {
        await deviceRef.update({
          'updated_at': nowMs,
          'uninstalled': false,
        });
      } else {
        await deviceRef.set({
          'created_at': nowMs,
          'updated_at': nowMs,
          'uninstalled': false,
          'id': deviceId,
          'device_info': deviceData
        });
      }
    }
  }
}
