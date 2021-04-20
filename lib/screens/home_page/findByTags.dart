import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:todo_list_app/modules/task.dart';
import 'package:todo_list_app/screens/home_page/taskInList.dart';
import 'package:collection/collection.dart';

class FindByTags extends StatefulWidget {
  FindByTags({this.listTask});

  final List<dynamic> listTask;

  @override
  _FindByTagsState createState() => _FindByTagsState();
}

class _FindByTagsState extends State<FindByTags> {
  final _tags = Task.listTag.map((e) => MultiSelectItem<String>(e, e)).toList();
  List<dynamic> _listSelectedTag = [];
  List<dynamic> _listTaskFound = [];

  bool _refresh = true;

  @override
  Widget build(BuildContext context) {
    setList();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 16),
            child: Text(
              "Select tags to find:",
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
              title: Text("Tags"),
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
                "Select tags",
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
          // Specify the generic type of the data in the list.
          // Specify the generic type of the data in the list.
          ImplicitlyAnimatedList<dynamic>(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            // The current items in the list.
            items: _listTaskFound,
            insertDuration: Duration(seconds: 1, milliseconds: 40),
            removeDuration: Duration(seconds: 1),
            updateDuration: Duration(seconds: 5),
            areItemsTheSame: (a, b) => a["key"] == b["key"],
            itemBuilder: (context, animation, item, index) {
              return SlideTransition(
                  position: animation.drive(
                      Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                          .chain(CurveTween(curve: Curves.easeInOutBack))),
                  child: TaskInList(task: _listTaskFound[index]));
              // return SizeFadeTransition(
              //   sizeFraction: 0.7,
              //   curve: Curves.easeInOut,
              //   animation: animation,
              //   child: TaskInList(task: widget.listTask[index])
              // );
            },
            removeItemBuilder: (context, animation, oldItem) {
              return FadeTransition(
                  opacity: animation, child: TaskInList(task: oldItem));
            },
          ),
          SizedBox(
            height: 200,
          )
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
