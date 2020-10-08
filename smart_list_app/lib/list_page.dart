import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/lists_page.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';


class ListPage extends StatefulWidget {
  final User user;
  final ShoppingList shoppingList;

  ListPage({@required this.user, @required this.shoppingList});

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
  bool dataArrived = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = widget.user;
    currentShoppingList = widget.shoppingList;
    items = Api.getShoppingListItems(currentShoppingList);
  }

  // Go to buying mode
  void goToSuperMode() {
    print("Go to super mode");
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

  /// Modify the items list according to the search and setState
  /// to show only items fitting to the search word.
  void doSearch() {
    print("Searching");
    arrangeCurrentItems(searchWord);
  }

  Widget getItemsList() {
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
                  if (index < currentItems.length){
                    currentUserList = currentItems[index].userAdded;
                    if (userColors.keys.contains(currentUserList.pk))
                    {
                      currentColor = userColors[currentUserList.pk];
                    }
                    else {
                      currentColor = colors[random.nextInt(colors.length)];
                      while (userColors.values.contains(currentColor) && userColors.length < colors.length) {
                        currentColor = colors[random.nextInt(colors.length)];
                      }
                      userColors[currentUserList.pk] = currentColor;
                    }
                  }

                  // Create the list:
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: ListTile(
                      onLongPress: () {print("Long press"); },
                      onTap: () { print("Go to item."); },
                      leading: CircleAvatar(child: Text(currentUserList.name[0]), backgroundColor: currentColor,),
                      title: Text(currentItems[index].product.name),
                      subtitle: Text("נוסף על ידי ${currentUserList.name}"),
                      trailing: Text("${currentItems[index].amount} ${currentItems[index].getUnitsText()}"),
                    ),
                  );
                },
                itemCount: currentItems.length,
              );
            }
          }
          else {
            return Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
          }
        }
    );
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
        centerTitle: true,
        title: Center(child: Text(currentShoppingList.name)),
        elevation: 0.0,
      ),
      body: getPage(),
    );
  }
}
