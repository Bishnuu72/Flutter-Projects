import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'notification_service.dart';

/// A service class for managing Firebase Cloud Messaging (FCM) operations.
///
/// This class provides utility functions to initialize FCM, retrieve the
/// FCM token for the current device, and send push notifications.
///
/// Example usage:
/// ```dart
/// final fcmService = FCMServices();
/// await fcmService.initializeCloudMessaging();
/// String? token = await fcmService.getFCMToken();
/// ```
class FCMServices {
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';
  static String? _serverKey;

  /// Set the FCM server key for sending notifications
  static void setServerKey(String serverKey) {
    _serverKey = serverKey;
  }

  /// Initializes Firebase Cloud Messaging (FCM) for the current device.
  ///
  /// This sets up FCM auto-initialization, allowing the device to automatically
  /// handle token generation and receive push notifications.
  ///
  /// This method should be invoked early in the app lifecycle, ideally during
  /// app startup or initialization.
  ///
  /// Returns a [Future] that completes when both permission is granted and
  /// auto-initialization is enabled.
  Future<void> initializeCloudMessaging() => Future.wait([
    // requesting notification permission
    FirebaseMessaging.instance.requestPermission(),
    // initialize fcm
    FirebaseMessaging.instance.setAutoInitEnabled(true),
  ]);

  /// Retrieves the default FCM token for the current device.
  ///
  /// This token is used to uniquely identify the device to Firebase Cloud Messaging
  /// and is necessary for sending targeted push notifications.
  ///
  /// Returns a [Future] that completes with the FCM token as a [String],
  /// or `null` if the token could not be retrieved.
  Future<String?> getFCMToken() => FirebaseMessaging.instance.getToken();

  /// Sends a push notification to a single device using its FCM token.
  ///
  /// - [token]: The FCM token of the target device
  /// - [title]: The notification title
  /// - [body]: The notification body
  /// - [data]: Optional data payload
  static Future<bool> sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (_serverKey == null) {
      log('FCM Server Key not set. Please set it using FCMServices.setServerKey()');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
          },
          'data': data ?? {},
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == 1;
      }
      return false;
    } catch (e) {
      log('Error sending FCM notification: $e');
      return false;
    }
  }

  /// Sends a push notification to multiple devices using their FCM tokens.
  ///
  /// - [tokens]: List of FCM tokens of target devices
  /// - [title]: The notification title
  /// - [body]: The notification body
  /// - [data]: Optional data payload
  static Future<bool> sendNotificationToMultipleTokens({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (_serverKey == null) {
      log('FCM Server Key not set. Please set it using FCMServices.setServerKey()');
      return false;
    }

    if (tokens.isEmpty) {
      log('No tokens provided for notification');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'registration_ids': tokens,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
          },
          'data': data ?? {},
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] > 0;
      }
      return false;
    } catch (e) {
      log('Error sending FCM notification to multiple tokens: $e');
      return false;
    }
  }

  /// Sets up listeners for Firebase Cloud Messaging (FCM) messages.
  ///
  /// This should be called after FCM has been initialized to ensure the app can
  /// respond to notifications in different app states:
  ///
  /// - **Foreground**: Handles messages while the app is running and visible.
  /// - **Background/Terminated**: Handles when the user taps a notification
  ///   to open or resume the app.
  void listenFCMMessage(BackgroundMessageHandler handler) {
    // Notification is received while app is open [foreground]
    FirebaseMessaging.onMessage.listen(_handleFCMMessage);

    // Notification is received while app is terminated or closed or background
    FirebaseMessaging.onBackgroundMessage(handler);

    // User taps on a notification to open the app [background/terminated/closed]
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Notification opened title: ${message.notification?.title}");
      log("Notification opened body: ${message.notification?.body}");
      NotificationService().onClickToNotification(
        jsonEncode({
          'title': message.notification?.title,
          'body': message.notification?.body,
        }),
      );
    });
  }

  /// Handles FCM messages received while the app is in the foreground.
  ///
  /// This method is triggered by [FirebaseMessaging.onMessage] and logs the
  /// notification title. Can be extended to show in-app notifications or
  /// trigger app-specific actions.
  Future<void> _handleFCMMessage(RemoteMessage message) async {
    log('Received FCM message title: ${message.notification?.title}');
    log('Received FCM message body: ${message.notification?.body}');
    await NotificationService().showNotification(message: message);
  }
}
