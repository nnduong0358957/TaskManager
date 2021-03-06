import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/components/type_of_work/listTypeOfWork.dart';
import 'package:todo_list_app/constants.dart';

class DialogTypeOfWork extends StatefulWidget {
  DialogTypeOfWork({this.listTask, this.typeOfWork, this.refreshPage});

  final List<dynamic> typeOfWork, listTask;
  final VoidCallback refreshPage;

  @override
  _DialogTypeOfWorkState createState() => _DialogTypeOfWorkState();
}

class _DialogTypeOfWorkState extends State<DialogTypeOfWork> {
  List<String> newList = [];

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        _showMyDialog(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add),
          Text("Thêm loại công việc"),
        ],
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Loại công việc'),
          content: ListTypeOfWork(
              typeOfWork: widget.typeOfWork, updateNewList: updateNewList),
          actions: <Widget>[
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Hủy'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: kPrimaryColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Lưu'),
              ),
              onPressed: () async {
                await updateFirebase(newList);
                await resetTypeOfWork(widget.listTask, newList);
                widget.refreshPage();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateNewList(List<String> list) {
    setState(() {
      newList = list;
    });
  }

  Future updateFirebase(List<String> newList) async {
    final auth = FirebaseAuth.instance;
    final ref = FirebaseDatabase.instance.reference();

    await ref.child("users/${auth.currentUser.uid}/typeOfWork").set(newList);
  }
}
