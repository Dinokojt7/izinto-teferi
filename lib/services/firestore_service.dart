import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER MANAGEMENT ====================

  // Get user data by user ID
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  // Create user document if it doesn't exist
  Future<void> createUserDocument({
    required String userId,
    required String email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

  // Check if user profile is complete
  Future<bool> isProfileComplete(String userId) async {
    try {
      final userData = await getUserData(userId);
      if (userData == null) return false;

      // Check for basic profile info
      final hasBasicInfo =
          userData['firstName'] != null &&
              userData['lastName'] != null &&
              userData['dateOfBirth'] != null;

      // Check for interests
      final hasInterests =
          userData['interests'] != null &&
              (userData['interests'] as List).isNotEmpty;

      return hasBasicInfo && hasInterests;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  // ==================== FOR CREATORS (Mobile App) ====================

  // Get ALL active campaigns for participants to browse

  // Get campaigns by user interests

  // Join a campaign as participant
  Future<void> joinCampaign(String campaignId, String userId) async {
    await _firestore.collection('campaigns').doc(campaignId).update({
      'participants': FieldValue.increment(1),
      'participantIds': FieldValue.arrayUnion([userId]),
    });

    // Also update user's joined campaigns
    await _firestore.collection('users').doc(userId).update({
      'joinedCampaigns': FieldValue.arrayUnion([campaignId]),
    });
  }

  // Leave a campaign
  Future<void> leaveCampaign(String campaignId, String userId) async {
    await _firestore.collection('campaigns').doc(campaignId).update({
      'participants': FieldValue.increment(-1),
      'participantIds': FieldValue.arrayRemove([userId]),
    });

    // Also update user's joined campaigns
    await _firestore.collection('users').doc(userId).update({
      'joinedCampaigns': FieldValue.arrayRemove([campaignId]),
    });
  }



  // Get user's recommended campaigns based on interests


  // In FirestoreService class

  // Add this for tutorials (you'll need to create a tutorials collection)
  Stream<List<dynamic>> getTutorials() {
    return _firestore
        .collection('tutorials')
        .where('active', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
