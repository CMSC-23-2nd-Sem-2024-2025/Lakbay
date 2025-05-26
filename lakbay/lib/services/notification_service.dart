import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:lakbay/utils/exact_alarm_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      // Create the notification channel for Android
      const androidChannel = AndroidNotificationChannel(
        'travel_plan_channel',
        'Travel Plan Notifications',
        description: 'Notifications for travel plans',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: Color(0xFFF86400),
      );

      // Create the Android notification channel
      final androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Request permissions
      final permissionStatus = await Permission.notification.request();

      // Request exact alarm permission for Android 12+
      if (await Permission.scheduleExactAlarm.isDenied) {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();

    // Request exact alarm permission for Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
      return status.isGranted && exactAlarmStatus.isGranted;
    }

    return status.isGranted;
  }

  Future<void> ensureInitialized() async {
    try {
      // Check if notifications are initialized
      final initializationSettings =
          await _notifications.getNotificationAppLaunchDetails();
      if (!(initializationSettings?.didNotificationLaunchApp ?? false)) {
        await initialize();
      }
    } catch (e) {
      await initialize();
    }
  }

  Future<void> scheduleTravelNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Ensure the service is initialized before scheduling
    await ensureInitialized();

    print('ID: $id');
    print('Title: $title');
    print('Body: $body');
    print('Original Scheduled Date: $scheduledDate');

    final androidDetails = AndroidNotificationDetails(
      'travel_plan_channel',
      'Travel Plan Notifications',
      channelDescription: 'Notifications for travel plans',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      showWhen: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      ledColor: Color(0xFFF86400),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Get the current time in the local timezone
      final now = tz.TZDateTime.now(tz.local);

      // Convert the scheduled date to the local timezone
      final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);

      // Verify the time is in the future
      if (scheduledTz.isBefore(now)) {
        final adjustedTime = now.add(Duration(minutes: 5));

        await _notifications.zonedSchedule(
          id,
          title,
          body,
          adjustedTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          scheduledTz,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      // Verify the scheduled notification
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      if (pendingNotifications.isNotEmpty) {
        for (var notification in pendingNotifications) {
          print('- ID: ${notification.id}, Title: ${notification.title}');
        }
      }
    } catch (e) {
      if (e is PlatformException && e.code == 'exact_alarms_not_permitted') {
        await openExactAlarmSettings();
      }
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens or perform actions here
  }

  Future<void> showTestNotification() async {
    final androidDetails = AndroidNotificationDetails(
      'travel_plan_channel',
      'Travel Plan Notifications',
      channelDescription: 'Notifications for travel plans',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      showWhen: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      ledColor: Color(0xFFF86400),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        999, // Test notification ID
        'Test Notification',
        'This is a test notification to verify the system is working',
        details,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<Map<String, dynamic>> getNotificationStatus() async {
    Map<String, dynamic> status = {};

    try {
      // Always report initialized as true if the service is running
      status['initialized'] = true;

      // Check notification permissions
      final permissionStatus = await Permission.notification.status;
      status['permissionStatus'] = permissionStatus.toString();

      // Check exact alarm permission
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      status['exactAlarmStatus'] = exactAlarmStatus.toString();

      // Get pending notifications
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      status['pendingCount'] = pendingNotifications.length;

      if (pendingNotifications.isNotEmpty) {
        for (var notification in pendingNotifications) {
          print('- ID: ${notification.id}, Title: ${notification.title}');
        }
      }
    } catch (e) {
      status['error'] = e.toString();
    }

    return status;
  }
}
