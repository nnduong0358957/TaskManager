import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_list_app/screens/edit_task/edit_task.dart';
import 'package:todo_list_app/screens/home_page/subTitle.dart';
import 'package:todo_list_app/constants.dart';

class TaskInList extends StatefulWidget {
  TaskInList({this.task});

  final Map<String, dynamic> task;

  @override
  _TaskInListState createState() => _TaskInListState();
}

class _TaskInListState extends State<TaskInList> {
  final ref = FirebaseDatabase.instance.reference();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final SlidableController slidableController = SlidableController();

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
          gradient: widget.task["status"]
              ? LinearGradient(
                  colors: [
                    const Color(0xFFBCC6FF),
                    const Color(0xFFF1F7FF),
                  ],
                  begin: const FractionalOffset(0.0, 2.0),
                  end: const FractionalOffset(3.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp)
              : null,
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
        child: ConstrainedBox(
          constraints: new BoxConstraints(
            minHeight: 50.0,
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
                    color: Colors.black.withOpacity(0.6),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildTimeField(String time) {
    return Container(
      margin: EdgeInsets.only(right: 10),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: size.width - 210,
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
                ? Container()
                : IconButton(
                    icon: Icon(
                      Icons.cancel,
                      size: 30,
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
