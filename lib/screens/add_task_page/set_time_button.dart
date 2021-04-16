import 'package:flutter/material.dart';

class SetTimeButton extends StatefulWidget {
  const SetTimeButton(
      {Key key,
      this.selectedDateTimeString,
      this.ChangeSelectedTime,
      this.selectTimeAlert})
      : super(key: key);

  final String selectedDateTimeString;
  // ignore: non_constant_identifier_names
  final VoidCallback ChangeSelectedTime;
  final VoidCallback selectTimeAlert;

  @override
  _SetTimeButtonState createState() => _SetTimeButtonState();
}

class _SetTimeButtonState extends State<SetTimeButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.selectedDateTimeString != null)
      return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.topRight,
          child: RaisedButton(
              onPressed: () {
                widget.ChangeSelectedTime();
              },
              child: Text("Remove")),
        ),
      );
    else {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: RaisedButton(
                  child: Row(
                    children: [
                      Icon(Icons.date_range),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          "Set time",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    widget.selectTimeAlert();
                  },
                ),
              ),
            ),
            Expanded(child: SizedBox()),
          ],
        ),
      );
    }
  }
}
