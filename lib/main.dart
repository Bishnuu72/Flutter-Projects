import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:manshi/firebase_auth/fcm_services.dart';
import 'package:manshi/firebase_auth/notification_service.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/config/fcm_config.dart';
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

  // Set FCM server key for sending notifications
  FCMServices.setServerKey(FCMConfig.serverKey);

  NotificationService().initializeLocalNotifications();

  await fcmServices.initializeCloudMessaging();
  fcmServices.listenFCMMessage(firebaseBackgroundMessagingHandler);

  // Handle FCM token updates when app is opened from terminated state
  await _handleFCMTokenUpdate();

  String? fcmToken = await fcmServices.getFCMToken();
  log("fcm token: $fcmToken");

  runApp(const WellnessApp());
}

Future<void> _handleFCMTokenUpdate() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final fcmServices = FCMServices();
      final newToken = await fcmServices.getFCMToken();
      
      if (newToken != null) {
        // Get current user data to check if token has changed
        final user = await FirestoreService.getUser(currentUser.uid);
        if (user != null && user.fcmToken != newToken) {
          // Token has changed, update it in Firestore
          await FirestoreService.updateUserFCMToken(currentUser.uid, newToken);
          log('FCM token updated for user: ${currentUser.uid}');
        }
      }
    }
  } catch (e) {
    log('Error handling FCM token update: $e');
  }
}
