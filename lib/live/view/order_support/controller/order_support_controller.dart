// order_support_controller.dart

// order_support_controller.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../services/notification_service.dart';

class OrderSupportController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  StreamSubscription? _messagesSubscription;
  String? _currentChatRoomId;

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  // Listen for incoming admin messages and trigger notifications
  void startListeningForAdminMessages(String orderId) {
    final chatRoomId = 'order_${orderId}_support';
    _currentChatRoomId = chatRoomId;

    _messagesSubscription = getMessagesStream(orderId).listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _checkForNewAdminMessages(snapshot.docs);
      }
    });
  }

  Future<void> _checkForNewAdminMessages(
      List<QueryDocumentSnapshot> docs) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      for (final doc in docs) {
        final messageData = doc.data() as Map<String, dynamic>;
        final senderType = messageData['senderType'];
        final senderId = messageData['senderId'];
        final notificationSent = messageData['notificationSent'] ?? false;
        final message = messageData['message'] ?? '';

        // Check if message is from admin AND not from current user AND notification not sent
        if (senderType == 'admin' &&
            senderId != user.uid &&
            !notificationSent) {
          await _triggerAdminMessageNotification(
              message, _currentChatRoomId!, doc.id);
        }
      }
    } catch (e) {
      print('Error checking admin messages: $e');
    }
  }

  Future<void> _triggerAdminMessageNotification(
      String message, String chatRoomId, String messageId) async {
    try {
      // Extract orderId from chatRoomId (format: order_XYZ_support)
      final orderId =
          chatRoomId.replaceFirst('order_', '').replaceFirst('_support', '');

      // Send notification with actual message content
      await NotificationService().showSupportNotification(
        orderId: orderId,
        title: 'Support - Order $orderId',
        body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
        additionalData: {
          'senderType': 'admin',
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('✅ Admin message notification sent for: $orderId');

      // Mark as notified in Firestore to prevent duplicates
      await _firestore
          .collection('order_support_chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'notificationSent': true,
        'notificationSentAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error triggering admin notification: $e');
    }
  }

  // Send message
// In OrderSupportController - modify sendMessage method
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
        'senderType': 'user', // This identifies who sent it
        'message': message.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [user.uid],
        'notificationSent': false, // Admin will handle notification
      });

      // Update chat room last message
      await _firestore
          .collection('order_support_chats')
          .doc(chatRoomId)
          .update({
        'lastMessage': message.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // REMOVE this line - don't send notification when user sends message
      // await _sendSupportNotification(orderId, message.trim());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error sending message: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getMessagesStream(String orderId) {
    final chatRoomId = 'order_${orderId}_support';

    // Return all messages ordered by timestamp
    return _firestore
        .collection('order_support_chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

// Add method to check for unread messages
  Stream<int> getUnreadMessagesCount(String orderId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    final chatRoomId = 'order_${orderId}_support';

    return _firestore
        .collection('order_support_chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('readBy', isNotEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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

  // In OrderSupportController, add these methods:

// Mark messages as read in real-time
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
      print('✅ Messages marked as read for order: $orderId');
    } catch (e) {
      print('❌ Error marking messages as read: $e');
    }
  }
}
