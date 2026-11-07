import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern setup
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize timezone, permissions, and platform settings
 Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    try {
      // Android runtime notification permission
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      // Explicitly request iOS permissions to ensure alert dialog triggers on first launch
      final iosPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }
  // Future<void> init() async {
  //   tz.initializeTimeZones();

  //   // Android initialization settings
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');

  //   // iOS (Darwin) initialization settings
  //   const DarwinInitializationSettings initializationSettingsDarwin =
  //       DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //   );

  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(
  //     android: initializationSettingsAndroid,
  //     iOS: initializationSettingsDarwin,
  //   );

  //   // Initialize notification plugin
  //   await flutterLocalNotificationsPlugin.initialize(
  //     settings: initializationSettings,
  //   );

  //   // Request Android 13+ runtime permissions
  //   final androidPlugin = flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>();

  //   if (androidPlugin != null) {
  //     await androidPlugin.requestNotificationsPermission();
  //     await androidPlugin.requestExactAlarmsPermission();
  //   }

  //   // Request iOS permissions
  //   await flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           IOSFlutterLocalNotificationsPlugin>()
  //       ?.requestPermissions(
  //         alert: true,
  //         badge: true,
  //         sound: true,
  //       );
  // }

 // Schedule task reminder safely without triggering exact alarm permission crashes
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminder_channel_high',
      'Task Reminders',
      channelDescription: 'High priority alerts for task reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
      ),
    );

    try {
      // inexactAllowWhileIdle runs without requiring special system alarm permissions
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: 'Task Reminder: $title',
        body: body.isEmpty ? 'Time to complete your scheduled task!' : body,
        scheduledDate: tzDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Failed to schedule reminder notification: $e');
    }
  }
  // Future<void> scheduleTaskReminder({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required DateTime scheduledDate,
  // }) async {
  //   // Prevent scheduling if date is in the past
  //   if (scheduledDate.isBefore(DateTime.now())) return;

  //   final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

  //   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //     'task_reminder_channel_high',
  //     'Task Reminders',
  //     channelDescription: 'High priority alerts for task reminders',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     playSound: true,
  //     enableVibration: true,
  //     icon: '@mipmap/ic_launcher',
  //   );

  //   const NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidDetails,
  //     iOS: DarwinNotificationDetails(
  //       presentAlert: true,
  //       presentBadge: true,
  //       presentSound: true,
  //     ),
  //   );

  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     id: id,
  //     title: 'Task Reminder: $title',
  //     body: body.isEmpty ? 'Time to complete your scheduled task!' : body,
  //     scheduledDate: tzDate,
  //     notificationDetails: notificationDetails,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }

  // Cancel scheduled notification by ID
  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

 // Show immediate notification for testing system channels and permissions
  Future<void> showInstantTestNotification() async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminder_channel_high',
        'Task Reminders',
        channelDescription: 'High priority alerts for task reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Pass arguments with their respective parameter names
    await flutterLocalNotificationsPlugin.show(
      id: 999,
      title: 'PlanIt Test Notification',
      body: 'Notification service is working properly!',
      notificationDetails: details,
    );
  }
}
