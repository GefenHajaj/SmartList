import 'package:flutter/material.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/list_page.dart';


class ListsPage extends StatefulWidget {
  final User user;

  ListsPage({Key key, @required this.user});

  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  bool dataArrived = false;
  bool addingList = false;
  User currentUser;
  Future data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = widget.user;
    data = Api.getUserLists(currentUser);
  }

  /// Go to view a shopping list page - all its items
  void goToList(ShoppingList shoppingList) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return ListPage(user: currentUser, shoppingList: shoppingList);
        }));
  }

  /// Get the list of shopping lists.
  /// In case we're still waiting for response, show spinning logo.
  Widget getListsList() {
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
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      color: Colors.white,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 12,
                      onPressed: () {
                        goToList(currentUser.shoppingLists[index]);
                      },
                      child: Text(currentUser.shoppingLists[index].name),
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
                itemCount: currentUser.shoppingLists.length,
              );
            }
          }
          else {
            return CircularProgressIndicator();
          }
        }
    );
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
                    onPressed: () {print("Add a List");},
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
                    onPressed: () {print("Join a List");},
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
