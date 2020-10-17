import 'package:flutter/material.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/join_list.dart';
import 'package:smart_list_app/list_page.dart';
import 'package:smart_list_app/create_list.dart';
import 'package:social_share/social_share.dart';


class ListsPage extends StatefulWidget {
  final User user;
  final bool dataArrived;

  ListsPage({Key key, @required this.user, @required this.dataArrived});

  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  bool dataArrived = false;
  bool addingList = false;
  User currentUser;
  Future data;
  var tapPosition =  Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    if (!widget.dataArrived)
      data = Api.getUserLists(currentUser);
  }

  /// Share a list using the default share options
  void shareList(ShoppingList shoppingList) {
    SocialShare.shareOptions("היי! הצטרף לרשימה המשותפת באפליקציית Smart List!\n\nמספר הרשימה שלי הוא ${shoppingList.uniqueID}");
  }

  /// Save the location of press
  void _storePosition(TapDownDetails details) {
    tapPosition = details.globalPosition;
  }

  /// Go to view a shopping list page - all its items
  void goToList(ShoppingList shoppingList) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return ListPage(user: currentUser, shoppingList: shoppingList, dataArrived: false,);
        }));
  }

  /// Go to create a new shopping list
  void goToCreateNewShoppingListPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return CreateListPage(user: currentUser);
        }));
  }

  /// Go to join a list
  void goToJoinList() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return JoinListPage(user: currentUser);
        }));
  }

  /// Delete a list and remove it from the screen
  void deleteList(ShoppingList shoppingList) async {
    Navigator.of(context).pop();
    Future.delayed(
      Duration(milliseconds: 200), () {
        Api.deleteShoppingList(currentUser, shoppingList);
        setState(() {
          currentUser.shoppingLists.remove(shoppingList);
        });
        }
    );
  }

  /// Show the pop up menu
  void showPopUpMenu(ShoppingList shoppingList, var overlay) async {
    await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            tapPosition & Size(40, 40), // smaller rect, the touch area
            Offset.zero & overlay.size // Bigger rect, the entire screen
        ),
        items: [
          PopupMenuItem(
            child: Center(
              child: FlatButton(
                child: Text(
                  "מחק רשימה",
                  textDirection: TextDirection.rtl,
                ),
                onPressed: () {
                    deleteList(shoppingList);
                  },
              ),
            ),
          ),
          PopupMenuItem(
            child: Center(
              child: FlatButton(
                child: Text(
                  "שתף רשימה",
                  textDirection: TextDirection.rtl,
                ),
                onPressed: () {
                    shareList(shoppingList);
                    Navigator.of(context).pop();
                  },
              ),
            ),
          ),
        ]
    );
  }

  /// Get a one list object - the button
  Widget getListWidget(ShoppingList shoppingList) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    return GestureDetector(
      onTapDown: _storePosition,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlatButton(
          color: Colors.white,
          height: MediaQuery
              .of(context)
              .size
              .height / 12,
          onPressed: () {
            goToList(shoppingList);
          },
          child: Text(shoppingList.name),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black54,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          onLongPress: () {
            showPopUpMenu(shoppingList, overlay);
          },
        ),
      ),
    );
  }

  /// Get the list of shopping lists.
  /// In case we're still waiting for response, show spinning logo.
  Widget getListsList() {
    if (!widget.dataArrived) {
      return FutureBuilder(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (currentUser.shoppingLists.isEmpty) {
                print("Number of shopping lists: ${currentUser.shoppingLists
                    .length}");
                return Text("אין רשימות");
              }
              else {
                return ListView.builder(
                  // scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return getListWidget(currentUser.shoppingLists[index]);
                  },
                  itemCount: currentUser.shoppingLists.length,
                );
              }
            }
            else {
              return Center(child: Container(
                  height: 40.0,
                  width: 40.0,
                  child: CircularProgressIndicator())
              );
            }
          }
      );
    }
    else {
      if (currentUser.shoppingLists.isEmpty) {
        print("Number of shopping lists: ${currentUser.shoppingLists
            .length}");
        return Text("אין רשימות");
      }
      else {
        return ListView.builder(
          // scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return getListWidget(currentUser.shoppingLists[index]);
          },
          itemCount: currentUser.shoppingLists.length,
        );
      }
    }
  }

  /// Get the body of the page.
  Widget getBody() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            textDirection: TextDirection.rtl,
            children: [
              Image.asset(
                'assets/smart_list_logo.png',
                height: MediaQuery.of(context).size.height / 5,
              ),
              SizedBox(height: 20),
              Text(
                  "הרשימות שלי",
                style: TextStyle(
                  fontSize: 34.0,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 40),
              getListsList(),
              SizedBox(height: 40,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                textDirection: TextDirection.rtl,
                children: [
                  Container(color: Colors.green),
                  FlatButton.icon(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
                    icon: Icon(Icons.add_shopping_cart),
                    onPressed: goToCreateNewShoppingListPage,
                    label: Text("יצירת\nרשימה",
                      textDirection: TextDirection.rtl,),
                    shape: ContinuousRectangleBorder(side: BorderSide(
                        color: Colors.black54,
                        width: 3,
                        style: BorderStyle.solid
                    )),
                  ),
                  Container(color: Colors.grey),
                  FlatButton.icon(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
                    icon: Icon(Icons.person_add),
                    onPressed: goToJoinList,
                    label: Text("הצטרף\nלרשימה",
                    textDirection: TextDirection.rtl,),
                    shape: ContinuousRectangleBorder(side: BorderSide(
                        color: Colors.black54,
                        width: 3,
                        style: BorderStyle.solid
                    )),
                  ),
                  Container(color: Colors.grey),
                ],
              ),
              SizedBox(height: 40.0,)
            ],
          ),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: getBody(),
        ),
      ),
    );
  }
}
