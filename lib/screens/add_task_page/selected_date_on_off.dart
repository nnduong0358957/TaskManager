import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectedDateOnOff extends StatefulWidget {
  const SelectedDateOnOff(
      {Key key,
      this.selectedDateTimeString,
      this.selectTimeAlert,
      this.status,
      this.changeStatus})
      : super(key: key);

  final String selectedDateTimeString;
  final VoidCallback selectTimeAlert, changeStatus;
  final bool status;

  @override
  _SelectedDateOnOffState createState() => _SelectedDateOnOffState();
}

class _SelectedDateOnOffState extends State<SelectedDateOnOff> {
  @override
  Widget build(BuildContext context) {
    if (widget.selectedDateTimeString == null)
      return Padding(padding: EdgeInsets.only(bottom: 20));
    else
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: RaisedButton(
          onPressed: () {
            widget.selectTimeAlert();
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  child: Text(widget.selectedDateTimeString ?? "",
                      style: TextStyle(
                          color: widget.status ? Colors.blue : Colors.black)),
                ),
                Transform.scale(
                  scale: 1.5,
                  child: Switch(
                    value: widget.status,
                    onChanged: (bool newValue) {
                      widget.changeStatus();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }
}
