import 'package:flutter/material.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/view_list_details.dart';

class CreateListPage extends StatefulWidget {
  final User user;

  CreateListPage({Key key, @required this.user});

  @override
  _CreateListPageState createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  User _currentUser;
  String _newShoppingListName = "";

  Color _buttonColor = Colors.grey[350];
  Color _disabledButtonColor = Colors.grey[350];
  Color _enabledButtonColor = Colors.white;

  String _buttonText = "הכנס שם";
  String _disabledButtonText = "הכנס שם";
  String _enabledButtonText = "המשך";

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  /// Create the new list and go to get list info.
  /// If the list name is empty - do nothing.
  void createNewList() async {
    if (_newShoppingListName != "") {
      setState(() {
        _buttonText = "טוען...";
      });
      var newShoppingList = await Api.createShoppingList(_currentUser, _newShoppingListName);
      setState(() {
        _enabledButtonColor = Colors.green;
        _buttonText = "יש!";
      });
      Navigator.of(context).push(MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return ViewListDetailsPage(user: _currentUser, newShoppingList: newShoppingList);
          }));
    }
  }


  /// Get the page of the screen
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
                crossAxisAlignment: CrossAxisAlignment.end,
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        "שם רשימה",
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
                          contentPadding: EdgeInsets.only(bottom: 13.0)
                        ),
                        keyboardType: TextInputType.name,
                        textDirection: TextDirection.rtl,
                        maxLength: 50,
                        onChanged: (input) {
                          setState(() {
                            _newShoppingListName = input;
                            if (_newShoppingListName != "") {
                              _buttonColor = _enabledButtonColor;
                              _buttonText = _enabledButtonText;
                              _isButtonEnabled = true;
                            }
                            else {
                              _buttonColor = _disabledButtonColor;
                              _buttonText = _disabledButtonText;
                              _isButtonEnabled = false;
                            }
                          });
                        },
                      ),
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
                      disabledColor: _buttonColor,
                      color: _enabledButtonColor,
                      disabledTextColor: Colors.black54,
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
                      onPressed: _isButtonEnabled ? createNewList : null,
                      child: Text(_buttonText,
                        textDirection: TextDirection.rtl,),
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
                        textDirection: TextDirection.rtl,),
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
        body: getBody()
    );
  }
}
