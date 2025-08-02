import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ✅ Use your correct package imports here:
import 'package:manshi/firebase_auth/fcm_services.dart';
import 'package:manshi/firebase_auth/notification_service.dart';
import 'package:manshi/wellness_app.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessagingHandler(RemoteMessage message) async {
  log("firebaseBackgroundMessagingHandler main: $message");
  await Firebase.initializeApp();
  NotificationService().initializeLocalNotifications();
  NotificationService().showNotification(message: message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FCMServices fcmServices = FCMServices();

  await Firebase.initializeApp();

  NotificationService().initializeLocalNotifications();

  await fcmServices.initializeCloudMessaging();
  fcmServices.listenFCMMessage(firebaseBackgroundMessagingHandler);

  String? fcmToken = await fcmServices.getFCMToken();
  log("fcm token: $fcmToken");

  runApp(const WellnessApp());
}
