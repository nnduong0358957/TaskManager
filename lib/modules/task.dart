import 'package:flutter/material.dart';

class Task {
  String title;
  String content;
  String typeAlarm;
  DateTime dateTime;
  bool status;
  String typeRepeat;
  int periodTime;
  String timeUnit;
  List<String> subTasks;
  bool isDeleted;
  bool isDone;
  List<dynamic> tags;
  bool isMiss;
  bool isShow;
  bool isAlertMiss;
  bool isAlertRemind;
  List<DateTime> listTimeNotificationPeriod;

  Task(
      {@required this.title,
      this.content,
      @required this.typeAlarm,
      @required this.dateTime,
      this.status,
      this.typeRepeat,
      this.periodTime,
      this.timeUnit,
      this.subTasks,
      this.isDeleted = false,
      this.isDone = false,
      this.tags,
      this.isMiss = true,
      this.isShow = false,
      this.isAlertMiss = false,
      this.isAlertRemind = false,
      this.listTimeNotificationPeriod});
}
