import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:manshi/firebase_auth/fcm_services.dart';
import 'package:manshi/wellness_app.dart';

/// Background message handler must be a top-level function
Future<void> firebaseBackgroundMessagingHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Required in background isolate
  log('🔕 [BG] Message Title: ${message.notification?.title}');
  log('🔕 [BG] Message Body: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FCMServices fcmServices = FCMServices();
  await Firebase.initializeApp();
  await fcmServices.initializeCloudMessaging();
  fcmServices.listenFCMMessage(firebaseBackgroundMessagingHandler);
  String? fcmToken = await fcmServices.getFCMToken();
  log("fcm token: $fcmToken");
  runApp(const WellnessApp());
}
