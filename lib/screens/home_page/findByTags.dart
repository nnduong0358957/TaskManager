import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:todo_list_app/components/type_of_work/dialogTypeOfWork.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_list_app/screens/home_page/taskInList.dart';
import 'package:collection/collection.dart';
import 'package:todo_list_app/constants.dart';

class FindByTags extends StatefulWidget {
  FindByTags({this.listTask, this.typeOfWork, this.refreshPage});

  final List<dynamic> listTask, typeOfWork;
  final VoidCallback refreshPage;

  @override
  _FindByTagsState createState() => _FindByTagsState();
}

class _FindByTagsState extends State<FindByTags> {
  final SlidableController slidableController = SlidableController();
  List<dynamic> _listSelectedTag = [];
  List<dynamic> _listTaskFound = [];

  bool _refresh = true;

  @override
  Widget build(BuildContext context) {
    final _tags =
        widget.typeOfWork.map((e) => MultiSelectItem<String>(e, e)).toList();

    setList();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 16),
            child: Text(
              "Chọn loại công việc cần tìm:",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MultiSelectDialogField(
              items: _tags,
              initialValue: _listSelectedTag,
              title: Text("Loại công việc"),
              selectedColor: Colors.blue,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              buttonIcon: Icon(
                null,
                color: Colors.blue,
              ),
              buttonText: Text(
                "Chọn loại công việc",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              onConfirm: (results) {
                _listSelectedTag = results;
                _refreshPage();
              },
              chipDisplay: MultiSelectChipDisplay(
                onTap: (value) {
                  setState(() {
                    _listSelectedTag.remove(value);
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: DialogTypeOfWork(
                  listTask: widget.listTask,
                  typeOfWork: widget.typeOfWork,
                  refreshPage: widget.refreshPage),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Specify the generic type of the data in the list.
          // Specify the generic type of the data in the list.
          _listTaskFound.length == 0
              ? Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('Không có công việc'),
                )
              : ImplicitlyAnimatedList<dynamic>(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  // The current items in the list.
                  items: _listTaskFound,
                  insertDuration: Duration(seconds: 1),
                  removeDuration: Duration(seconds: 1),
                  updateDuration: Duration(seconds: 1),
                  areItemsTheSame: (a, b) => a["key"] == b["key"],
                  itemBuilder: (context, animation, item, index) {
                    return SlideTransition(
                        position: animation.drive(Tween<Offset>(
                                begin: Offset(1, 0), end: Offset(0, 0))
                            .chain(CurveTween(curve: Curves.easeInOutBack))),
                        child: Slidable(
                          child: TaskInList(task: _listTaskFound[index]),
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
                                await changeStatus(item, !item["status"]);
                              },
                            ),
                          ],
                        ));
                  },
                  removeItemBuilder: (context, animation, oldItem) {
                    return FadeTransition(
                        opacity: animation, child: TaskInList(task: oldItem));
                  },
                ),
          SizedBox(
            height: 200,
          ),
        ],
      ),
    );
  }

  Future setList() async {
    if (_listSelectedTag.length != 0) {
      _listTaskFound = [];

      Function eq = const ListEquality().equals;

      widget.listTask.forEach((task) {
        List<dynamic> tags = task["tags"];
        if (tags != null) {
          var setListSelectedTag = _listSelectedTag.toSet();

          var setListTag = tags.toSet();

          List<dynamic> result =
              setListSelectedTag.intersection(setListTag).toList();
          if (eq(result, _listSelectedTag)) _listTaskFound.add(task);
        }
      });
    } else
      setState(() {
        _listTaskFound = widget.listTask;
      });
  }

  void _refreshPage() {
    setState(() {
      _refresh = !_refresh;
    });
  }
}
