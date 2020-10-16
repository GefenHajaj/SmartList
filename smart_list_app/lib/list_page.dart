import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'dart:math';
import 'package:smart_list_app/add_item_to_list.dart';
import 'package:smart_list_app/change_item_properties.dart';
import 'package:smart_list_app/super_mode_page.dart';


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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = widget.user;
    currentShoppingList = widget.shoppingList;
    dataArrived = widget.dataArrived;
    if (!dataArrived)
      items = Api.getShoppingListItems(currentShoppingList);
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
          return AddItemToListPage(user: currentUser, shoppingList: currentShoppingList,);
        }));
  }

  /// Arrange the current Items to show.
  /// Leave only items that match the
  void arrangeCurrentItems(String search) {
    List temp = currentItems;
    currentItems = List();
    for (var item in temp) {
      if (item.product.name.contains(search) && !item.isBought) {
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

  Widget getItemsList() {
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

              if (currentItems.isEmpty) {
                print("Number of shopping list items: ${currentItems.length}");
                return Center(child: Text("אין מוצרים להראות"));
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
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListTile(
                        onLongPress: () {
                          print("Long press");
                        },
                        onTap: () {
                          goToChangeItemProperties(currentItems[index]);
                        },
                        leading: CircleAvatar(child: Text(currentUserList
                            .name[0]), backgroundColor: currentColor,),
                        title: Text(currentItems[index].product.name),
                        subtitle: Text("נוסף על ידי ${currentUserList.name}"),
                        trailing: Text(
                            "${currentItems[index].amount} ${currentItems[index]
                                .getUnitsText()}"),
                      ),
                    );
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

      if (currentItems.isEmpty) {
        print("Number of shopping list items: ${currentItems.length}");
        return Center(child: Text("אין מוצרים להראות"));
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
            return Directionality(
              textDirection: TextDirection.rtl,
              child: ListTile(
                onLongPress: () {
                  print("Long press");
                },
                onTap: () {
                  goToChangeItemProperties(currentItems[index]);
                },
                leading: CircleAvatar(child: Text(currentUserList
                    .name[0]), backgroundColor: currentColor,),
                title: Text(currentItems[index].product.name),
                subtitle: Text("נוסף על ידי ${currentUserList.name}"),
                trailing: Text(
                    "${currentItems[index].amount} ${currentItems[index]
                        .getUnitsText()}"),
              ),
            );
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
                      searchWord = input;
                      doSearch();
                    });
                  },
                ),
              ),
            ),
            Expanded(flex:6,child: Container(child: getItemsList())),
            Expanded(flex:1,child: Container(height: MediaQuery.of(context).size.height, color: Colors.grey[300],
            child: Center(
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
                        child: Text("מצב סופר",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0
                          ),
                        ),
                      ),
                    ),
                  )
              ),
            ),))
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
          IconButton(icon: Icon(Icons.add), onPressed: goToAddItemPage),
          IconButton(icon: Icon(Icons.settings), onPressed: () {print("List settings"); }),
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
