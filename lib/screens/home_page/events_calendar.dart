import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_list_app/constants.dart';
import 'package:todo_list_app/screens/home_page/taskInList.dart';

class TableCalendarWithEvents extends StatefulWidget {
  TableCalendarWithEvents({this.listTask});

  final List<dynamic> listTask;

  @override
  _TableCalendarWithEventsState createState() =>
      _TableCalendarWithEventsState();
}

class _TableCalendarWithEventsState extends State<TableCalendarWithEvents> {
  Map<DateTime, List<dynamic>> eventSource;
  Map<DateTime, List<dynamic>> events;
  ValueNotifier<List<dynamic>> _selectedEvents;

  List<dynamic> listEvent = [];

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    initial();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime(kNow.year - 1, kNow.month, kNow.day),
            lastDay: DateTime(
                kNow.year + 2, kNow.month, kNow.day, kNow.hour, kNow.minute),
            focusedDay: _focusedDay,
            calendarStyle: CalendarStyle(
                weekendTextStyle: TextStyle(color: Colors.red),
                defaultTextStyle: TextStyle(color: kPrimaryColor)),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 26, right: 26, top: 8, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: Divider(
                      height: 1,
                      thickness: 2,
                      color: Colors.grey.withOpacity(0.6),
                    )),
                    Text(
                      'Công việc',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        color: Colors.blue[400],
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Expanded(
                        child: Divider(
                      height: 1,
                      thickness: 2,
                      color: Colors.grey.withOpacity(0.6),
                    )),
                  ],
                ),
              ),
              _selectedEvents.value.length != 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 260),
                      child: ValueListenableBuilder<List<dynamic>>(
                        valueListenable: _selectedEvents,
                        builder: (context, value, _) {
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              return buildTaskInList(value[index]);
                            },
                          );
                        },
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Không có công việc"),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTaskInList(value) {
    Map<String, dynamic> taskSelect;
    widget.listTask.forEach((task) {
      if (task["key"] == value) {
        taskSelect = task;
      }
    });
    if (taskSelect == null)
      return Text("No events");
    else
      return TaskInList(
        task: taskSelect,
      );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  void initial() {
    DateTime testDate;
    eventSource = Map.fromIterable(widget.listTask, key: (task) {
      DateTime testDateTime = DateTime.parse(task["dateTime"]);
      testDate =
          DateTime(testDateTime.year, testDateTime.month, testDateTime.day);
      return DateTime.parse(task["dateTime"]);
    }, value: (task) {
      listEvent = [];
      widget.listTask.forEach((e) {
        DateTime eDateTime = DateTime.parse(e["dateTime"]);
        DateTime eDate = DateTime(
          eDateTime.year,
          eDateTime.month,
          eDateTime.day,
        );
        if (eDate.isAtSameMomentAs(testDate)) {
          listEvent.add(e["key"]);
        }
      });
      return listEvent;
    });

    events = LinkedHashMap<DateTime, List<dynamic>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(eventSource);

    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }
}
