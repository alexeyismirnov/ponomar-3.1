import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:supercharged/supercharged.dart';
import 'dart:io';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class FirebaseConfig {
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static var count = 0;

  static setup() async {
    tz.initializeTimeZones();

    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('cross'),
        iOS: DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        ));
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  static schedule(DateTime date, String title, String body) async {
    count++;
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // final d = DateTime.now() + 4.minutes;
    // final scheduledDate = tz.TZDateTime(tz.local, d.year, d.month, d.day, d.hour, d.minute);

    final d = date - 1.days;
    final scheduledDate = tz.TZDateTime(tz.local, d.year, d.month, d.day, 17, 00);

    if (scheduledDate.isBefore(now)) return;

    await FirebaseConfig.flutterLocalNotificationsPlugin.zonedSchedule(
        count,
        title,
        body,
        scheduledDate,
        NotificationDetails(
            android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: 'cross',
        )),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  static show(String title, String body) {
    flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'cross',
          ),
        ));
  }

  static cancel() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
