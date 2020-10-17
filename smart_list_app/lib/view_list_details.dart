import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_list_app/classes.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentUser = widget.user;
    _currentShoppingList = widget.newShoppingList;
    _currentUser.shoppingLists.add(_currentShoppingList);
  }

  /// Share a list using the default share options
  void shareList(ShoppingList shoppingList) {
    SocialShare.shareOptions("היי! הצטרף לרשימה המשותפת באפליקציית Smart List!\n\nמספר הרשימה שלי הוא ${shoppingList.uniqueID}");
  }

  /// Go back to home screen.
  /// Make sure to reload home screen!
  void goBackToListsPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (BuildContext context) => ListsPage(user: _currentUser, dataArrived: true)
      ), (Route<dynamic> route) => false,
    );
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
                    onPressed: goBackToListsPage,
                    child: Text("אישור",
                      textDirection: TextDirection.rtl,),
                    shape: ContinuousRectangleBorder(side: BorderSide(
                        color: Colors.black54,
                        width: 3,
                        style: BorderStyle.solid
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      iconSize: 40.0,
                        icon: Icon(Icons.ios_share),
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
