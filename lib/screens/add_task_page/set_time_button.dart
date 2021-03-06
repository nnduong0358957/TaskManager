import 'package:flutter/material.dart';
import 'package:todo_list_app/constants.dart';

class SetTimeButton extends StatefulWidget {
  const SetTimeButton(
      {Key key, this.selectedDateTimeString, this.selectTimeAlert})
      : super(key: key);

  final String selectedDateTimeString;

  // ignore: non_constant_identifier_names
  final VoidCallback selectTimeAlert;

  @override
  _SetTimeButtonState createState() => _SetTimeButtonState();
}

class _SetTimeButtonState extends State<SetTimeButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.selectedDateTimeString != null)
      return Container();
    else {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10.0),
        child: RaisedButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.date_range,
                color: kPrimaryColor,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  "Chọn thời gian",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: kPrimaryColor),
                ),
              ),
            ],
          ),
          onPressed: () {
            widget.selectTimeAlert();
          },
        ),
      );
    }
  }
}
