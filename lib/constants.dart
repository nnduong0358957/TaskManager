import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final ref = FirebaseDatabase.instance.reference();
final FirebaseAuth auth = FirebaseAuth.instance;

const kPrimaryColor = Colors.blue;
const kTextColor = Colors.white;
DateTime kNow = DateTime.now();
DateTime kTomorrow = kNow.add(Duration(days: 1));
DateTime kYesterday = kNow.subtract(Duration(days: 1));

Container buildColorGradient() {
  return Container(
    decoration: new BoxDecoration(
      gradient: new LinearGradient(
          colors: [
            const Color(0xFF3366FF),
            const Color(0xFF00CCFF),
          ],
          begin: const FractionalOffset(0.0, 1.0),
          end: const FractionalOffset(3.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp),
    ),
  );
}

Future changeStatus(Map<String, dynamic> task, bool newValue) async {
  final path = "users/${auth.currentUser.uid}/tasks";
  DateTime now = DateTime.now();
  DateTime taskDateTime = DateTime.parse(task["dateTime"]);

  // Nếu bật lại task thuộc loại OneTime thì đặt cho nó thời gian trước thời
  // gian bây giờ để tránh bị lỗi (thời gian thông báo ở quá khứ)
  if (newValue && task["typeAlarm"] == "One Time") {
    DateTime newDateTime = DateTime(
        now.year, now.month, now.day, taskDateTime.hour, taskDateTime.minute);
    if (newDateTime.isBefore(now)) {
      newDateTime = newDateTime.add(Duration(days: 1));
    }
    await ref
        .child(path)
        .child(task["key"])
        .update({"dateTime": newDateTime.toString(), "status": newValue});
  }

  await ref.child(path).child(task["key"]).update({
    "status": newValue,
    "isMiss": true,
    "isShow": false,
    "isAlertMiss": true,
    "isAlertRemind": true
  });
}

Future setListTimeAlarm(Map<String, dynamic> task) async {
  final path = "users/${auth.currentUser.uid}/tasks";
  DateTime taskDateTime = DateTime.parse(task["dateTime"]);

  int listLength;
  if (task["timeUnit"] == "Minutes")
    listLength = 20;
  else if (task["timeUnit"] == "Hours")
    listLength = 12;
  else if (task["timeUnit"] == "Days") listLength = 7;

  List<String> listNotiTime = List<String>.generate(listLength, (index) {
    if (index == 0)
      return taskDateTime.toString();
    else if (task["timeUnit"] == "Minutes") {
      taskDateTime = taskDateTime.add(Duration(minutes: task["periodTime"]));
    } else if (task["timeUnit"] == "Hours") {
      taskDateTime = taskDateTime.add(Duration(hours: task["periodTime"]));
    } else if (task["timeUnit"] == "Days") {
      taskDateTime = taskDateTime.add(Duration(days: task["periodTime"]));
    }
    return taskDateTime.toString();
  });

  await ref.child(path).child(task["key"]).update({
    "listTimeNotificationPeriod": listNotiTime,
  });
}

Future resetTypeOfWork(
    List<dynamic> listTask, List<dynamic> newListTypeOfWork) async {
  listTask.forEach((task) async {
    if (task['tags'] != null) {
      List<dynamic> tags = new List<dynamic>.from(task['tags']);
      List<dynamic> editTags = new List<dynamic>.from(tags);
      bool isChange = false;
      tags.forEach((element) {
        if (!newListTypeOfWork.contains(element)) {
          editTags.remove(element);
          isChange = true;
        }
      });
      if (isChange)
        await ref
            .child("users/${auth.currentUser.uid}/tasks/${task['key']}")
            .update({"tags": editTags});
    }
  });
}
