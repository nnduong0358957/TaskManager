import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list_app/components/drawer.dart';
import 'package:todo_list_app/constants.dart';
import 'package:todo_list_app/screens/add_task_page/add_task.dart';
import 'package:todo_list_app/components/color_loader_2.dart';
import 'package:todo_list_app/screens/home_page/events_calendar.dart';
import 'package:todo_list_app/screens/home_page/findByTags.dart';
import 'package:todo_list_app/screens/home_page/list_expansion.dart';
import 'package:todo_list_app/modules/NotificationService.dart';
import 'package:cron/cron.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({this.auth, this.onSignOut, this.app});

  final FirebaseApp app;
  final FirebaseAuth auth;
  final VoidCallback onSignOut;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool refresh = true;
  var ref;
  bool checkWhenOpen = false;
  String isDone;
  String path;
  List<dynamic> listTask = [];
  List<dynamic> typeOfWork = [];
  final Map<String, dynamic> listCategory = {
    "Today": [],
    "Tomorrow": [],
    "Upcoming": [],
    "One Time": [],
    "Repeat": []
  };

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    print("Create HomePage");

    if (isDone != null) {
      if (checkWhenOpen == false) {
        listTask.forEach((element) {
          if (element["status"] == true) checkIsShow(element);
        });
      }

      alertStatusTask();

      notification();
      refreshEveryMinute();
      return DefaultTabController(
          length: 4,
          child: SafeArea(
            child: Scaffold(
                drawer:
                    AppDrawer(auth: widget.auth, onSignOut: widget.onSignOut),
                appBar: AppBar(
                  flexibleSpace: buildColorGradient(),
                  bottom: TabBar(
                    tabs: [
                      Tab(
                        icon: Icon(Icons.calendar_today_rounded),
                      ),
                      Tab(
                        icon: Icon(Icons.access_time),
                      ),
                      Tab(
                        icon: Icon(Icons.repeat),
                      ),
                      Tab(
                        icon: Icon(Icons.work_outlined),
                      ),
                    ],
                  ),
                  title: Text(
                    'All Tasks',
                    style: GoogleFonts.lato(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: kTextColor),
                  ),
                ),
                floatingActionButton: Container(
                  width: 80,
                  height: 80,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(_createRoute());
                    },
                    tooltip: 'Add task',
                    child: Icon(
                      Icons.add,
                      size: 50,
                    ),
                  ),
                ),
                body: TabBarView(
                  children: [
                    SingleChildScrollView(
                        child: Column(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height,
                            child: TableCalendarWithEvents(listTask: listTask)),
                      ],
                    )),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          ListExpansion(
                              title: "Today", listTask: listCategory["Today"]),
                          ListExpansion(
                              title: "Tomorrow",
                              listTask: listCategory["Tomorrow"]),
                          ListExpansion(
                            title: "Upcoming",
                            listTask: listCategory["Upcoming"],
                          ),
                          SizedBox(
                            height: 200,
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          ListExpansion(
                              title: "One Time",
                              listTask: listCategory["One Time"]),
                          ListExpansion(
                              title: "Repeat",
                              listTask: listCategory["Repeat"]),
                          SizedBox(
                            height: 200,
                          )
                        ],
                      ),
                    ),
                    FindByTags(
                        listTask: listTask,
                        typeOfWork: typeOfWork,
                        refreshPage: refreshPage),
                  ],
                )),
          ));
    } else
      return SafeArea(
          child: Scaffold(
              body: Center(
                  child: Transform.scale(
        scale: 2,
        child: ColorLoader2(
          color1: Colors.red[800],
          color2: Colors.blue[600],
          color3: Colors.purple,
        ),
      ))));
  }

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  Future loadData() async {
    ref = FirebaseDatabase.instance.reference();

    await ref
        .child("users/${widget.auth.currentUser.uid}/typeOfWork")
        .onValue
        .listen((event) {
      var dataSnapshot = event.snapshot;
      List<dynamic> values = dataSnapshot.value;
      if (values != null) {
        typeOfWork = values;
      } else
        initialTypeOfWork();
    });

    await ref.child(path).onValue.listen((event) {
      print("Read data to list");
      var dataSnapshot = event.snapshot;
      List listToday = [],
          listTomorrow = [],
          listUpcoming = [],
          listOneTime = [],
          listRepeat = [];
      Map<dynamic, dynamic> values = dataSnapshot.value;
      listTask.clear();

      if (values != null) {
        int i = 0;
        values.forEach((key, value) {
          i++;
          var task = {
            "id": i,
            "key": key,
            "title": value["title"],
            "content": value["content"],
            "typeAlarm": value["typeAlarm"],
            "dateTime": value["dateTime"],
            "typeRepeat": value["typeRepeat"],
            "periodTime": value["periodTime"],
            "timeUnit": value["timeUnit"],
            "subTasks": value["subTasks"],
            "status": value["status"],
            "isDone": value["isDone"],
            "tags": value["tags"],
            "isMiss": value["isMiss"],
            "isShow": value["isShow"],
            "isAlertMiss": value["isAlertMiss"],
            "isAlertRemind": value["isAlertRemind"]
          };

          if (value["isDeleted"] == false) {
            listTask.add(task);
          }
        });

        sortList(
            listToday, listTomorrow, listUpcoming, listOneTime, listRepeat);
      }

      setState(() {
        isDone = "Done";
      });
    });
  }

  Future<String> readData() async {
    print("Read data");

    path = "users/${widget.auth.currentUser.uid}/tasks";

    await loadData();

    return isDone;
  }

  // Kiểm tra task đã được thông báo hay chưa, nếu rồi thì isShow = true.
  Future checkIsShow(Map<String, dynamic> task) async {
    final path = "users/${widget.auth.currentUser.uid}/tasks";

    DateTime now = DateTime.now();
    DateTime taskDateTime = DateTime.parse(task["dateTime"]);
    DateTime timeWaitNotification = taskDateTime.add(Duration(minutes: 5));

    // Nếu bật app lên trong thời gian chờ xác nhận thông báo thì isMiss = false, isShow = true
    if (timeWaitNotification.isAfter(now) &&
        now.isAfter(taskDateTime) &&
        task["isAlertRemind"] == false) {
      await ref
          .child(path)
          .child(task["key"])
          .update({"isMiss": false, "isShow": true});
    }

    if (task["typeAlarm"] == "Repeat") {
      if (task["typeRepeat"] == "Daily") {
        while (now.isAfter(taskDateTime)) {
          // Đưa task date đến ngày thông báo gần nhất
          setState(() {
            taskDateTime = taskDateTime.add(Duration(days: 1));
          });
        }
      } else if (task["typeRepeat"] == "Weekly") {
        while (now.isAfter(taskDateTime)) {
          // Đưa task date đến ngày thông báo gần nhất
          setState(() {
            taskDateTime = taskDateTime.add(Duration(days: 7));
          });
        }
      } else if (task["typeRepeat"] == "Period") {
        while (now.isAfter(taskDateTime)) {
          // Đưa task date đến ngày thông báo gần nhất
          if (task["timeUnit"] == "Minutes") {
            taskDateTime =
                taskDateTime.add(Duration(minutes: task["periodTime"]));
          } else if (task["timeUnit"] == "Hours") {
            taskDateTime =
                taskDateTime.add(Duration(hours: task["periodTime"]));
          } else if (task["timeUnit"] == "Days") {
            taskDateTime = taskDateTime.add(Duration(days: task["periodTime"]));
          }
        }
      }
    }

    // Nếu waitTime < now => isShow = true
    if (timeWaitNotification.isBefore(now) && task["isAlertMiss"] == false) {
      await ref.child(path).child(task["key"]).update({
        "isMiss": true,
        "isShow": true,
        "isAlertMiss": false,
      });
    }

    //Cập nhật lại ngày thông báo của loại thông báo lặp lại (Repeat)
    if (task["typeAlarm"] == "Repeat" &&
        task["isShow"] == false &&
        task["isMiss"] == true) {
      // Reset sau khi thông báo bị MISS
      if (task["isAlertMiss"] == true) {
        await ref.child(path).child(task["key"]).update({
          "dateTime": taskDateTime.toString(),
          "isShow": false,
          "isMiss": true,
          "isAlertMiss": false,
          "isAlertRemind": false
        });
      } else
      // Reset sau khi nhận được thông báo remind
      if (task["isAlertRemind"] == true) {
        await ref.child(path).child(task["key"]).update({
          "dateTime": taskDateTime.toString(),
          "isShow": false,
          "isMiss": true,
          "isAlertMiss": false,
          "isAlertRemind": false
        });
      }
    }
  }

  void alertStatusTask() {
    List<dynamic> listTaskMiss = [], listRemind = [];

    listTask.forEach((element) async {
      // Thêm vào list Task bị MISS
      if (element["isMiss"] == true &&
          element["isShow"] == true &&
          element["status"] == true &&
          element["isAlertMiss"] == false) {
        listTaskMiss.add(element);
      }

      // Thêm vào list Task đã nhận được
      if (element["isMiss"] == false &&
          element["isShow"] == true &&
          element["status"] == true &&
          element["isAlertRemind"] == false) {
        listRemind.add(element);
        if (element["typeAlarm"] == "One Time") {
          await ref.child(path).child(element["key"]).update({
            "isShow": false,
            "status": false,
            "isMiss": true,
            "isAlertRemind": true
          });
        } else if (element["typeAlarm"] == "Repeat") {
          await ref
              .child(path)
              .child(element["key"])
              .update({"isShow": false, "isMiss": true, "isAlertRemind": true});
        }
      }
    });
    if (listTaskMiss.length != 0) {
      _showAlert(listTaskMiss);
    }

    if (listRemind.length != 0) {
      remindTask(listRemind);
    }
  }

  Future<bool> checkConnection(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connect with wifi mobile");
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connect with wifi");
      return true;
    }

    return false;
  }

//Animation for Navigator
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddPage(
        typeOfWork: typeOfWork,
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

  void sortList(
      List<dynamic> listToday,
      List<dynamic> listTomorrow,
      List<dynamic> listUpcoming,
      List<dynamic> listOneTime,
      List<dynamic> listRepeat) {
    // listTask.sort((b, a) => a['title'].toLowerCase().compareTo(b['title'].toLowerCase()));

    listTask.sort((a, b) {
      if (b["status"] || a["isDone"]) {
        return 1;
      }
      return -1;
    });

    listTask.forEach((element) {
      DateTime now = new DateTime.now();
      DateTime dateNow = new DateTime(now.year, now.month, now.day);
      DateTime tomorrow =
          DateTime(dateNow.year, dateNow.month, dateNow.day + 1);

      DateTime dateTime = DateTime.parse(element["dateTime"]);
      DateTime taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (taskDate == dateNow) listToday.add(element);
      if (taskDate == tomorrow) listTomorrow.add(element);
      if (taskDate != dateNow && taskDate != tomorrow)
        listUpcoming.add(element);

      if (element["typeAlarm"] == "One Time")
        listOneTime.add(element);
      else
        listRepeat.add(element);
    });

    listCategory["Today"] = listToday;
    listCategory["Tomorrow"] = listTomorrow;
    listCategory["Upcoming"] = listUpcoming;
    listCategory["One Time"] = listOneTime;
    listCategory["Repeat"] = listRepeat;
  }

  void notification() {
    NotificationService().initialize(listTask);
    NotificationService().cancelNotification();
    listTask.asMap().forEach((index, element) {
      if (element["status"] == true && element["isDone"] == false) {
        if (element["typeAlarm"] == "One Time") {
          NotificationService().instantNotification(element, index);
        } else if (element["typeAlarm"] == "Repeat")
          NotificationService().scheduledNotification(element, index);
      }
    });
  }

  //Hàm thông báo có công việc
  void _showAlertDialog(BuildContext context, String content) {
    AlertDialog alertDialog = AlertDialog(
      title: Container(
        width: 100,
        height: 100,
        child: Image.asset("assets/images/reminder.png"),
      ),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        FlatButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))
      ],
    );
    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  void refreshPage() {
    setState(() {
      refresh = !refresh;
    });
  }

  // Hàm thông báo bỏ lỡ công việc
  void _showAlert(List<dynamic> listTaskMiss) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
          title: Container(
            width: 100,
            height: 100,
            child: Image.asset("assets/images/warning.png"),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text("You have missed out on some tasks recently"),
              ),
              Container(
                height: deviceHeight * 20 / 100,
                width: deviceWidth * 80 / 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: listTaskMiss.length,
                  itemBuilder: (BuildContext context, int index) {
                    DateTime taskMissDateTime =
                        DateTime.parse(listTaskMiss[index]["dateTime"]);
                    String stringTime;
                    if (taskMissDateTime.hour >= 10)
                      stringTime = "${taskMissDateTime.hour}";
                    else
                      stringTime = "0${taskMissDateTime.hour}";
                    if (taskMissDateTime.minute >= 10)
                      stringTime = stringTime + ":${taskMissDateTime.minute}";
                    else
                      stringTime = stringTime + ":0${taskMissDateTime.minute}";
                    String stringDateTime =
                        "${taskMissDateTime.day}/${taskMissDateTime.month}/${taskMissDateTime.year} at $stringTime";

                    return RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.album_outlined, size: 20),
                          ),
                          TextSpan(
                              text:
                                  " ${listTaskMiss[index]["title"]} on $stringDateTime",
                              style: TextStyle(
                                  color: Colors.yellow[800], fontSize: 22)),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: <Widget>[
            new OutlineButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              child: new Text("Remind me later"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new OutlineButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              child: new Text("OK"),
              onPressed: () {
                listTaskMiss.forEach((element) {
                  ref
                      .child(path)
                      .child(element["key"])
                      .update({"isAlertMiss": true});
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    });
  }

  void remindTask(List<dynamic> listRemind) {
    listRemind.forEach((task) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog(context, "You should to do ${task["title"]} now!");
      });
    });
  }

  void refreshEveryMinute() {
    print("check dialog");
    var cron = new Cron();
    cron.schedule(new Schedule.parse('* * * * *'), () async {
      listTask.forEach((element) async {
        if (element["status"] == true) await checkIsShow(element);
      });

      alertStatusTask();
    });
  }

  Future initialTypeOfWork() async {
    List<String> listTag = [
      "Priority",
      "Important",
      "Deadline",
      "Family",
      "Work",
      "In Progress"
    ];
    await ref
        .child("users/${widget.auth.currentUser.uid}/typeOfWork")
        .set(listTag);
  }
}
