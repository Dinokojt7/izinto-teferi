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

  TextEditingController messageController = TextEditingController();

  // Get or create chat room
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
            'admin': true,
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

      // Add message to subcollection
      await _firestore
          .collection('order_support_chats')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'senderType': 'user',
        'message': message.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [user.uid],
      });

      // Update chat room last message
      await _firestore
          .collection('order_support_chats')
          .doc(chatRoomId)
          .update({
        'lastMessage': message.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': user.uid,
      });

      // Send notification to admin (only if message is from user)
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
    final chatRoomId = 'order_${orderId}_support';
    return _firestore
        .collection('order_support_chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String orderId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final chatRoomId = 'order_${orderId}_support';

      final messages = await _firestore
          .collection('order_support_chats')
          .doc(chatRoomId)
          .collection('messages')
          .where('readBy', isNotEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([user.uid])
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Send support notification (to admin when user messages, to user when admin messages)
  Future<void> _sendSupportNotification(String orderId, String message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // For now, we'll just show a local notification to the user
      // In a real implementation, you'd send this to admin
      await NotificationService().showSupportNotification(
        orderId: orderId,
        title: 'Support Message Sent',
        body: 'Your message has been sent to our support team.',
      );

      print('✅ Support notification sent for order: $orderId');
    } catch (e) {
      print('❌ Error sending support notification: $e');
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
