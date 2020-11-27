import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/list_page.dart';
import 'package:smart_list_app/lists_page.dart';
import 'package:social_share/social_share.dart';

class ViewListDetailsPage extends StatefulWidget {
  final User user;
  final ShoppingList newShoppingList;

  ViewListDetailsPage({Key key, @required this.user, @required this.newShoppingList});

  @override
  _ViewListDetailsPageState createState() => _ViewListDetailsPageState();
}

class _ViewListDetailsPageState extends State<ViewListDetailsPage> {
  User _currentUser;
  ShoppingList _currentShoppingList;
  String _storeLink = "https://play.google.com/store/apps/details?id=com.smartlistapps.smart_list_app";

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _currentShoppingList = widget.newShoppingList;
    _currentUser.shoppingLists.add(_currentShoppingList);
  }

  /// Share a list using the default share options
  void shareList(ShoppingList shoppingList) {
    SocialShare.shareOptions("היי! הצטרף לרשימה המשותפת באפליקציית Super List!\n\nשם הרשימה שלי הוא: ${shoppingList.name}\nמספר הרשימה שלי הוא: ${shoppingList.uniqueID}\n\nעוד אין לך Super List?\nהורד עכשיו: $_storeLink");
  }

  /// Go back to home screen.
  /// Make sure to reload home screen!
  void _goToListPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (BuildContext context) => ListsPage(user: _currentUser, dataArrived: true)
      ), (Route<dynamic> route) => false,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (BuildContext context) => ListPage(user: _currentUser, shoppingList: _currentShoppingList, dataArrived: false)
      ));
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
              Center(
                  child: Text(
                      "הצלחנו!\n\nמספר רשימה: ${_currentShoppingList.uniqueID}\nשם רשימה: ${_currentShoppingList.name}",
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  )
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FlatButton(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    onPressed: _goToListPage,
                    child: Text("אישור",
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
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: FlatButton(
                        child: Column(
                          children: [
                            Icon(Icons.ios_share, size: 40.0,),
                            SizedBox(height: 5.0,),
                            Text(
                              "שיתוף", style:
                              TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onPressed: () { shareList(_currentShoppingList); }
                    ),
                  )
                ],
              ),
            ],
          )
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
