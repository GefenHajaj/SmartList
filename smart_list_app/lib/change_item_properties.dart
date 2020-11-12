import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/list_page.dart';

class ChangeItemPropertiesPage extends StatefulWidget {
  final User user;
  final ShoppingList shoppingList;
  final ShoppingListObject item;

  ChangeItemPropertiesPage({Key key, @required this.user, @required this.shoppingList, @required this.item});

  @override
  _ChangeItemPropertiesPageState createState() => _ChangeItemPropertiesPageState();
}

class _ChangeItemPropertiesPageState extends State<ChangeItemPropertiesPage> {
  User _currentUser;
  ShoppingList _currentShoppingList;
  ShoppingListObject _currentItem;

  String _newName = "";
  double _newAmountNumber;
  double _newAmountFriction;
  int _newUnits;

  Map<int, Widget> _unitsMap = {
    1 : Text("קילוגרם"),
    0 : Text("יחידות"),
  };


  String _buttonText = "שנה משהו";
  String _enabledButtonText = "המשך";
  String _disabledButtonText = "שנה משהו";

  Color _enabledButtonColor = Colors.white;
  Color _disabledButtonColor = Colors.grey[350];

  FixedExtentScrollController _scrollController;
  FixedExtentScrollController _scrollControllerNumber;

  int _popTimes = 2;

  bool shouldPop() {
    return _popTimes-- == 0;
  }

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _currentShoppingList = widget.shoppingList;
    _currentItem = widget.item;
    _newName = _currentItem.product.name;
    _newUnits = _currentItem.units == "units" ? 0 : 1;
     _newAmountNumber = _currentItem.amount.toInt().toDouble().roundToDouble();
     _newAmountFriction =  double.parse((_currentItem.amount - _currentItem.amount.toInt()).toStringAsFixed(1));
    _scrollController = FixedExtentScrollController(initialItem: (_newAmountFriction * 10).toInt());
    _scrollControllerNumber = FixedExtentScrollController(initialItem: _newAmountNumber.toInt());
  }

  /// Check if anything changed
  bool hasAnythingChanged() {
    double amount = _newAmountNumber + _newAmountFriction;
    String units = _newUnits == 0 ? "units" : "kg";
    return _currentItem.product.name != _newName || _currentItem.units != units || _currentItem.amount != amount;
  }

  void goToZero() {
    _scrollController.animateToItem(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  /// Change the item properties and go back to the list screen
  void changeItemProperties() async {
    if (hasAnythingChanged()) {
      _currentItem.product.name = _newName;
      _currentItem.amount = _newAmountNumber + _newAmountFriction;
      _currentItem.units = _newUnits == 0 ? "units" : "kg";
      await Api.changeListItem(_currentUser, _currentShoppingList, _currentItem);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => ListPage(user: _currentUser, shoppingList: _currentShoppingList, dataArrived: true)),
            (Route<dynamic> route) => shouldPop(),
      );
    }
  }


  void changeButtonText() {
    if (_newName != "" && hasAnythingChanged()) {
        _buttonText = _enabledButtonText;
    }
    else {
        _buttonText = _disabledButtonText;
    }
  }

  void amountPickHandleNumbers(int index) {
    setState(() {
      _newAmountNumber = index.toDouble();
      changeButtonText();
    });
    print(_newAmountNumber);
  }

  void amountPickHandleFrictions(int index) {
    setState(() {
      if (_newUnits == 0) {
        goToZero();
        _newAmountFriction = 0.0;
      }
      else {
        _newAmountFriction = index / 10.0;
      }
      changeButtonText();
    });
    print(_newAmountFriction);
  }


  /// Get the body of the page
  Widget getBody() {
    return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            textDirection: TextDirection.rtl,
            children: [
              Container(
                child: Image.asset(
                  'assets/smart_list_logo.png',
                  height: MediaQuery.of(context).size.height / 4.5,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.end,
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        "שם מוצר",
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 20.0
                        ),
                        // textAlignVertical: TextAlignVertical.bottom,
                        initialValue: _newName,
                        decoration: InputDecoration(
                          counterText: "",
                        ),
                        keyboardType: TextInputType.name,
                        textDirection: TextDirection.rtl,
                        maxLength: 50,
                        onChanged: (input) {
                          setState(() {
                            _newName = input;
                            changeButtonText();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                textDirection: TextDirection.rtl,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                    child: Text("סוג יחידות:", textDirection: TextDirection.rtl,),
                  ),
                  CupertinoSegmentedControl<int>(
                    children: _unitsMap,
                    onValueChanged: (int unitsValue) {
                      setState(() {
                        _newUnits = unitsValue;
                        if (_newUnits == 0) {
                          goToZero();
                        }
                        changeButtonText();
                      });
                    },
                    groupValue: _newUnits,
                    borderColor: Colors.black54,
                    selectedColor: Colors.green[400],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                textDirection: TextDirection.rtl,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15.0),
                    child: Text("בחר כמות:", textDirection: TextDirection.rtl,),
                  ),
                  Container(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: CupertinoPicker(
                                  scrollController: _scrollControllerNumber,
                                  itemExtent: 30,
                                  onSelectedItemChanged: amountPickHandleNumbers,
                                  children: List<Widget>.generate(100, (int index) {
                                    return Align(child: Text(index.toString(),), alignment: Alignment.centerRight,);
                                  })
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: CupertinoPicker(
                                scrollController: _scrollController,
                                itemExtent: 30,
                                onSelectedItemChanged: amountPickHandleFrictions,
                                children: List<Widget>.generate(10, (int index) {
                                  return Align(child: Text(".$index",), alignment: Alignment.centerLeft,);
                                })
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(),
                    FlatButton(
                      disabledColor: _disabledButtonColor,
                      color: _enabledButtonColor,
                      disabledTextColor: Colors.black54,
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
                      onPressed: hasAnythingChanged() && _newName != "" ? changeItemProperties : null,
                      child: Text(_buttonText,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      shape: ContinuousRectangleBorder(side: BorderSide(
                          color: Colors.black54,
                          width: 3,
                          style: BorderStyle.solid
                      )),
                    ),
                    Container(),
                    FlatButton(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
                      onPressed: () { Navigator.of(context).pop(); },
                      child: Text("ביטול",
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      shape: ContinuousRectangleBorder(side: BorderSide(
                          color: Colors.black54,
                          width: 3,
                          style: BorderStyle.solid
                      )),
                    ),
                    Container(),
                  ],
                ),
              ),
              SizedBox(height: 40.0,)
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: getBody(),
    );
  }
}
