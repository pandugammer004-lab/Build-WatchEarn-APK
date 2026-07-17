import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await requestPermission();
    await _setupLocalNotifications();
    
    // Handle background messages (must be a top-level function in main.dart usually)
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Schedule engagement notifications
    await scheduleEngagementNotification();
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLocalNotification(message);
    });

    // Handle tap on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message);
    });
  }

  Future<void> requestPermission() async {
    try {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint("FCM Permission error: $e");
    }
  }

  Future<String?> getFCMToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint("FCM Token error: $e");
      return null;
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifs.initialize(
      androidInit,
      onDidReceiveNotificationResponse: (details) {
        // Handle tap on local notification
      }
    );
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifs.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'watchearn_channel',
            'WatchEarn Notifications',
            channelDescription: 'Main notification channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> scheduleEngagementNotification() async {
    try {
      await _localNotifs.periodicallyShow(
        0,
        '🎉 Come back and earn!',
        'New rewards and videos are waiting for you. Watch and earn more coins now.',
        RepeatInterval.hourly,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'engagement_channel',
            'Engagement Notifications',
            channelDescription: 'Reminders to earn coins',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint("Error scheduling engagement notification: $e");
    }
  }

  void handleNotificationTap(RemoteMessage message) {
    // Navigation logic based on message data
    debugPrint("Notification tapped: ${message.data}");
  }
}
