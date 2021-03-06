import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:todo_list_app/constants.dart';
import 'package:todo_list_app/screens/add_task_page/TypeSelect.dart';
import 'package:todo_list_app/screens/add_task_page/list_subtasks.dart';
import 'package:todo_list_app/screens/add_task_page/selected_date_on_off.dart';
import 'package:todo_list_app/screens/add_task_page/set_time_button.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:todo_list_app/modules/task.dart';

class AddPage extends StatefulWidget {
  AddPage({this.typeOfWork});

  final List<dynamic> typeOfWork;

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final ref = FirebaseDatabase.instance.reference();

  Task newTask;

  TextEditingController titleTaskController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController subTaskController = TextEditingController();

  bool refreshPage = true;
  bool status = true;
  String selectedDateTimeString;
  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  int periodTime = 5;
  String timeUnit = "Minutes";
  List<String> listSubTask = List<String>();
  List<String> listNameOfDay = [
    "Thứ 2",
    "Thứ 3",
    "Thứ 4",
    "Thứ 5",
    "Thứ 6",
    "Thứ 7",
    "Chủ nhật"
  ];
  String _selectedType = 'One Time';
  String _typeRepeat;

  final FirebaseAuth auth = FirebaseAuth.instance;

  List<dynamic> _listSelectedTag = [];

  @override
  Widget build(BuildContext context) {
    final _tags =
        widget.typeOfWork.map((e) => MultiSelectItem<String>(e, e)).toList();

    return MaterialApp(
      theme: ThemeData(
        primaryColor: kPrimaryColor,
      ),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            flexibleSpace: buildColorGradient(),
            title: Text(
              'Thêm',
              style: GoogleFonts.lato(
                  fontSize: 26, fontWeight: FontWeight.w700, color: kTextColor),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Center(
                  child: FlatButton(
                    child: Text(
                      'Lưu',
                      style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kTextColor),
                    ),
                    onPressed: () {
                      checkData();
                    },
                  ),
                ),
              )
            ],
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/bg_addTask.jpg"),
                    fit: BoxFit.cover)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 20, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 30),
                      child: buildTextField(
                          "Tên công việc", "", titleTaskController, false),
                    ),
                    MultiSelectDialogField(
                      items: _tags,
                      title: Text("Loại công việc"),
                      barrierColor: Colors.black54,
                      searchable: true,
                      selectedColor: Colors.blue,
                      buttonIcon: Icon(Icons.work),
                      buttonText: Text(
                        "Chọn loại công việc",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onConfirm: (results) {
                        _listSelectedTag = results;
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        onTap: (value) {
                          setState(() {
                            _listSelectedTag.remove(value);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: buildTextField(
                          "Nội dung", "", contentController, false),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, top: 30),
                      child: Row(
                        children: [
                          Text(
                            "Chọn loại thông báo:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Spacer(),
                          Transform.scale(
                            scale: 0.8,
                            child: LiteRollingSwitch(
                              //initial value
                              value: false,
                              textOn: 'Lặp lại',
                              textOff: '1 lần',
                              colorOn: Colors.greenAccent[700],
                              colorOff: Colors.indigo,
                              iconOn: Icons.replay,
                              iconOff: Icons.adjust_outlined,
                              textSize: 16.0,
                              onChanged: (bool state) {
                                //Use it to manage the different states
                                if (state == true)
                                  _ChangeSelectedType("Repeat");
                                else
                                  _ChangeSelectedType("One Time");
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Thông báo vào lúc:",
                      style: TextStyle(fontSize: 16),
                    ),
                    SetTimeButton(
                        selectedDateTimeString: selectedDateTimeString,
                        selectTimeAlert: _selectTimeAlert),
                    SelectedDateOnOff(
                        selectedDateTimeString: selectedDateTimeString,
                        selectTimeAlert: _selectTimeAlert,
                        status: status,
                        changeStatus: _changeStatus),
                    SelectType(
                      selectedType: _selectedType,
                      selectedRepeat: _selectedRepeat,
                      typeRepeat: _typeRepeat,
                      periodTime: periodTime,
                      timeUnit: timeUnit,
                      changePeriodTime: changePeriodTime,
                      changeTimeUnit: changeTimeUnit,
                    ),
                    Row(
                      children: [
                        Text(
                          "Công việc phụ:",
                          style: TextStyle(fontSize: 17),
                        ),
                        Spacer(),
                        RaisedButton(
                          child: Row(
                            children: [Icon(Icons.add), Text("Thêm")],
                          ),
                          onPressed: () {
                            if (subTaskController.text.trim() != "")
                              listSubTask.add(subTaskController.text);
                            else
                              _showAlertDialog(context, "Lỗi!!!",
                                  "Bạn chưa nhập nội dung công việc phụ.");
                            subTaskController.text = "";
                            _refreshPage();
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                      child: buildTextField(
                          "Tên công việc", "", subTaskController, false),
                    ),
                    ListSubTask(
                        listSubTask: listSubTask,
                        removeFromList: removeFromList),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //Kiểm tra đã nhập đầy đủ dữ liệu cần thiết
  Future checkData() async {
    if (titleTaskController.text.trim() != "" &&
        _selectedDate != null &&
        _selectedTime != null)
      writeData();
    else
      _showAlertDialog(context, "Lỗi!!!",
          "Bạn cần đặt tên công việc và chọn thời gian thông báo để có thể lưu công việc này.");
  }

  // Nhập dữ liệu vào User
  Future writeData() async {
    String path = "users/${auth.currentUser.uid}/tasks";
    DateTime finalDateTime = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedTime.minute);

    if (_selectedType == "One Time") _typeRepeat = null;

    if (finalDateTime.isAfter(DateTime.now())) {
      newTask = Task(
        title: titleTaskController.text,
        content: contentController.text,
        typeAlarm: _selectedType,
        dateTime: finalDateTime,
        status: status,
        typeRepeat: _typeRepeat,
        subTasks: listSubTask,
        tags: _listSelectedTag,
        periodTime: _selectedType == "Repeat" && _typeRepeat == "Period"
            ? periodTime
            : null,
        timeUnit: _selectedType == "Repeat" && _typeRepeat == "Period"
            ? timeUnit
            : null,
      );

      ref.child(path).push().set({
        "title": newTask.title,
        "content": newTask.content,
        "typeAlarm": newTask.typeAlarm,
        "dateTime": newTask.dateTime.toString(),
        "typeRepeat": newTask.typeRepeat,
        "periodTime": newTask.periodTime,
        "timeUnit": newTask.timeUnit,
        "subTasks": newTask.subTasks,
        "status": newTask.status,
        "isDeleted": newTask.isDeleted,
        "isDone": newTask.isDone,
        "tags": newTask.tags,
        "isMiss": newTask.isMiss,
        "isShow": newTask.isShow,
        "isAlertMiss": newTask.isAlertMiss,
        "isAlertRemind": newTask.isAlertRemind,
        "listTimeNotificationPeriod": null,
      });

      Navigator.pop(context);
    } else {
      _selectedDate = null;
      _selectedTime = null;
      selectedDateTimeString = null;
      _refreshPage();
      _showAlertDialog(context, "Lỗi!",
          "Bạn đang chọn thời gian ở quá khứ.\n Làm ơn hãy chọn lại.");
    }
  }

  // Báo lỗi khi chưa chọn ngày hoặc giờ. Nếu đúng thì gọi hàm để đổi DateTime thành String để hiển thị
  void _selectTimeAlert() async {
    _selectedDate = await _selectDate(_selectedDate);
    if (_selectedDate == null) {
      _selectedTime = null;
      selectedDateTimeString = null;
      _showAlertDialog(context, "Lỗi!!!", "Chọn chưa chọn ngày");
      _refreshPage();
    } else {
      _selectedTime = await _selectTime(_selectedTime);
      if (_selectedTime == null) {
        selectedDateTimeString = null;
        _showAlertDialog(context, "Lỗi!!!", "Bạn chưa chọn thời gian");
        _refreshPage();
      } else {
        setState(() {
          selectedDateTimeString =
              _textFromDateTime(_selectedDate, _selectedTime);
        });
      }
    }
  }

  // Hàm chuyển đổi One Time hay Repeat
  // ignore: non_constant_identifier_names
  Future _ChangeSelectedType(String val) async {
    setState(() {
      _selectedType = val;
    });
    if (_selectedType == "Repeat" && _typeRepeat == null)
      setState(() {
        _typeRepeat = "Daily";
      });
    if (_selectedDate != null && _selectedTime != null)
      selectedDateTimeString = _textFromDateTime(_selectedDate, _selectedTime);
    _refreshPage();
  }

  // Tạo sẵn Form input Text field
  TextField buildTextField(String labelText, String hintText,
      TextEditingController controller, bool readOnly) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: null, // để có thể nhập nhiều dòng trong TextField
      decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }

  // Hàm remove giá thời gian được đặt
  // ignore: non_constant_identifier_names
  void _ChangeSelectedTime() {
    setState(() {
      selectedDateTimeString = null;
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  //Hàm gọi dialog chọn ngày tháng
  Future<DateTime> _selectDate(selectedDate) async {
    DateTime firstDate = selectedDate;
    final DateTime _pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate == null || firstDate.isBefore(DateTime.now())
          ? DateTime.now()
          : selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 50)),
    );
    return _pickedDate;
  }

  //Hàm gọi dialog chọn thời gian
  Future<TimeOfDay> _selectTime(selectedTime) async {
    TimeOfDay now = TimeOfDay.now();
    TimeOfDay timeDefault = TimeOfDay(hour: now.hour, minute: now.minute + 1);
    final TimeOfDay _pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime == null ? timeDefault : selectedTime,
    );
    return _pickedTime;
  }

  // Hàm để xác định loại Repeat đang chọn
  Future _selectedRepeat(String val) async {
    if (val == "Daily")
      setState(() {
        _typeRepeat = "Daily";
      });
    else if (val == "Weekly")
      setState(() {
        _typeRepeat = "Weekly";
      });
    else if (val == "Period")
      setState(() {
        _typeRepeat = "Period";
      });

    if (selectedDateTimeString != null)
      setState(() {
        selectedDateTimeString =
            _textFromDateTime(_selectedDate, _selectedTime);
      });
  }

  // Hàm chuyển DateTime thành String
  // ignore: missing_return
  String _textFromDateTime(DateTime selectedDate, TimeOfDay selectedTime) {
    String minute = selectedTime.minute.toString();
    if (selectedTime.minute < 10) minute = "0" + minute;
    var numberOfDayOfWeek = DateTime(selectedDate.weekday).weekday;
    String nameOfDayOfWeek;
    for (var i = 0; i < 7; i++) {
      if (i == numberOfDayOfWeek) nameOfDayOfWeek = listNameOfDay[i];
    }

    DateTime now = new DateTime.now();
    DateTime dateNow = new DateTime(now.year, now.month, now.day);
    DateTime tomorrow = DateTime(dateNow.year, dateNow.month, dateNow.day + 1);

    if (_selectedType == "One Time") {
      if (selectedDate == dateNow)
        return 'Hôm nay lúc ${selectedTime.hour}:$minute';
      else if (selectedDate == tomorrow)
        return 'Ngày mai lúc ${selectedTime.hour}:$minute';
      else
        return '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} lúc ${selectedTime.hour}:$minute';
    } else if (_selectedType == "Repeat") {
      if (_typeRepeat == "Daily")
        return "Mỗi ngày lúc ${selectedTime.hour}:$minute";
      else if (_typeRepeat == "Weekly")
        return "Mỗi tuần vào $nameOfDayOfWeek lúc ${selectedTime.hour}:$minute";
      else if (_typeRepeat == "Period")
        return "Lặp lại mỗi $periodTime ${timeUnit == "Minutes" ? "phút" : timeUnit == "Hours" ? "giờ" : timeUnit == "Days" ? "ngày" : ""} từ ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} lúc ${selectedTime.hour}:$minute";
    }
  }

// Hàm để refresh trang
  void _refreshPage() {
    setState(() {
      refreshPage = !refreshPage;
    });
  }

  void _changeStatus() {
    setState(() {
      status = !status;
    });
  }

  void removeFromList(String subTask) {
    _showDeleteYesNoDialog(
        context, "Xóa công việc phụ", "Bạn có chắc muốn xóa $subTask", subTask);
  }

// Form viết sẵn để hiển thị dialog
  void _showAlertDialog(BuildContext context, String title, String content) {
    AlertDialog alertDialog = AlertDialog(
      title: Container(
        width: 100,
        height: 100,
        child: Image.asset("assets/images/warning.png"),
      ),
      content: Text(content),
      elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: OutlineButton(
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text('OK'),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  // Form dialog Yes, No
  void _showDeleteYesNoDialog(
      BuildContext context, String title, String content, String deleteItem) {
    AlertDialog alertDialog = AlertDialog(
      title: Container(
        width: 100,
        height: 100,
        child: Image.asset("assets/images/warning.png"),
      ),
      content: Text(
        content,
        style: TextStyle(color: Colors.red, fontSize: 14),
      ),
      elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        Row(
          children: [
            OutlineButton(
              onPressed: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text('Hủy'),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: OutlineButton(
                onPressed: () {
                  listSubTask.remove(deleteItem);
                  _refreshPage();
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    'Tiếp tục',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  void changeTimeUnit(newUnit) {
    setState(() {
      timeUnit = newUnit;
    });
    if (selectedDateTimeString != null)
      setState(() {
        selectedDateTimeString =
            _textFromDateTime(_selectedDate, _selectedTime);
      });
  }

  void changePeriodTime(newTime) {
    setState(() {
      periodTime = newTime;
    });
    if (selectedDateTimeString != null)
      setState(() {
        selectedDateTimeString =
            _textFromDateTime(_selectedDate, _selectedTime);
      });
  }
}
