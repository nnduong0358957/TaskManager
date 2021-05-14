import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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