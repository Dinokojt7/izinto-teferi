// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_service.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Required fields for profile completion
  static const List<String> requiredProfileFields = [
    'firstName',
    'lastName',
    'gender',
    'dateOfBirth',
    'agreedToTerms',
  ];

  Future<void> _saveUserToFirestore(User user, bool isNewUser) async {
    try {
      // First, check if user document already exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && !isNewUser) {
        // User exists - only update basic auth info, don't overwrite profile data
        await _firestore.collection('users').doc(user.uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // New user - create with initial structure
        final Map<String, dynamic> userData = {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'userType': 'creator',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          // Only initialize required fields as null for truly new users
          ...(isNewUser
              ? {
                  'firstName': null,
                  'lastName': null,
                  'gender': null,
                  'dateOfBirth': null,
                  'agreedToTerms': false,
                }
              : {}),
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));

      }
    } catch (e) {

      rethrow;
    }
  }

  // Check if user profile is complete
  Future<bool> isProfileComplete(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data();
      if (data == null) return false;

      // Check all required fields
      for (String field in requiredProfileFields) {
        if (!data.containsKey(field) || data[field] == null) {
          return false;
        }

        // Special check for agreedToTerms boolean
        if (field == 'agreedToTerms' && data[field] != true) {
          return false;
        }
      }

      return true;
    } catch (e) {

      return false;
    }
  }

  // Update user profile
  Future<void> updateProfile(
    String uid,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        ...profileData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Stream<User?> get user => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  // In your AuthService class
  Future<void> handleUserLogin(User user) async {
    try {
      // Save user to Firestore
      await _saveUserToFirestore(user, false);

      // Initialize notifications and save FCM token
      final notificationService = NotificationService();
      await notificationService.initialize();
    } catch (e) {}
  }

  String getDisplayName() {
    return _auth.currentUser?.displayName ?? 'User';
  }

  String getUserInitial() {
    final name = _auth.currentUser?.displayName ?? 'U';
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Future<Map<String, dynamic>?> getUserProfileData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasAddresses() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('addresses')
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

// Usage
  // Create user document on first sign in
  Future<void> createUserDocument({
    required String userId,
    required String email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final firestoreService = FirestoreService();
      await firestoreService.createUserDocument(
        userId: userId,
        email: email,
        displayName: displayName,
        photoURL: photoURL,
      );
    } catch (e) {

      rethrow;
    }
  }
}
