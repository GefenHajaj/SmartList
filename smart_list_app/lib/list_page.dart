import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/lists_page.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


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
  String searchWord;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = widget.user;
    currentShoppingList = widget.shoppingList;
    items = Api.getShoppingListItems(currentShoppingList);
  }

  /// Modify the items list according to the search and setState
  /// to show only items fitting to the search word.
  void doSearch() {
    print("Searching");
    // TODO: implement this function.
  }

  Widget getItemsList() {
    return FutureBuilder(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List shoppingListItems = snapshot.data;
            currentShoppingList.items = shoppingListItems;

            if (shoppingListItems.isEmpty) {
              print("Number of shopping list items: ${shoppingListItems.length}");
              return Text("אין מוצרים");
            }
            else {
              return ListView.builder(
                // scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      color: Colors.white,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 12,
                      onPressed: () {
                        print("Go to Item");
                      },
                      child: Text(shoppingListItems[index].product.name),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.black54,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  );
                },
                itemCount: shoppingListItems.length,
              );
            }
          }
          else {
            return CircularProgressIndicator();
          }
        }
    );
  }

  /// Get the entire page
  Widget getPage() {
    return SafeArea(
        child: SingleChildScrollView(
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
              Center(child: getItemsList()),
              Center(child: Text("הסוף"))
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(child: Text(currentShoppingList.name)),
        elevation: 0.0,
      ),
      body: getPage(),
    );
  }
}
