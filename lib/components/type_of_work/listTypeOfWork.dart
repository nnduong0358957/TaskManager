import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/constants.dart';

class ListTypeOfWork extends StatefulWidget {
  ListTypeOfWork({this.typeOfWork, this.updateNewList});

  final List<dynamic> typeOfWork;
  final Function(List<String>) updateNewList;

  @override
  _ListTypeOfWorkState createState() => _ListTypeOfWorkState();
}

class _ListTypeOfWorkState extends State<ListTypeOfWork> {
  TextEditingController typeOfWorkController = TextEditingController();
  final List<String> newList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.typeOfWork.forEach((element) {
      newList.add(element);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextField(),
          SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.topRight,
            child: RaisedButton(
              color: kPrimaryColor,
              textColor: kTextColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                setState(() {
                  if (typeOfWorkController.text.trim() != "") {
                    newList.add(typeOfWorkController.text.trim());
                    typeOfWorkController.text = "";
                    widget.updateNewList(newList);
                  }
                });
              },
              child: Text("Add"),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Wrap(
            spacing: 4,
            children: [
              ...newList.map((e) => Chip(
                    label: Text(e),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () {
                      if (newList.length > 1) {
                        setState(() {
                          newList.remove(e);
                          widget.updateNewList(newList);
                        });
                      } else
                        _showAlertDialog(context,
                            "List of job types must have at least one");
                    },
                  ))
            ],
          ),
        ],
      ),
    );
  }

  TextField buildTextField() {
    return TextField(
      controller: typeOfWorkController,
      maxLines: null, // để có thể nhập nhiều dòng trong TextField
      decoration: InputDecoration(
          labelText: "Add type",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }

  Future update() async {
    final auth = FirebaseAuth.instance;
    final ref = FirebaseDatabase.instance.reference();

    ref.child("users/${auth.currentUser.uid}/typeOfWork").set(newList);
  }

  //Hàm thông báo có công việc
  void _showAlertDialog(BuildContext context, String content) {
    AlertDialog alertDialog = AlertDialog(
      title: Container(
        width: 100,
        height: 100,
        child: Image.asset("assets/images/warning.png"),
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
}
