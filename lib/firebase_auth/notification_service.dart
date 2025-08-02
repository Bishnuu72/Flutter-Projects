import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level function to handle notification tap when app is in the background
/// or terminated.
///
/// This function is required to be a top-level function and annotated with
/// `@pragma('vm:entry-point')` so that Flutter can reference it correctly
/// even if the app is killed.
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse notificationResponse,
    ) => NotificationService().onClickToNotification(
  notificationResponse.payload,
);

/// A service class for handling local notifications using the
/// `flutter_local_notifications` plugin.
///
/// This class is responsible for initializing notification settings,
/// requesting permissions, and displaying notifications based on Firebase
/// messages.
class NotificationService {
  /// The plugin instance used to manage local notifications.
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initializes the local notifications plugin with platform-specific settings
  /// and sets up handlers for notification taps (both foreground and background).
  void initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('notification');
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const DarwinInitializationSettings initializationSettingsMacOS =
    DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    // Request permissions on iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
    >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Initialize the plugin and assign tap handlers
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
      onDidReceiveBackgroundNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
      onDidReceiveBackgroundNotificationResponse,
    );
  }

  /// Displays a local notification based on a [RemoteMessage] from Firebase.
  ///
  /// The notification is customized with channel ID, title, body, and payload
  /// (which includes the message data). It handles both Android and iOS styling.
  ///
  /// - [message]: The incoming remote message from Firebase Cloud Messaging.
  Future<void> showNotification({required RemoteMessage message}) async {
    log('local notification remote message: ${message.toMap()}');

    const String channelId = 'wellness_channel';
    const String channelName = 'Wellness Notifications';
    const String channelDesc = 'Notifications for wellness updates';

    // Generate a unique 32-bit integer ID for the notification
    final int notificationId =
        DateTime.now().millisecondsSinceEpoch % 2147483647;

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Show the notification with title, body, and optional payload
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      message.notification?.title ?? message.data['title'] ?? '',
      message.notification?.body ?? message.data['body'] ?? '',
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  void onClickToNotification(String? data) {
    log("notification payload: $data");
  }
}