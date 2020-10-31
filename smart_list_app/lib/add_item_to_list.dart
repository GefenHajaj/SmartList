import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/list_page.dart';

class AddItemToListPage extends StatefulWidget {
  final User user;
  final ShoppingList shoppingList;

  AddItemToListPage({Key key, @required this.user, @required this.shoppingList});

  @override
  _AddItemToListPageState createState() => _AddItemToListPageState();
}

class _AddItemToListPageState extends State<AddItemToListPage> {
  User _currentUser;
  ShoppingList _currentShoppingList;

  String _productName = "";

  int _units = 0; // 0 - units, 1 - kg
  Map<int, Widget> _unitsMap = {
    1 : Text("קילוגרם"),
    0 : Text("יחידות"),
  };
  double _amountNumber = 1;
  double _amountFriction = 0;

  String _buttonText = "הכנס שם מוצר";
  String _enabledButtonText = "המשך";
  String _disabledButtonText = "הכנס שם מוצר";

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
    _scrollController = FixedExtentScrollController();
    _scrollControllerNumber = FixedExtentScrollController(initialItem: 1);
  }

  /// Add the item to the list and go back to list page
  void addItemToList() async {
    String unitsText = _units == 0 ? "units" : "kg";
    ShoppingListObject newItem = await Api.addItemToList(_currentUser, _currentShoppingList, _productName, unitsText, _amountNumber + _amountFriction);
    _currentShoppingList.items.add(newItem);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => ListPage(user: _currentUser, shoppingList: _currentShoppingList, dataArrived: true)),
          (Route<dynamic> route) => shouldPop(),
    );
  }

  void amountPickHandleNumbers(int index) {
    _amountNumber = index.toDouble();
    print(_amountNumber);
  }

  void amountPickHandleFrictions(int index) {
    _amountFriction = index / 10.0;
    if (_units == 0) {
      goToZero();
      _amountFriction = 0;
    }
    print(_amountFriction);
  }

  void goToZero() {
    _scrollController.animateToItem(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
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
                      child: TextField(
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          counterText: "",
                        ),
                        keyboardType: TextInputType.name,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 20.0
                        ),
                        maxLength: 50,
                        onChanged: (input) {
                          setState(() {
                            _productName = input;
                            if (_productName != "")
                              _buttonText = _enabledButtonText;
                            else
                              _buttonText = _disabledButtonText;
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
                    child: Text("בחר סוג יחידות:", textDirection: TextDirection.rtl,),
                  ),
                  CupertinoSegmentedControl<int>(
                      children: _unitsMap,
                      onValueChanged: (int unitsValue) {
                        setState(() {
                          _units = unitsValue;
                          if (_units == 0) {
                            goToZero();
                          }
                        });
                      },
                    groupValue: _units,
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
                      onPressed: _productName != "" ? addItemToList : null,
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
