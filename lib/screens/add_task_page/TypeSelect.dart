import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectType extends StatefulWidget {
  const SelectType(
      {Key key,
      this.selectedType,
      this.selectedRepeat,
      this.typeRepeat,
      this.periodTime,
      this.timeUnit,
      this.changeTimeUnit,
      this.changePeriodTime})
      : super(key: key);

  final String selectedType, typeRepeat, timeUnit;
  final int periodTime;

  final Function(int) changePeriodTime;
  final Function(String) selectedRepeat, changeTimeUnit;

  @override
  _SelectTypeState createState() => _SelectTypeState();
}

class _SelectTypeState extends State<SelectType> {
  List<TypeButtonModel> buttonList = new List<TypeButtonModel>();
  TextEditingController periodTimeController = TextEditingController();

  List<String> listUnitTime = ['Minutes', 'Hours', 'Days'];

  bool refresh = true;

  void _refreshPage() {
    setState(() {
      refresh = !refresh;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buttonList.add(new TypeButtonModel(false, 'Daily'));
    buttonList.add(new TypeButtonModel(false, 'Period'));
    buttonList.add(new TypeButtonModel(false, 'Weekly'));

    periodTimeController.text = widget.periodTime.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedType == "Repeat") {
      resetSelectType();
      return Column(
        children: [
          Center(
            child: Container(
              height: 120,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: buttonList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: RawMaterialButton(
                      onPressed: () {
                        buttonList
                            .forEach((element) => element.isSelected = false);
                        buttonList[index].isSelected = true;
                        widget.selectedRepeat(buttonList[index].buttonText);
                      },
                      elevation: 2.0,
                      fillColor: buttonList[index].isSelected
                          ? Colors.blueAccent
                          : Colors.white,
                      child: Container(
                        width: 70,
                        child: Text(
                          buttonList[index].buttonText == "Daily"
                              ? "H??ng ng??y"
                              : buttonList[index].buttonText == "Weekly"
                                  ? "H??ng tu???n"
                                  : buttonList[index].buttonText == "Period"
                                      ? "Chu k???"
                                      : "",
                          style: TextStyle(
                              color: buttonList[index].isSelected
                                  ? Colors.white
                                  : Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      padding: EdgeInsets.all(10),
                      shape: CircleBorder(),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          widget.typeRepeat == "Period"
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Th???i gian l???p l???i: ",
                      style: TextStyle(fontSize: 15),
                    ),
                    Container(width: 60, child: buildTextField()),
                    DropdownButton(
                        value: widget.timeUnit,
                        onChanged: (String newValue) {
                          widget.changeTimeUnit(newValue);
                          if (newValue == "Minutes" &&
                              int.parse(periodTimeController.text) < 5) {
                            widget.changePeriodTime(int.parse("5"));
                            setState(() {
                              periodTimeController.text = "5";
                            });
                          }
                        },
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        style: const TextStyle(color: Colors.deepPurple),
                        items: listUnitTime
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value == "Minutes"
                                ? "Ph??t"
                                : value == "Hours"
                                    ? "Gi???"
                                    : value == "Days"
                                        ? "Ng??y"
                                        : ""),
                          );
                        }).toList())
                  ],
                )
              : Container(),
          SizedBox(
            height: 20,
          )
        ],
      );
    } else
      return SizedBox();
  }

  Future resetSelectType() async {
    String changedSelectedType = widget.selectedType;

    if (changedSelectedType == "Repeat")
      buttonList.forEach((element) => {
            if (widget.typeRepeat != null)
              if (element.buttonText == widget.typeRepeat)
                element.isSelected = true
              else
                element.isSelected = false
            else if (element.buttonText == "Period")
              element.isSelected = true
            else
              element.isSelected = false
          });
  }

  TextField buildTextField() {
    return TextField(
      onChanged: (value) {
        if (widget.timeUnit == "Minutes" && int.parse(value) < 5) {
          value = "5";
          setState(() {
            periodTimeController.text = value;
          });
        }
        widget.changePeriodTime(int.parse(value));
      },
      controller: periodTimeController,
      keyboardType: TextInputType.number,
      maxLines: null,
      inputFormatters: [
        LengthLimitingTextInputFormatter(2),
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }
}

class TypeButtonModel {
  bool isSelected;
  final String buttonText;

  TypeButtonModel(this.isSelected, this.buttonText);
}
