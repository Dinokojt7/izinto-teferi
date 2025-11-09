// simple_notification_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SimpleNotificationTest extends StatefulWidget {
  @override
  _SimpleNotificationTestState createState() => _SimpleNotificationTestState();
}

class _SimpleNotificationTestState extends State<SimpleNotificationTest> {
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    print('🚀 Initializing notifications...');

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

    await notifications.initialize(initSettings);

    // Create channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_channel', // Must match manifest
      'Order Notifications',
      description: 'Order notifications',
      importance: Importance.high,
    );

    final androidPlugin = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      print('✅ Channel created: order_channel');
    }

    print('✅ Notifications initialized!');
  }

  Future<void> _showNotification() async {
    print('📨 Showing notification...');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'order_channel', // Must match manifest
      'Order Notifications',
      channelDescription: 'Order notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await notifications.show(
        123,
        'Test Notification',
        'This is a test notification!',
        platformDetails,
      );
      print('✅ Notification shown!');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showNotification,
              child: Text('Test Notification'),
            ),
            SizedBox(height: 20),
            Text('Check console for logs'),
          ],
        ),
      ),
    );
  }
}
