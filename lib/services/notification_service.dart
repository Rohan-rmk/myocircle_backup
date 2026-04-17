// lib/notification_manager.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String? fcmToken;
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  print("🔥 Background Message: ${message.notification?.title}");
}

class NotificationManager {
  // Local notification plugin
  static final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  // Initialize everything
  static Future<void> initialize() async {
    // Init Local Notifications
    await _initLocalNotifications();

    // Ask permission
    await _askPermissions();
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print("📩 Foreground Message: ${message.notification?.title}");

      _showLocalNotification(
        message.notification?.title ?? "New Notification",
        message.notification?.body ?? "",
      );
    });

    // When app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("👉 Notification clicked (background)");
    });

    // When app opened from terminated
    RemoteMessage? msg =
    await FirebaseMessaging.instance.getInitialMessage();
    if (msg != null) {
      print("🚀 Notification clicked (terminated)");
    }

    // ✅ Wait for APNS token first


    if (Platform.isIOS) {
      // iOS needs APNS first
      String? apnsToken;

      for (int i = 0; i < 5; i++) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        if (apnsToken != null) break;

        print("⏳ Waiting for APNS token...");
        await Future.delayed(const Duration(seconds: 2));
      }

      print("🍏 APNS Token: $apnsToken");
    }

// ✅ Works for both Android & iOS
    String? token = await FirebaseMessaging.instance.getToken();
    print("🔑 FCM Token: $token");
    fcmToken = token;

    // Token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      print("♻️ Token refreshed: $t");
    });
  }

  // ---------------------------
  // Local Notification Setup
  // ---------------------------
  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _local.initialize(settings);

    // 👉 ADD THIS BLOCK
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel',
      'General Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _local
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ---------------------------
  // Permission request
  // ---------------------------
  static Future<void> _askPermissions() async {
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("🔐 Permission: ${settings.authorizationStatus}");
  }

  // ---------------------------
  // Show notification
  // ---------------------------
  static Future<void> _showLocalNotification(
      String title, String body) async {

    const androidDetails = AndroidNotificationDetails(
      "default_channel",
      "General Notifications",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails, // 🔥 REQUIRED FOR iOS
    );

    await _local.show(0, title, body, details);
  }
}
