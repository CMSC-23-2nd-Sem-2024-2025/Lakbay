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
    print('\n=== Initializing Notification Service ===');
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
        print('Creating Android notification channel...');
        await androidPlugin.createNotificationChannel(androidChannel);
        print('Android notification channel created successfully');
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

      print('Initializing notification plugin...');
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      print('Notification plugin initialized: $initialized');

      // Request permissions
      print('Requesting notification permissions...');
      final permissionStatus = await Permission.notification.request();
      print('Notification permission status: $permissionStatus');

      // Request exact alarm permission for Android 12+
      if (await Permission.scheduleExactAlarm.isDenied) {
        print('Requesting exact alarm permission...');
        final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
        print('Exact alarm permission status: $exactAlarmStatus');
      }

      print('=== Notification Service Initialization Complete ===\n');
    } catch (e) {
      print('Error initializing notification service: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<bool> requestPermissions() async {
    print('Requesting notification permissions...');
    final status = await Permission.notification.request();
    print('Notification permission status: $status');

    // Request exact alarm permission for Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      print('Requesting exact alarm permission...');
      final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
      print('Exact alarm permission status: $exactAlarmStatus');
      return status.isGranted && exactAlarmStatus.isGranted;
    }

    return status.isGranted;
  }

  Future<void> ensureInitialized() async {
    print('\n=== Ensuring Notification Service is Initialized ===');
    try {
      // Check if notifications are initialized
      final initializationSettings =
          await _notifications.getNotificationAppLaunchDetails();
      if (!(initializationSettings?.didNotificationLaunchApp ?? false)) {
        print('Notification service not initialized, initializing now...');
        await initialize();
      } else {
        print('Notification service already initialized');
      }
    } catch (e) {
      print('Error checking initialization status: $e');
      print('Attempting to reinitialize...');
      await initialize();
    }
    print('=== End Initialization Check ===\n');
  }

  Future<void> scheduleTravelNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print('\n=== Notification Service: Scheduling Notification ===');

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
      print('Current time in local timezone: $now');

      // Convert the scheduled date to the local timezone
      final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);
      print('Scheduled time in local timezone: $scheduledTz');

      // Verify the time is in the future
      if (scheduledTz.isBefore(now)) {
        print(
          'Warning: Scheduled time is in the past, adjusting to 5 minutes from now',
        );
        final adjustedTime = now.add(Duration(minutes: 5));
        print('Adjusted scheduled time: $adjustedTime');

        print('Scheduling notification with adjusted time...');
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
        print('Notification scheduled with adjusted time');
      } else {
        print('Scheduling notification with original time...');
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
        print('Notification scheduled with original time');
      }

      // Verify the scheduled notification
      print('Verifying scheduled notification...');
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      print('Total pending notifications: ${pendingNotifications.length}');
      if (pendingNotifications.isNotEmpty) {
        print('Pending notifications:');
        for (var notification in pendingNotifications) {
          print('- ID: ${notification.id}, Title: ${notification.title}');
        }
      } else {
        print('No pending notifications found');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
      if (e is PlatformException && e.code == 'exact_alarms_not_permitted') {
        print('Prompting user to allow exact alarms in system settings...');
        await openExactAlarmSettings();
      }
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
    print('=== End Notification Service: Scheduling Notification ===\n');
  }

  Future<void> cancelNotification(int id) async {
    print('Cancelling notification with ID: $id');
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    print('Cancelling all notifications');
    await _notifications.cancelAll();
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap
    // You can navigate to specific screens or perform actions here
  }

  Future<void> showTestNotification() async {
    print('Showing test notification...');

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
      print('Test notification shown successfully');
    } catch (e) {
      print('Error showing test notification: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<Map<String, dynamic>> getNotificationStatus() async {
    print('\n=== Checking Notification Service Status ===');
    Map<String, dynamic> status = {};

    try {
      // Always report initialized as true if the service is running
      status['initialized'] = true;

      // Check notification permissions
      final permissionStatus = await Permission.notification.status;
      status['permissionStatus'] = permissionStatus.toString();
      print('Notification permission status: ${status['permissionStatus']}');

      // Check exact alarm permission
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      status['exactAlarmStatus'] = exactAlarmStatus.toString();
      print('Exact alarm permission status: ${status['exactAlarmStatus']}');

      // Get pending notifications
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      status['pendingCount'] = pendingNotifications.length;
      print('Pending notifications count: ${status['pendingCount']}');

      if (pendingNotifications.isNotEmpty) {
        print('Pending notifications:');
        for (var notification in pendingNotifications) {
          print('- ID: ${notification.id}, Title: ${notification.title}');
        }
      }
    } catch (e) {
      print('Error checking notification status: $e');
      status['error'] = e.toString();
    }

    print('=== End Notification Service Status Check ===\n');
    return status;
  }
}
