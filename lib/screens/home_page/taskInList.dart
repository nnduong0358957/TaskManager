import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/constants.dart';
import 'package:todo_list_app/screens/edit_task/edit_task.dart';
import 'package:todo_list_app/screens/home_page/subTitle.dart';

class TaskInList extends StatefulWidget {
  TaskInList({this.task});

  final Map<String, dynamic> task;

  @override
  _TaskInListState createState() => _TaskInListState();
}

class _TaskInListState extends State<TaskInList> {
  final ref = FirebaseDatabase.instance.reference();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool _refresh = false;

  @override
  void initState() {
    super.initState();
    checkDone(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> listTag = [];
    DateTime dateTime = DateTime.parse(widget.task["dateTime"]);
    String time = dateTime.minute < 10
        ? "${dateTime.hour}:0${dateTime.minute}"
        : "${dateTime.hour}:${dateTime.minute}";
    if (widget.task["tags"] != null) listTag = widget.task["tags"];

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: ListTile(
        onTap: () {
          if (widget.task["isDone"] == false)
            Navigator.of(context).push(_editRoute(widget.task));
        },
        title: widget.task["isDone"] == false
            ? widget.task["status"] == true
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            widget.task["title"],
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Transform.scale(
                          scale: 0.7,
                          alignment: Alignment.topLeft,
                          child: Chip(
                            backgroundColor: kPrimaryColor,
                            label: Row(
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                      fontSize: 10, color: kTextColor),
                                ),
                                widget.task["typeAlarm"] == "Repeat"
                                    ? Icon(
                                        Icons.repeat,
                                        size: 16,
                                        color: kTextColor,
                                      )
                                    : SizedBox(),
                                widget.task["typeRepeat"] == "Daily"
                                    ? Text(" Daily",
                                        style: TextStyle(
                                          color: kTextColor,
                                          fontSize: 8,
                                        ))
                                    : widget.task["typeRepeat"] == "Weekly"
                                        ? Text(" Weekly",
                                            style: TextStyle(
                                              color: kTextColor,
                                              fontSize: 8,
                                            ))
                                        : SizedBox()
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            widget.task["title"],
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Opacity(
                          opacity: 0.8,
                          child: Transform.scale(
                            scale: 0.7,
                            alignment: Alignment.topLeft,
                            child: Chip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(time,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 10)),
                                  widget.task["typeAlarm"] == "Repeat"
                                      ? Icon(
                                          Icons.repeat,
                                          size: 16,
                                          color: Colors.grey,
                                        )
                                      : SizedBox(),
                                  widget.task["typeRepeat"] == "Daily"
                                      ? Text(" Daily",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 8,
                                          ))
                                      : widget.task["typeRepeat"] == "Weekly"
                                          ? Text(" Weekly",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 8,
                                              ))
                                          : SizedBox()
                                ],
                              ),
                            ),
                          ))
                    ],
                  )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      ' ${widget.task["title"]} ',
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
        subtitle: SubTitle(listTag: listTag),
        dense: true,
        leading: widget.task["isDone"] == false
            ? Icon(Icons.panorama_fish_eye)
            : Icon(Icons.check_circle),
        trailing: widget.task["isDone"] == false
            ? Transform.scale(
                scale: 1.4,
                child: Switch(
                  value: widget.task["status"],
                  onChanged: (bool newValue) async {
                    setState(() {
                      widget.task["status"] = newValue;
                    });
                    changeStatus(widget.task, newValue);
                  },
                ),
              )
            : IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  _deleteTask(widget.task["key"]);
                }),
      ),
    );
  }

  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  Future _deleteTask(String key) async {
    String path = "users/${auth.currentUser.uid}/tasks/$key";
    await ref.child(path).update({"isDeleted": true});
  }

  void _refreshPage() {
    setState(() {
      _refresh = !_refresh;
    });
  }

  Route _editRoute(var taskEdit) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => EditPage(
        taskEdit: taskEdit,
        homeRefresh: _refreshPage,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
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
          .update({"dateTime": newDateTime.toString()});
    }

    await ref.child(path).child(task["key"]).update({"status": newValue});
  }

  Future checkDone(Map<String, dynamic> task) async {
    DateTime now = DateTime.now();
    DateTime taskDateTime = DateTime.parse(task["dateTime"]);
    if (task["typeAlarm"] == "One Time" &&
        taskDateTime.isBefore(now) &&
        task["status"] == true) {
      await changeStatus(task, false);
      _refreshPage();
    }
  }

  void _showWarningToast(BuildContext context, String title, String content) {
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.yellow[900],
      duration: Duration(seconds: 2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(content)
        ],
      ),
    ));
  }
}
