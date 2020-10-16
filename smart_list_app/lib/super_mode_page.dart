import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/list_page.dart';
import 'dart:async';

class SuperModePage extends StatefulWidget {
  final User user;
  final ShoppingList shoppingList;

  SuperModePage({Key key, @required this.user, @required this.shoppingList});

  @override
  _SuperModePageState createState() => _SuperModePageState();
}

class _SuperModePageState extends State<SuperModePage> {
  User _currentUser;
  ShoppingList _currentShoppingList;
  List _currentItems;
  String _searchWord = "";
  Timer _timer;
  // bool _canceled = false;

  int _popTimes = 2;

  bool _shouldPop() {
    return _popTimes-- == 0;
  }

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _currentShoppingList = widget.shoppingList;
    _timer = new Timer.periodic(Duration(seconds: 5), (timer) {
      updateList();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  /// Cancel everything! Unbuy all the items and go back to previous page.
  void cancelAndGoBack() {
    List<ShoppingListObject> currentItems = _currentShoppingList.items;
    for (ShoppingListObject item in currentItems) {
      if (item.isBought) {
        item.isBought = false;
        Api.unbuyShoppingListItem(_currentUser, item);
      }
    }
    Navigator.of(context).pop();
  }

  /// Finished on the page - clean everything bought from the list
  /// and go back to the list page.
  void finish() {
    List<ShoppingListObject> temp = new List<ShoppingListObject>();

    // Add all the items that are still not bought to the temp list.
    // Delete all items that were bought.
    for (ShoppingListObject item in _currentShoppingList.items) {
      if (item.isBought) {
        Api.deleteShoppingListItem(_currentUser, item);
      }
      else {
        temp.add(item);
      }
    }

    // Assign the new updated list to the old one
    _currentShoppingList.items = temp;
    // Go back to list page - but updated!
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => ListPage(user: _currentUser, shoppingList: _currentShoppingList, dataArrived: true)),
          (Route<dynamic> route) => _shouldPop(),
    );

  }

  /// Wipe the entire list - delete all the items and go back to list page.
  void deleteEverything() {
    // Delete all the items from the shopping list
    Api.wipeShoppingList(_currentUser, _currentShoppingList);
    _currentShoppingList.items = new List<ShoppingListObject>();
    // Go back to list page - but updated!
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => ListPage(user: _currentUser, shoppingList: _currentShoppingList, dataArrived: true)),
          (Route<dynamic> route) => _shouldPop(),
    );
  }


  /// Update data - every 5 seconds, query the API and get the updated list
  void updateList() async {
     var updatedItems = await Api.getShoppingListItems(_currentShoppingList);
     setState(() {
       _currentShoppingList.items = updatedItems;
     });
  }

  /// Arrange the current Items to show.
  /// Leave only items that match the search. Items that are bought will be on the buttom.
  void arrangeCurrentItems(String search) {
    List temp = _currentItems;
    _currentItems = List();
    // Add all items that match search:
    for (var item in temp) {
      if (item.product.name.contains(search) && !item.isBought) {
        _currentItems.add(item);
      }
    }
    // Add all items that match search and were bought
    for (var item in temp) {
      if (item.product.name.contains(search) && item.isBought) {
        _currentItems.add(item);
      }
    }
  }

  /// Modify the items list according to the search and setState
  /// to show only items fitting to the search word.
  void _doSearch() {
    print("Searching");
    arrangeCurrentItems(_searchWord);
  }

  void buyOrUnbuyItem(ShoppingListObject item) {
    if (item.isBought) {
      Api.unbuyShoppingListItem(_currentUser, item);
      setState(() {
        item.isBought = false;
      });
    }
    else {
      Api.buyShoppingListItem(_currentUser, item);
      setState(() {
        item.isBought = true;
      });
    }
  }

  /// Get the list of all items in the Shopping List
  Widget getItemsList() {
    _currentItems = _currentShoppingList.items;
    arrangeCurrentItems(_searchWord);

    if (_currentItems.isEmpty) {
      return Center(child: Text("אין מוצרים להראות"));
    }
    else {
      return ListView.builder(
        // scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          // Create the list:
          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListTile(
              onLongPress: () {
                print("Long press");
              },
              onTap: () {
                buyOrUnbuyItem(_currentItems[index]);
              },
              leading: CircleAvatar(
                child: Text(
                    _currentItems[index].userAdded.name[0],
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
                backgroundColor: _currentItems[index].isBought ? Colors.black54 : Colors.blue[200],
              ),
              title: Text("${_currentItems[index].product.name}${_currentItems[index].isBought ? " - נקנה" : ""}"),
              subtitle: Text(
                  "נוסף על ידי ${_currentItems[index].userAdded.name}"),
              trailing: Text(
                  "${_currentItems[index].amount} ${_currentItems[index]
                      .getUnitsText()}"),
            ),
          );
        },
        itemCount: _currentItems.length,
      );
    }
  }

  /// Get the entire bode of the page
  Widget getPage() {
    return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'חלב',
                    labelText: 'מה לחפש?',
                  ),
                  textDirection: TextDirection.rtl,
                  onChanged: (input) {
                    setState(() {
                      _searchWord = input;
                      _doSearch();
                    });
                  },
                ),
              ),
            ),
            Expanded(flex:6,child: Container(child: getItemsList())),
            Expanded(flex:1,child: Container(height: MediaQuery.of(context).size.height, color: Colors.blue[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                textDirection: TextDirection.rtl,
                children: [
                  Container(color: Colors.green),
                  FlatButton(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
                    onPressed: cancelAndGoBack,
                    child: Text("ביטול\nוחזרה",
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    shape: ContinuousRectangleBorder(side: BorderSide(
                        color: Colors.black54,
                        width: 3,
                        style: BorderStyle.solid
                    )),
                  ),
                  Container(color: Colors.blue),
                  FlatButton(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
                    onPressed: finish,
                    child: Text("חזור\nונקה מסומן",
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    shape: ContinuousRectangleBorder(side: BorderSide(
                        color: Colors.black54,
                        width: 3,
                        style: BorderStyle.solid
                    )),
                  ),
                  Container(color: Colors.grey),
                  FlatButton(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
                    onPressed: deleteEverything,
                    child: Text("נקה את\nכל הרשימה",
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    shape: ContinuousRectangleBorder(side: BorderSide(
                        color: Colors.black54,
                        width: 3,
                        style: BorderStyle.solid
                    )),
                  ),
                  Container(color: Colors.grey),
                ],
              ),
            ))
          ],
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Center(child: Text("${_currentShoppingList.name} - מצב סופר", textDirection: TextDirection.rtl,)),
        elevation: 0.0,
      ),
      body: getPage(),
    );
  }
}
