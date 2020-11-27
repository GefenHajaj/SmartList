import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'dart:math';
import 'package:smart_list_app/add_item_to_list.dart';
import 'package:smart_list_app/change_item_properties.dart';
import 'package:smart_list_app/super_mode_page.dart';
import 'package:smart_list_app/list_settings_page.dart';


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

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    currentShoppingList = widget.shoppingList;
    dataArrived = widget.dataArrived;
    if (!dataArrived)
      items = Api.getShoppingListItems(currentUser, currentShoppingList);
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



  /// Go to buying mode
  void goToSuperMode() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return SuperModePage(user: currentUser, shoppingList: currentShoppingList,);
        }));
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
            // buyOrUnbuyItem(_currentItems[index]);
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
                          labelText: 'מה לחפש?',
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
            Expanded(flex:1,child: Container(height: MediaQuery.of(context).size.height, color: Colors.grey[300],
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    // elevation: 10.0,
                      borderRadius: BorderRadius.circular(50.0),
                      color: Colors.transparent,
                      child: Container(
                        height: 60.0,
                        width: 250.0,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(50.0)
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50.0),
                          onTap: goToSuperMode,
                          child: Center(
                            child: Text("מצב קניות",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0
                              ),
                            ),
                          ),
                        ),
                      )
                  ),
                ),
              ),)),
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
