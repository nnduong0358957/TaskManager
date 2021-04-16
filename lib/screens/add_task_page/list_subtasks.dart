import 'package:flutter/material.dart';

class ListSubTask extends StatefulWidget {
  const ListSubTask({Key key, @required this.listSubTask, this.removeFromList})
      : super(key: key);

  final List<String> listSubTask;
  final Function(String) removeFromList;

  @override
  _ListSubTaskState createState() => _ListSubTaskState();
}

class _ListSubTaskState extends State<ListSubTask> {
  @override
  Widget build(BuildContext context) {
    if (widget.listSubTask != null)
      return Column(
        children: [
          ...widget.listSubTask.map((e) => Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.panorama_fish_eye, size: 16),
                        ),
                        TextSpan(
                            text: "   $e",
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        widget.removeFromList(e);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ),
              )),
          SizedBox(
            height: 50,
          )
        ],
      );
    else
      return SizedBox();
  }
}
