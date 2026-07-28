// services/notification_service.dart
// TODO(god-file): ~530 lines mixing FCM setup, local-notification handling,
// and chat-message listener wiring (see setupChatMessageListener, called
// from main.dart). Consider splitting the chat-listener piece out.
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _localNotifications;
  bool _isInitialized = false;
  String? _currentFcmToken;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _localNotifications = FlutterLocalNotificationsPlugin();

    // Order notification channel - let system handle sound
    const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      'order_channel', // Match your manifest
      'Order Notifications',
      description: 'Get notified about order updates and status changes',
      importance: Importance.high, // High but not max to avoid annoying users
      playSound: false, // Let system/user settings handle sound
    );

    // Support notification channel
    const AndroidNotificationChannel supportChannel =
        AndroidNotificationChannel(
      'support_channel',
      'Support Notifications',
      description: 'Get notified about support messages',
      importance: Importance.high,
      playSound: false, // Let system handle sound
    );

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Create notification channels for Android
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(orderChannel);
      await androidPlugin.createNotificationChannel(supportChannel);

    }

    // Configure Firebase Messaging
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true, // Allow FCM to handle sound
    );

    // Listen for token refresh and auto-save
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {

      _saveFCMTokenToFirestore(newToken);
    });

    // Listen for messages
    _setupMessageHandling();

    // Get initial token and save it automatically
    await _setupFCMToken();

    _isInitialized = true;

  }

  Future<void> _setupFCMToken() async {
    try {
      // Get the FCM token
      _currentFcmToken = await FirebaseMessaging.instance.getToken();


      // AUTO-SAVE: Save to Firestore if user is logged in
      await _saveFCMTokenToFirestore(_currentFcmToken);
    } catch (e) {

    }
  }

  // AUTO-SAVE FCM token to Firestore
  Future<void> _saveFCMTokenToFirestore(String? token) async {
    if (token == null) {

      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'updatedAt': FieldValue.serverTimestamp(),
          'notificationsEnabled': true,
          'notificationsEnabledAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));



      } else {

      }
    } catch (e) {

    }
  }

  void _setupMessageHandling() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      _showLocalNotificationFromMessage(message);
    });

    // When app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      _handleNotificationData(message.data);
    });

    // Handle initial message when app is opened from terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {

        _handleNotificationData(message.data);
      }
    });
  }

  Future<void> _showLocalNotificationFromMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      // Determine which channel to use based on message data
      final channel = message.data['type'] == 'order_support'
          ? 'support_channel'
          : 'order_channel';

      await showNotification(
        title: notification.title ?? 'Izinto',
        body: notification.body ?? 'You have a new notification',
        channel: channel,
        payload: message.data.isNotEmpty ? message.data : null,
      );
    }
  }

  void _handleNotificationData(Map<String, dynamic> data) {


    final type = data['type'];
    final orderId = data['orderId'];

    if (orderId != null) {
      switch (type) {
        case 'new_order':
          _navigateToOrderDetails(orderId);
          break;
        case 'order_support':
          _navigateToSupportChat(orderId);
          break;
        case 'order_update':
          _navigateToOrderDetails(orderId);
          break;
        default:
          _navigateToOrdersList();
      }
    } else {
      _navigateToOrdersList();
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    try {
      // Parse payload if it's JSON, otherwise treat as simple data
      final data = _parsePayload(payload);
      _handleNotificationData(data);
    } catch (e) {

    }
  }

  Map<String, dynamic> _parsePayload(String payload) {
    try {
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (e) {
      // If it's not JSON, create a simple map
      return {'type': 'general', 'message': payload};
    }
  }

  // ========== PUBLIC METHODS ==========

  // Show a generic notification
  Future<void> showNotification({
    required String title,
    required String body,
    String channel = 'order_channel',
    Map<String, dynamic>? payload,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails;
      final DarwinNotificationDetails iosDetails =
          const DarwinNotificationDetails();

      switch (channel) {
        case 'support_channel':
          androidDetails = const AndroidNotificationDetails(
            'support_channel',
            'Support Notifications',
            channelDescription: 'Get notified about support messages',
            importance: Importance.high,
            priority: Priority.high,
            playSound: false, // Respect user settings
          );
          break;
        default:
          androidDetails = const AndroidNotificationDetails(
            'order_channel',
            'Order Notifications',
            channelDescription:
                'Get notified about order updates and status changes',
            importance: Importance.high,
            priority: Priority.high,
            playSound: false, // Respect user settings
          );
      }

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformDetails,
        payload: payload != null ? jsonEncode(payload) : null,
      );


    } catch (e) {

    }
  }

  // Show order notification
  Future<void> showOrderNotification({
    required String orderId,
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = {
      'type': 'new_order',
      'orderId': orderId,
      ...?additionalData,
    };

    await showNotification(
      title: title,
      body: body,
      channel: 'order_channel',
      payload: data,
    );
  }

  // Show order status update
  Future<void> showOrderStatusNotification({
    required String orderId,
    required String status,
    required String body,
  }) async {
    await showOrderNotification(
      orderId: orderId,
      title: 'Order $status',
      body: body,
      additionalData: {'updateType': status.toLowerCase()},
    );
  }

  // Show support notification
  // In NotificationService - improve the support notification method
  Future<void> showSupportNotification({
    required String orderId,
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = {
      'type': 'order_support',
      'orderId': orderId,
      'senderType': 'admin', // Important: identify as admin message
      ...?additionalData,
    };

    await showNotification(
      title: title,
      body: body,
      channel: 'support_channel',
      payload: data,
    );


  }

// Also update the message handler to be more specific
  void _handleChatMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final orderId = data['orderId'];
    final senderType = data['senderType'];



    // Only handle admin support messages
    if (type == 'order_support' && senderType == 'admin') {
      final messageBody = data['message'] ?? 'You have a new support message';

      // Show local notification (this handles foreground case)
      _showLocalNotificationForAdminMessage(orderId, messageBody, data);

      // Navigate if needed
      _navigateToSupportChat(orderId);
    }
  }

  Future<void> _showLocalNotificationForAdminMessage(
      String orderId, String message, Map<String, dynamic> data) async {
    await showSupportNotification(
      orderId: orderId,
      title: 'Support - Order $orderId',
      body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      additionalData: data,
    );
  }

  // Manual save method for when user enables notifications
  Future<void> saveFCMTokenToBackend() async {
    await _saveFCMTokenToFirestore(_currentFcmToken);
  }

  // Remove FCM tokens when user logs out
  Future<void> removeFCMToken(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmTokens': FieldValue.arrayRemove([token]),
          'notificationsEnabled': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });

      }
    } catch (e) {

    }
  }

  Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true, // Request sound permission but let system handle it
        criticalAlert: false,
      );

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      if (granted) {

        await _setupFCMToken();
      } else {

      }

      return granted;
    } catch (e) {

      return false;
    }
  }

  Future<String?> getFCMToken() async {
    if (_currentFcmToken == null) {
      _currentFcmToken = await FirebaseMessaging.instance.getToken();
    }
    return _currentFcmToken;
  }

  Future<bool> areNotificationsEnabled() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Check if token is saved in backend
  Future<bool> isTokenSavedInBackend() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _currentFcmToken != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = doc.data();
        final tokens = data?['fcmTokens'] as List?;
        return tokens != null && tokens.contains(_currentFcmToken);
      }
      return false;
    } catch (e) {

      return false;
    }
  }

// Listen for new support messages in the background
  void setupChatMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      _handleChatMessage(message);
    });

    // Setup for background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      _handleChatMessage(message);
    });
  }

// Send chat notification (to be called from Firebase Functions)
  Future<void> sendChatNotification({
    required String orderId,
    required String message,
    required String senderType,
  }) async {
    try {
      // Only send notification if message is from admin
      if (senderType == 'admin') {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await showSupportNotification(
            orderId: orderId,
            title: 'New Support Message',
            body: message.length > 50
                ? '${message.substring(0, 50)}...'
                : message,
            additionalData: {
              'senderType': senderType,
              'timestamp': DateTime.now().toIso8601String(),
            },
          );

        }
      }
    } catch (e) {

    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // ========== NAVIGATION METHODS ==========
  // You'll need to implement these based on your app structure

  void _navigateToOrderDetails(String orderId) {

    // Implement your navigation logic
    // Example: Get.to(() => OrderDetailsScreen(orderId: orderId));
  }

  void _navigateToSupportChat(String orderId) {

    // Implement your navigation logic
    // Example: Get.to(() => SupportChatScreen(orderId: orderId));
  }

  void _navigateToOrdersList() {

    // Implement your navigation logic
    // Example: Get.to(() => OrderHistoryView());
  }
}

// Add this import at the top of the file
