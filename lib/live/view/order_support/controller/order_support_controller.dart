// order_support_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../services/notification_service.dart';

class OrderSupportController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;

  TextEditingController messageController = TextEditingController();

  // Create or get chat room for order
  Future<String> getOrCreateChatRoom(String orderId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final chatRoomId = 'order_${orderId}_support';

      // Check if chat room exists
      final chatRoomDoc = await _firestore
          .collection('order_support_chats')
          .doc(chatRoomId)
          .get();

      if (!chatRoomDoc.exists) {
        // Create new chat room
        await _firestore.collection('order_support_chats').doc(chatRoomId).set({
          'orderId': orderId,
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
          'status': 'active',
          'participants': {
            user.uid: true,
            'admin': true, // Admin will be notified
          }
        });
      }

      return chatRoomId;
    } catch (e) {
      print('Error creating chat room: $e');
      rethrow;
    }
  }

  // Send message
  Future<void> sendMessage(String orderId, String message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      if (message.trim().isEmpty) return;

      _isLoading = true;
      notifyListeners();

      final chatRoomId = await getOrCreateChatRoom(orderId);
      final timestamp = FieldValue.serverTimestamp();

      // Add message to subcollection
      await _firestore
          .collection('order_support_chats')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'senderType': 'user',
        'message': message.trim(),
        'timestamp': timestamp,
        'readBy': [user.uid],
      });

      // Update chat room last message
      await _firestore
          .collection('order_support_chats')
          .doc(chatRoomId)
          .update({
        'lastMessage': message.trim(),
        'lastMessageAt': timestamp,
        'lastSenderId': user.uid,
      });

      // Send notification to admin
      await _sendSupportNotification(orderId, message.trim());

      messageController.clear();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Stream messages for a chat room
  Stream<QuerySnapshot> getMessagesStream(String orderId) {
    return _firestore
        .collection('order_support_chats')
        .doc('order_${orderId}_support')
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

// In OrderSupportController, use the singleton instance:
  Future<void> _sendSupportNotification(String orderId, String message) async {
    try {
      // Use the singleton instance directly
      await NotificationService().showSupportNotification(
        orderId: orderId,
        title: 'Support Message Sent',
        body:
            'Your message has been sent to our support team. We\'ll respond soon.',
      );

      print('✅ Support notification sent for order: $orderId');
    } catch (e) {
      print('❌ Error sending support notification: $e');
    }
  }

  // Helper method to send FCM notifications
  Future<void> _sendFCMNotification({
    required List<String> tokens,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // This would integrate with your FCM service
    // For now, we'll just print
    print('FCM Notification:');
    print('Title: $title');
    print('Body: $body');
    print('Data: $data');
    print('Tokens: ${tokens.length}');
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
