import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_list_app/constants.dart';
import 'package:todo_list_app/screens/home_page/taskInList.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TableCalendarWithEvents extends StatefulWidget {
  TableCalendarWithEvents({this.listTask});

  final List<dynamic> listTask;

  @override
  _TableCalendarWithEventsState createState() =>
      _TableCalendarWithEventsState();
}

class _TableCalendarWithEventsState extends State<TableCalendarWithEvents> {
  final SlidableController slidableController = SlidableController();
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  Map<DateTime, List<dynamic>> eventSource;
  Map<DateTime, List<dynamic>> events;
  ValueNotifier<List<dynamic>> _selectedEvents;

  List<dynamic> listEvent = [];

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay, _rangeStart, _rangeEnd;

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
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: _rangeSelectionMode,
            calendarStyle: CalendarStyle(
                weekendTextStyle: TextStyle(color: Colors.red),
                defaultTextStyle: TextStyle(color: kPrimaryColor),
                todayDecoration: BoxDecoration(
                    color: Colors.yellow[800], shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(
                    color: Colors.green[500], shape: BoxShape.circle)),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
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
                          var listTaskEvents = [];
                          widget.listTask.forEach((task) {
                            if (value.contains(task['key']))
                              listTaskEvents.add(task);
                          });
                          return ImplicitlyAnimatedList<dynamic>(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            // The current items in the list.
                            items: listTaskEvents,
                            insertDuration: Duration(seconds: 0),
                            removeDuration: Duration(milliseconds: 600),
                            updateDuration: Duration(seconds: 1),
                            areItemsTheSame: (a, b) => a["key"] == b["key"],
                            itemBuilder: (context, animation, item, index) {
                              return SlideTransition(
                                  position: animation.drive(Tween<Offset>(
                                          begin: Offset(1, 0),
                                          end: Offset(0, 0))
                                      .chain(CurveTween(
                                          curve: Curves.easeInOutBack))),
                                  child: Slidable(
                                    child: TaskInList(task: item),
                                    key: Key(item['key']),
                                    controller: slidableController,
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.25,
                                    secondaryActions: [
                                      SlideAction(
                                        color: Color(0xFFE2E2EA),
                                        child: Text(
                                          item["status"] ? 'Tắt' : 'Bật',
                                          style: TextStyle(
                                              color: item["status"]
                                                  ? Colors.red[300]
                                                  : Colors.green[600],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        onTap: () async {
                                          await changeStatus(
                                              item, !item["status"]);
                                        },
                                      ),
                                    ],
                                  ));
                            },
                            removeItemBuilder: (context, animation, oldItem) {
                              return FadeTransition(
                                  opacity: animation,
                                  child: TaskInList(task: oldItem));
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _rangeEnd = null;
        _rangeStart = null;
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }

  void _onRangeSelected(start, end, focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  List<dynamic> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  List<DateTime> daysInRange(DateTime first, DateTime last) {
    final dayCount = last.difference(first).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(first.year, first.month, first.day + index),
    );
  }

  List<dynamic> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getEventsForDays(days);
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

    if (_selectedDay != null) {
      _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    }
  }
}
