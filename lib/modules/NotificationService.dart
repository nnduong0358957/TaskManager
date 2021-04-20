import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService extends ChangeNotifier {
  final ref = FirebaseDatabase.instance.reference();
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String _timezone = 'Unknown';

  //initialize
  Future initialize(List<dynamic> listTask) async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_notification_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future instantNotification(Map<String, dynamic> task, int id) async {
    String time, title, body, payload;
    time = task["dateTime"];
    title = task["title"];
    body = "You have a job right now";
    payload = task["key"];

    print("Called instantNotification");
    tz.initializeTimeZones();
    _timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(_timezone));

    const android = AndroidNotificationDetails(
        "id", "channel", "channelDescription",
        playSound: true, importance: Importance.max, priority: Priority.high);
    const ios = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: ios);

    if (DateTime.parse(time).isAfter(DateTime.now())) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
          id, title, body, tz.TZDateTime.parse(tz.local, time), platform,
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } else
      print("Type alarm 'One time' can not use datetime in the past");
  }

  Future scheduledNotification(Map<String, dynamic> task, int id) async {
    String time, title, body, payload;
    time = task["dateTime"];
    title = task["title"];
    body = "You have a job right now";
    payload = task["key"];

    tz.initializeTimeZones();
    _timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(_timezone));

    const android = AndroidNotificationDetails(
        "id", "channel", "channelDescription",
        playSound: true, importance: Importance.max, priority: Priority.high);
    const ios = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: ios);

    if (task["typeRepeat"] == "Daily") {
      print("Called Daily Notification");
      await _flutterLocalNotificationsPlugin.zonedSchedule(
          id, title, body, tz.TZDateTime.parse(tz.local, time), platform,
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time);
    } else if (task["typeRepeat"] == "Weekly") {
      print("Called Weekly Notification");
      await _flutterLocalNotificationsPlugin.zonedSchedule(
          id, title, body, tz.TZDateTime.parse(tz.local, time), platform,
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
    }
  }

  // Cancel notification
  Future cancelNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
