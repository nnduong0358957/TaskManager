import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list_app/constants.dart';
import 'package:todo_list_app/screens/home_page/taskInList.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';

class ListExpansion extends StatefulWidget {
  ListExpansion({this.title, this.listTask});

  final List listTask;
  final String title;

  @override
  _ListExpansionState createState() => _ListExpansionState();
}

class _ListExpansionState extends State<ListExpansion> {
  bool expansionStatus = false;

  @override
  Widget build(BuildContext context) {
    int number = widget.listTask.length;

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: ExpansionTile(
        initiallyExpanded: expansionStatus,
        onExpansionChanged: (value) {
          setState(() {
            expansionStatus = value;
          });
        },
        backgroundColor: Colors.white,
        leading: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(.07),
            child: Icon(
              Icons.list,
              color: Theme.of(context).primaryColor,
            )),
        trailing: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(.07),
          child: expansionStatus == false
              ? Text(
                  number.toString(),
                  style: TextStyle(color: Colors.blue),
                )
              : Icon(Icons.keyboard_arrow_up),
          foregroundColor: Colors.blue,
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.lato(
              fontSize: 20, fontWeight: FontWeight.w700, color: kPrimaryColor),
        ),
        expandedAlignment: Alignment.topLeft,
        children: [
          // Specify the generic type of the data in the list.
          ImplicitlyAnimatedList<dynamic>(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            // The current items in the list.
            items: widget.listTask,
            insertDuration: Duration(seconds: 1),
            removeDuration: Duration(seconds: 1),
            updateDuration: Duration(seconds: 1),
            areItemsTheSame: (a, b) => a["key"] == b["key"],
            itemBuilder: (context, animation, item, index) {
              return SlideTransition(
                  position: animation.drive(
                      Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                          .chain(CurveTween(curve: Curves.easeInOutBack))),
                  child: TaskInList(task: widget.listTask[index]));
            },
            removeItemBuilder: (context, animation, oldItem) {
              return FadeTransition(
                  opacity: animation, child: TaskInList(task: oldItem));
            },
          )
        ],
      ),
    );
  }
}
