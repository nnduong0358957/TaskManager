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
    final size = MediaQuery.of(context).size;
    List<dynamic> listTag = [];
    DateTime dateTime = DateTime.parse(widget.task["dateTime"]);
    String time = dateTime.minute < 10
        ? "${dateTime.hour}:0${dateTime.minute}"
        : "${dateTime.hour}:${dateTime.minute}";
    if (widget.task["tags"] != null) listTag = widget.task["tags"];

    return ListTile(
      onTap: () {
        if (widget.task["isDone"] == false)
          Navigator.of(context).push(_editRoute(widget.task));
      },
      title: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFE2E2EA),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 1.0,
              spreadRadius: 0.0,
              offset: Offset(2.0, 2.0), // shadow direction: bottom right
            )
          ],
        ),
        child: Opacity(
          opacity: widget.task["status"] ? 1 : 0.5,
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildTimeField(time),
                VerticalDivider(
                  thickness: 2,
                  width: 1,
                  color: Colors.grey.withOpacity(0.6),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildTitle(size),
                    widget.task["content"] != ""
                        ? Row(
                            children: [
                              widget.task["content"] == ""
                                  ? SizedBox()
                                  : Icon(Icons.assignment_outlined),
                              SizedBox(width: 5),
                              Container(
                                  width: size.width - 200,
                                  child: Text(
                                    widget.task["content"],
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          )
                        : Container(),
                    Container(
                        width: size.width - 180,
                        child: SubTitle(listTag: listTag))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildTimeField(String time) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          widget.task["typeAlarm"] == "Repeat"
              ? Icon(
                  Icons.repeat,
                  size: 16,
                )
              : Divider(
                  height: 1,
                ),
          widget.task["typeAlarm"] == "Repeat"
              ? widget.task["typeRepeat"] == "Daily"
                  ? Text("Hàng ngày",
                      style: TextStyle(
                        fontSize: 8,
                      ))
                  : widget.task["typeRepeat"] == "Weekly"
                      ? Text("Hàng tuần",
                          style: TextStyle(
                            fontSize: 8,
                          ))
                      : widget.task["typeRepeat"] == "Period"
                          ? Text(
                              "${widget.task['periodTime']} ${widget.task['timeUnit'] == "Minutes" ? "phút" : widget.task['timeUnit'] == "Hours" ? "giờ" : widget.task['timeUnit'] == "Days" ? "ngày" : ""}",
                              style: TextStyle(
                                fontSize: 8,
                              ))
                          : SizedBox()
              : SizedBox()
        ],
      ),
    );
  }

  Container buildTitle(Size size) {
    return Container(
        width: size.width - 160,
        child: Row(
          children: [
            Container(
              width: size.width - 240,
              child: Text(
                widget.task["title"],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decorationThickness: 2,
                    decoration: widget.task["isDone"]
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
            widget.task["isDone"] == false
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
                    icon: Icon(
                      Icons.cancel,
                      size: 36,
                    ),
                    onPressed: () {
                      _deleteTask(widget.task["key"]);
                    })
          ],
        ));
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
