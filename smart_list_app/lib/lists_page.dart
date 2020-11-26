import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/join_list.dart';
import 'package:smart_list_app/list_page.dart';
import 'package:smart_list_app/create_list.dart';
import 'package:social_share/social_share.dart';
import 'package:smart_list_app/info_page.dart';
import 'package:smart_list_app/ad_manager.dart';
import 'package:smart_list_app/sign_up.dart';
import 'package:firebase_admob/firebase_admob.dart';

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
  bool _canPressShare = true;
  bool _canPressLeave = true;
  User currentUser;
  Future data;
  var tapPosition = Offset(0.0, 0.0);
  BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
    );
    _loadBannerAd();

    currentUser = widget.user;
    if (!widget.dataArrived) data = Api.getUserLists(currentUser);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  /// Share a list using the default share options
  void shareList(ShoppingList shoppingList) async {
    await SocialShare.shareOptions(
        "היי! הצטרף לרשימה המשותפת באפליקציית Super List!\n\nשם הרשימה שלי הוא: ${shoppingList.name}\nמספר הרשימה שלי הוא: ${shoppingList.uniqueID}");
    _canPressShare = true;
  }

  /// Save the location of press
  void _storePosition(TapDownDetails details) {
    tapPosition = details.globalPosition;
  }

  /// Go to view a shopping list page - all its items
  void goToList(ShoppingList shoppingList) {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return ListPage(
        user: currentUser,
        shoppingList: shoppingList,
        dataArrived: false,
      );
    }));
  }

  /// Go to create a new shopping list
  void goToCreateNewShoppingListPage() {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return CreateListPage(user: currentUser);
    }));
  }

  /// Go to join a list
  void goToJoinList() {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return JoinListPage(user: currentUser);
    }));
  }

  /// Go to info page
  void _goToInfoPage() {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return InfoPage();
    }));
  }

  /// Delete a list and remove it from the screen
  void _leaveList(ShoppingList shoppingList) async {
    Navigator.of(context).pop();
    Future.delayed(Duration(milliseconds: 200), () {
      Api.removeUserFromList(currentUser, currentUser, shoppingList);
      setState(() {
        currentUser.shoppingLists.remove(shoppingList);
      });
    });
  }

  void _leaveListAlert(ShoppingList shoppingList) {
    if (shoppingList.owner.pk == currentUser.pk) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AlertDialog(
            title: Text(
              "אופס",
              textDirection: TextDirection.rtl,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "אתה יצרת את הרשימה ומנהל אותה, לכן לא תוכל לעזוב אותה.",
              textDirection: TextDirection.rtl,
            ),
            actions: [
              FlatButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    "אוקיי",
                    style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold
                    ),
                  )),
            ],
          ));
    }
    else {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AlertDialog(
            title: Text(
              "לעזוב את הרשימה?",
              textDirection: TextDirection.rtl,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "אתם בטוחים שאתם רוצים לעזוב את הרשימה?",
              textDirection: TextDirection.rtl,
            ),
            actions: [
              FlatButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    "לא",
                    style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold
                    ),
                  )),
              FlatButton(
                  onPressed: () { _leaveList(shoppingList); },
                  child: Text(
                    "כן",
                    style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold
                    ),
                  )),
            ],
          ));
    }
    _canPressLeave = true;
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // deleteList(shoppingList);
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  shareList(shoppingList);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ]);
  }

  /// Get a one list object - the button
  Widget getListWidget(ShoppingList shoppingList) {
    // final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    return GestureDetector(
      // onTapDown: _storePosition,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlatButton(
          color: Colors.white,
          height: MediaQuery.of(context).size.height / 12,
          onPressed: () {
            goToList(shoppingList);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                child: Text(
                  shoppingList.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 7.0),
                    child: GestureDetector(
                        child: Icon(Icons.remove_shopping_cart_outlined),
                        onTap: () { _leaveListAlert(shoppingList); }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 7.0),
                    child: GestureDetector(
                        child: Icon(Icons.ios_share),
                        onTap: () {
                          if (_canPressShare)
                          {
                            _canPressShare = false;
                            shareList(shoppingList);
                          }
                        }
                    ),
                  ),
                ],
              )
            ],
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black54,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
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
                print(
                    "Number of shopping lists: ${currentUser.shoppingLists.length}");
                return Text("אין רשימות");
              } else {
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
            } else {
              return Center(
                  child: Container(
                      height: 40.0,
                      width: 40.0,
                      child: CircularProgressIndicator()));
            }
          });
    } else {
      if (currentUser.shoppingLists.isEmpty) {
        print("Number of shopping lists: ${currentUser.shoppingLists.length}");
        return Text("אין רשימות");
      } else {
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

  Widget _getInfoButton() {
    return IconButton(
      icon: Icon(
        Icons.info_outline,
        color: Colors.black54,
      ),
      onPressed: () {
        _goToInfoPage();
      },
    );
  }

  void _signOut() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_info.txt');
    file.delete();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<Null>(builder: (BuildContext context) {
      return SignUpPage();
    }), (Route<dynamic> route) => false);
  }

  void _signOutAlert() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
              title: Text(
                "להתנתק?",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                "בטוחים שאתם רוצים להתנתק?\nפעולה זו היא בלתי הפיכה!",
                textDirection: TextDirection.rtl,
              ),
              actions: [
                FlatButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(
                      "לא",
                      style: TextStyle(
                        color: Colors.black,
                        // fontWeight: FontWeight.bold
                      ),
                    )),
                FlatButton(
                    onPressed: _signOut,
                    child: Text(
                      "כן",
                      style: TextStyle(
                        color: Colors.black,
                        // fontWeight: FontWeight.bold
                      ),
                    )),
              ],
            ));
  }

  Widget _getSignOutButton() {
    return IconButton(
        icon: Icon(
          Icons.exit_to_app_outlined,
          color: Colors.red[300],
        ),
        onPressed: _signOutAlert);
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "שלום ${currentUser.name},",
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  Text(
                    "הרשימות שלך",
                    style: TextStyle(
                      fontSize: 34.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              getListsList(),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                textDirection: TextDirection.rtl,
                children: [
                  Container(color: Colors.green),
                  FlatButton.icon(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
                    icon: Icon(Icons.add_shopping_cart),
                    onPressed: goToCreateNewShoppingListPage,
                    label: Text(
                      "יצירת\nרשימה",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    shape: ContinuousRectangleBorder(
                        side: BorderSide(
                            color: Colors.black54,
                            width: 3,
                            style: BorderStyle.solid)),
                  ),
                  Container(color: Colors.grey),
                  FlatButton.icon(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
                    icon: Icon(Icons.person_add),
                    onPressed: goToJoinList,
                    label: Text(
                      "הצטרף\nלרשימה",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    shape: ContinuousRectangleBorder(
                        side: BorderSide(
                            color: Colors.black54,
                            width: 3,
                            style: BorderStyle.solid)),
                  ),
                  Container(color: Colors.grey),
                ],
              ),
              SizedBox(
                height: 80.0,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: _getSignOutButton(),
          elevation: 0.0,
          actions: [_getInfoButton()],
        ),
      ),
      body: Container(
        child: SafeArea(
          child: getBody(),
        ),
      ),
    );
  }
}
