import 'package:flutter/material.dart';

class SubTitle extends StatefulWidget {
  SubTitle({this.listTag});

  final List<dynamic> listTag;

  @override
  _SubTitleState createState() => _SubTitleState();
}

class _SubTitleState extends State<SubTitle> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...widget.listTag.map((e) {
            return Transform.scale(
              alignment: Alignment.topLeft,
              scale: 0.9,
              child: Chip(
                backgroundColor: Colors.blue[300],
                  label: Text(
                e,
                style: TextStyle(fontSize: 10, color: Colors.white),
              )),
            );
          })
        ],
      ),
    );
  }
}
