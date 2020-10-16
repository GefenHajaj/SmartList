import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/list_page.dart';
import 'dart:async';

class ListSettingsPage extends StatefulWidget {
  final User user;
  final ShoppingList shoppingList;

  ListSettingsPage({Key key, @required this.user, @required this.shoppingList});

  @override
  _ListSettingsPageState createState() => _ListSettingsPageState();
}

class _ListSettingsPageState extends State<ListSettingsPage> {
  User _currentUser;
  ShoppingList _currentShoppingList;
  Future _listMembers;
  List _listMembersData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentUser = widget.user;
    _currentShoppingList = widget.shoppingList;
    _listMembers = Api.getShoppingListMembers(_currentUser, _currentShoppingList);
  }

  /// Go back
  void goBack() {
    Navigator.of(context).pop();
  }

  /// Remove user from list
  void removeUserFromTheList(User userToRemove) async {
    await Api.removeUserFromList(_currentUser, userToRemove, _currentShoppingList);
    setState(() {
      _listMembersData.remove(userToRemove);
    });
  }

  /// Get the list of the users
  Widget getUsersList() {
    return FutureBuilder(
        future: _listMembers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _listMembersData = snapshot.data;

            if (_listMembersData.isEmpty){
              return Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 40),
                child: Center(
                  child: Text(
                    "אין עוד חברים ברשימה חוץ ממך.",
                        textDirection: TextDirection.rtl,
                ),
                ),
              );
            }
            else {
              return ListView.builder(
                scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person),
                          backgroundColor: Colors.blue[100],),
                        title: Text(_listMembersData[index].name),
                        trailing: IconButton(
                            onPressed: () {
                              removeUserFromTheList(_listMembersData[index]);
                            },
                            icon: Icon(Icons.person_remove),
                        )
                      ),
                    );
                  },
                itemCount: _listMembersData.length,
              );
            }
          }
          else {
            return Center(child: SizedBox(
                width: 30, height: 30, child: CircularProgressIndicator()));
          }
        }
    );
  }

  Widget getPage() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0.0),
              child: Image.asset(
                'assets/smart_list_logo.png',
                height: MediaQuery.of(context).size.height / 5,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
              child: Text(
                "שם הרשימה: ${_currentShoppingList.name}",
                style: TextStyle(
                  fontSize: 22.0,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
              child: Text(
                "מספר הרשימה: ${_currentShoppingList.uniqueID}",
                style: TextStyle(
                  fontSize: 22.0,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
              child: Text(
                "החברים ברשימה:",
                style: TextStyle(
                  fontSize: 22.0,
                  decoration: TextDecoration.underline
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            getUsersList(),
            SizedBox(height: 40,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              child: FlatButton(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                onPressed: () {
                  goBack();
                },
                child: Text("אישור",
                  textDirection: TextDirection.rtl,),
                shape: ContinuousRectangleBorder(side: BorderSide(
                    color: Colors.black54,
                    width: 3,
                    style: BorderStyle.solid
                )),
              ),
            ),
            SizedBox(height: 40.0,)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: getPage(),
        ),
      ),
    );
  }
}
