import 'package:flutter/material.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/view_list_details.dart';
import 'package:smart_list_app/lists_page.dart';

class JoinListPage extends StatefulWidget {
  final User user;

  JoinListPage({Key key, @required this.user});

  @override
  _JoinListPageState createState() => _JoinListPageState();
}

class _JoinListPageState extends State<JoinListPage> {
  User _currentUser;
  String _uniqueIDString = "";

  String _buttonText = "הכנס מספר רשימה";
  String _enabledButtonText = "המשך";
  String _disabledButtonText = "הכנס מספר רשימה";

  Color _enabledButtonColor = Colors.white;
  Color _disabledButtonColor = Colors.grey[350];

  TextEditingController _listNumController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  /// Is unique id valid
  bool isUniqueIDValid() {
    return _uniqueIDString.length == 8 && int.parse(_uniqueIDString, onError: (e) => null) != null;
  }
  
  /// Go to main screen with delay
  void goToListsPage() {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => ListsPage(user: _currentUser, dataArrived: true)
        ), (Route<dynamic> route) => false,
      );
    });
  }

  /// Join a list and go to view list page
  void joinList() async {
    if (isUniqueIDValid()) {
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        _enabledButtonText = "טוען...";
      });
      var newShoppingList = await Api.joinList(_currentUser, _uniqueIDString);
      if (newShoppingList is ShoppingList) {
        setState(() {
          _buttonText = "יש!";
          _enabledButtonColor = Colors.green;
        });
        Navigator.of(context).push(MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return ViewListDetailsPage(
                  user: _currentUser, newShoppingList: newShoppingList);
            }));
      }
      else {
        setState(() {
          _buttonText = "מספר רשימה לא תקין";
          _enabledButtonColor = Colors.red;
        });
        Future.delayed(const Duration(seconds: 1), () {
          _listNumController.text = "";
          setState(() {
            _buttonText = _disabledButtonText;
            _enabledButtonColor = _disabledButtonColor;
          });
        });
      }
    }
  }

  /// Get the body of the page
  Widget getBody() {
    return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
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
                // crossAxisAlignment: CrossAxisAlignment.end,
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            "מספר רשימה",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Text(
                          "מספר בן 8 ספרות",
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 12.0
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: TextField(
                        style: TextStyle(
                            fontSize: 20.0
                        ),
                        controller: _listNumController,
                        // textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          counterText: "",
                        ),
                        keyboardType: TextInputType.name,
                        // textDirection: TextDirection.rtl,
                        maxLength: 50,
                        onChanged: (input) {
                          setState(() {
                            _uniqueIDString = input;
                            if (isUniqueIDValid())
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
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
                      onPressed: isUniqueIDValid() ? joinList : null,
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
      body: getBody(),
    );
  }
}
