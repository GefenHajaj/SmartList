import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'dart:math';
import 'package:smart_list_app/add_item_to_list.dart';
import 'package:smart_list_app/change_item_properties.dart';
import 'package:smart_list_app/list_settings_page.dart';
import 'dart:async';

class ListPage extends StatefulWidget {
  final User user;
  final ShoppingList shoppingList;
  final bool dataArrived;

  ListPage({Key key, @required this.user, @required this.shoppingList, @required this.dataArrived});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  User currentUser;
  ShoppingList currentShoppingList;
  Future items;
  List currentItems;
  String searchWord = "";
  Map userColors = {};
  List colors = [Colors.red, Colors.green, Colors.blue, Colors.brown, Colors.pink[300], Colors.purple[400]];
  Random random = new Random();
  bool dataArrived;
  var _tapPosition;

  Timer _timer;
  int _refreshSeconds = 15;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    currentShoppingList = widget.shoppingList;
    dataArrived = widget.dataArrived;
    _timer = new Timer.periodic(Duration(seconds: _refreshSeconds), (timer) {
      updateList();
    });
    if (!dataArrived)
      items = Api.getShoppingListItems(currentUser, currentShoppingList);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Update data - every X seconds, query the API and get the updated list
  void updateList() async {
    if (dataArrived) {
      var updatedItems = await Api.getShoppingListItems(currentUser, currentShoppingList);
      setState(() {
        currentShoppingList.items = updatedItems;
      });
    }
  }

  /// Save the location of press
  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  /// Show the pop up menu
  void showPopUpMenu(ShoppingListObject item, var overlay) async {
    await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            _tapPosition & Size(40, 40), // smaller rect, the touch area
            Offset.zero & overlay.size // Bigger rect, the entire screen
        ),
        items: [
          PopupMenuItem(
            child: Center(
              child: FlatButton(
                child: Text(
                  "ערוך מוצר",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  goToChangeItemProperties(item);
                },
              ),
            ),
          ),
          PopupMenuItem(
            child: Center(
              child: FlatButton(
                child: Text(
                  "מחק מוצר",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: () {
                  deleteItem(item);
                },
              ),
            ),
          ),
        ]
    );
  }

  /// Delete item from the list
  void deleteItem(ShoppingListObject item) async {
    Navigator.of(context).pop();
    Future.delayed(
        Duration(milliseconds: 200), () {
      Api.deleteShoppingListItem(currentUser, currentShoppingList, item);
      setState(() {
        currentShoppingList.items.remove(item);
      });
    }
    );
  }

  /// Go to add item page
  void goToAddItemPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return AddItemToListPage(initialName: searchWord, user: currentUser, shoppingList: currentShoppingList,);
        }));
  }

  /// Go to list settings page
  void goToListSettings() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return ListSettingsPage(user: currentUser, shoppingList: currentShoppingList,);
        }));
  }

  /// Arrange the current Items to show.
  /// Leave only items that match the
  void arrangeCurrentItems(String search) {
    List temp = currentItems;
    currentItems = List();
    // Add all items that match search:
    for (var item in temp) {
      if (item.product.name.contains(search) && !item.isBought) {
        currentItems.add(item);
      }
    }
    // Add all items that match search and were bought
    for (var item in temp) {
      if (item.product.name.contains(search) && item.isBought) {
        currentItems.add(item);
      }
    }
  }

  void goToChangeItemProperties(ShoppingListObject item) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return ChangeItemPropertiesPage(user: currentUser, shoppingList: currentShoppingList, item: item,);
        }));
  }

  /// Modify the items list according to the search and setState
  /// to show only items fitting to the search word.
  void doSearch() {
    print("Searching");
    arrangeCurrentItems(searchWord);
  }

  bool _areThereBoughtItems() {
    for (var item in currentShoppingList.items) {
      if (item.isBought)
        return true;
    }
    return false;
  }

  /// Cancel everything! Unbuy all the items.
  void _cancelEverything() {
    List<ShoppingListObject> currentItems = currentShoppingList.items;
    setState(() {
      for (ShoppingListObject item in currentItems) {
        if (item.isBought) {
          item.isBought = false;
          Api.unbuyShoppingListItem(currentUser, currentShoppingList, item);
        }
      }
    });
  }

  /// Delete all the items that are bought
  void _deleteBought() {
    List<ShoppingListObject> temp = new List<ShoppingListObject>();

    // Add all the items that are still not bought to the temp list.
    // Delete all items that were bought.
    for (ShoppingListObject item in currentShoppingList.items) {
      if (item.isBought) {
        Api.deleteShoppingListItem(currentUser, currentShoppingList, item);
      }
      else {
        temp.add(item);
      }
    }
    setState(() {
      // Assign the new updated list to the old one
      currentShoppingList.items = temp;
    });
  }

  /// Wipe the entire list - delete all the items.
  void deleteEverything() {
    // Delete all the items from the shopping list
    if (currentShoppingList.items != null && currentShoppingList.items.isNotEmpty) {
      Api.wipeShoppingList(currentUser, currentShoppingList);
      setState(() {
        currentShoppingList.items = new List<ShoppingListObject>();
      });
    }
    Navigator.of(context).pop();
  }

  void _deleteEverythingAlert() {
    if (currentShoppingList.items != null && currentShoppingList.items.isNotEmpty) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) =>
              AlertDialog(
                title: Text("למחוק את כל המוצרים ברשימה?",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                content: Text(
                  "בטוחים שאתם רוצים למחוק את כל המוצרים ברשימה?",
                  textDirection: TextDirection.rtl,
                ),
                actions: [
                  FlatButton(
                      onPressed: Navigator
                          .of(context)
                          .pop,
                      child: Text(
                        "לא",
                        style: TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold
                        ),
                      )
                  ),
                  FlatButton(
                      onPressed: deleteEverything,
                      child: Text(
                        "כן",
                        style: TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold
                        ),
                      )
                  ),
                ],
              )
      );
    }
  }

  /// Get the buttons that will appear at the bottom of the screen.
  /// If there are no bought items, the button will just say "wipe list".
  /// If there are bought items, there will also be a button that says "wipe
  /// bought items"
  Widget _getBottomButtons() {
    bool areThereBoughtItems = _areThereBoughtItems();
    List<StatelessWidget> _buttons = <StatelessWidget>[
      Container(color: Colors.grey),
      Container(
        padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 0.0),
        child: FlatButton(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: areThereBoughtItems ? 0.0 : 75.0),
          onPressed: _deleteEverythingAlert,
          child: Text(areThereBoughtItems ? "נקה את\nכל הרשימה" : "נקה את כל הרשימה",
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
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
      ),
      Container(color: Colors.grey),
    ];

    if (_areThereBoughtItems()) {
      _buttons = <StatelessWidget>[
        Container(color: Colors.green),
        Container(
          padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 0.0),
          child: FlatButton(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 10.0),
            onPressed: _cancelEverything,
            child: Text("בטל סימוני נקנה",
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
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
        ),
        Container(color: Colors.blue),
        Container(
          padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 0.0),
          child: FlatButton(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 10.0),
            onPressed: _deleteBought,
            child: Text("מחק מוצרים שנקנו",
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
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
        ),
      ] + _buttons;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      textDirection: TextDirection.rtl,
      children: _buttons
    );
  }

  void _buyOrUnbuyItem(ShoppingListObject item) {
    if (item.isBought) {
      Api.unbuyShoppingListItem(currentUser, currentShoppingList, item);
      setState(() {
        item.isBought = false;
      });
    }
    else {
      Api.buyShoppingListItem(currentUser, currentShoppingList, item);
      setState(() {
        item.isBought = true;
      });
    }
  }

  Widget _getAddFirstItemButton() {
    return Center(
        child: Wrap(
            children: [
              MaterialButton(
                onPressed: goToAddItemPage,
                color: Colors.green[100],
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(
                          Icons.add,
                        size: 50,
                      ),
                      Text(
                          "הוסף מוצר\nלרשימה",
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]
        )
    );
  }

  Widget _getItemWidget(ShoppingListObject item, RenderBox overlay, Color currentColor, User currentUserList) {
    dynamic amount = item.amount;
    amount = amount.roundToDouble() == amount ? amount.round() : amount;
    return GestureDetector(
      onTapDown: _storePosition,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListTile(
          onLongPress: () {
            if (!item.isBought)
              showPopUpMenu(item, overlay);
          },
          onTap: () {
            _buyOrUnbuyItem(item);
          },
          leading: CircleAvatar(
            child: Text(currentUserList.name[0]),
            backgroundColor: item.isBought ? Colors.black54 : currentColor,
          ),
          title: Text(
            "${item.product.name}${item.isBought ? " - נקנה" : ""}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text("נוסף על ידי ${currentUserList.name}"),
          trailing: Text(
            "$amount ${item.getUnitsText()}",
            style: TextStyle(
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  Widget getItemsList() {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    if (!dataArrived) {
      return FutureBuilder(
          future: items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Arrange data
              if (!dataArrived) {
                dataArrived = true;
                List shoppingListItems = snapshot.data;
                currentShoppingList.items = shoppingListItems;
              }
              currentItems = currentShoppingList.items;
              arrangeCurrentItems(searchWord);

              if (currentShoppingList.items.isEmpty) {
                return _getAddFirstItemButton();
              }
              else {
                return ListView.builder(
                  // scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    // Determine color for item
                    Color currentColor;
                    User currentUserList;

                    if (index < currentItems.length) {
                      currentUserList = currentItems[index].userAdded;
                      if (userColors.keys.contains(currentUserList.pk)) {
                        currentColor = userColors[currentUserList.pk];
                      }
                      else {
                        currentColor = colors[random.nextInt(colors.length)];
                        while (userColors.values.contains(currentColor) &&
                            userColors.length < colors.length) {
                          currentColor = colors[random.nextInt(colors.length)];
                        }
                        userColors[currentUserList.pk] = currentColor;
                      }
                    }
                    // Create the list:
                    return _getItemWidget(currentItems[index], overlay, currentColor, currentUserList);
                  },
                  itemCount: currentItems.length,
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

    // If we already have the data:
    else {
      currentItems = currentShoppingList.items;
      arrangeCurrentItems(searchWord);

      if (currentShoppingList.items.isEmpty) {
        print("Number of shopping list items: ${currentItems.length}");
        return _getAddFirstItemButton();
      }
      else {
        return ListView.builder(
          // scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            // Determine color for item
            Color currentColor;
            User currentUserList;
            if (index < currentItems.length) {
              currentUserList = currentItems[index].userAdded;
              if (userColors.keys.contains(currentUserList.pk)) {
                currentColor = userColors[currentUserList.pk];
              }
              else {
                currentColor = colors[random.nextInt(colors.length)];
                while (userColors.values.contains(currentColor) &&
                    userColors.length < colors.length) {
                  currentColor = colors[random.nextInt(colors.length)];
                }
                userColors[currentUserList.pk] = currentColor;
              }
            }
            dynamic amount = currentItems[index].amount;
            amount = amount.roundToDouble() == amount ? amount.round() : amount;
            // Create the list:
            return _getItemWidget(currentItems[index], overlay, currentColor, currentUserList);
          },
          itemCount: currentItems.length,
        );
      }
    }
  }

  /// Get the entire page
  Widget getPage() {
    return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 2,
                      child: IconButton(
                        icon: Center(
                          child: Icon(
                              Icons.add,
                            size: 36.0,
                            color: Colors.green,
                          ),
                        ),
                        onPressed: goToAddItemPage,
                      )
                  ),
                  // Expanded(child: Container(), flex: 1,),
                  Expanded(
                    flex: 12,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 18.0
                        ),
                        decoration: const InputDecoration(
                          labelText: 'מה לחפש או להוסיף?',
                        ),
                        textDirection: TextDirection.rtl,
                        onChanged: (input) {
                          setState(() {
                            searchWord = input;
                            doSearch();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex:6,child: Container(child: getItemsList())),
            Expanded(flex:1,child: Container(height: MediaQuery.of(context).size.height, color: Colors.blue[100],
              child: _getBottomButtons(),
            )),
            SizedBox(height: 60,)
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        actions: [
          // IconButton(icon: Icon(Icons.add), onPressed: goToAddItemPage),
          IconButton(icon: Icon(Icons.settings), onPressed: () { goToListSettings(); }),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () { Navigator.of(context).pop(); },
        ),
        centerTitle: true,
        title: Center(child: Text(currentShoppingList.name, textDirection: TextDirection.rtl,)),
        elevation: 0.0,
      ),
      body: getPage(),
    );
  }
}
