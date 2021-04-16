import 'package:flutter/material.dart';

class SelectType extends StatefulWidget {
  const SelectType(
      {Key key, this.selectedType, this.selectedRepeat, this.typeRepeat})
      : super(key: key);

  final String selectedType, typeRepeat;

  final Function(String) selectedRepeat;

  @override
  _SelectTypeState createState() => _SelectTypeState();
}

class _SelectTypeState extends State<SelectType> {
  List<TypeButtonModel> buttonList = new List<TypeButtonModel>();

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
    buttonList.add(new TypeButtonModel(false, 'Weekly'));
  }

  @override
  Widget build(BuildContext context) {
    resetSelectType();
    if (widget.selectedType == "Repeat") {
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
                        _refreshPage();
                      },
                      elevation: 2.0,
                      fillColor: buttonList[index].isSelected
                          ? Colors.blueAccent
                          : Colors.white,
                      child: Container(
                        width: 70,
                        child: Text(
                          buttonList[index].buttonText,
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
            else if (element.buttonText == "Daily")
              element.isSelected = true
            else
              element.isSelected = false
          });
  }
}

class TypeButtonModel {
  bool isSelected;
  final String buttonText;

  TypeButtonModel(this.isSelected, this.buttonText);
}
