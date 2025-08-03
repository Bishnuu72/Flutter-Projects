import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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
    tz.initializeTimeZones(); // Initialize timezones
    
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

  /// Schedules a daily reminder notification.
  ///
  /// - [id]: Unique identifier for the notification
  /// - [title]: Notification title
  /// - [body]: Notification body
  /// - [hour]: Hour of the day (0-23)
  /// - [minute]: Minute of the hour (0-59)
  /// - [payload]: Optional data payload
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    const String channelId = 'wellness_reminders';
    const String channelName = 'Wellness Reminders';
    const String channelDesc = 'Daily wellness reminders';

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Schedules a weekly reminder notification.
  ///
  /// - [id]: Unique identifier for the notification
  /// - [title]: Notification title
  /// - [body]: Notification body
  /// - [dayOfWeek]: Day of the week (1-7, where 1 is Monday)
  /// - [hour]: Hour of the day (0-23)
  /// - [minute]: Minute of the hour (0-59)
  /// - [payload]: Optional data payload
  Future<void> scheduleWeeklyReminder({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    const String channelId = 'wellness_reminders';
    const String channelName = 'Wellness Reminders';
    const String channelDesc = 'Weekly wellness reminders';

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeekday(dayOfWeek, hour, minute),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancels a scheduled notification by ID.
  ///
  /// - [id]: The ID of the notification to cancel
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Gets all pending notification requests.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  void onClickToNotification(String? data) {
    log("notification payload: $data");
  }

  /// Calculates the next instance of a specific time for daily reminders.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// Calculates the next instance of a specific weekday and time for weekly reminders.
  tz.TZDateTime _nextInstanceOfWeekday(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }
}