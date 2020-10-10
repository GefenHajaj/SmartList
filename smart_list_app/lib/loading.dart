import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/lists_page.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:smart_list_app/sign_up.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

/// Serves as a loading page.
/// If the user is connected - go to lists page.
/// If it is a new user - register.
class _LoadingPageState extends State<LoadingPage> {
  String logoPath = "assets/smart_list_logo.png";
  Future connectedUser;

  /// Check if the user is already registered.
  /// Go to a page according to result.
  Future checkIfAlreadySigned() async {
    final directory = await getApplicationDocumentsDirectory();
    File userFile = File('${directory.path}/user_info1.txt');
    if (userFile.existsSync()) {
      print("Registered");
      // Todo: Call the API and tell him that the user connected
      Map userInfo = json.decode(await userFile.readAsString());
      print ('${userInfo['name']} - ${userInfo['pk']}');
      Navigator.of(context).push(MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return ListsPage(user: new User(name: userInfo['name'], pk: userInfo['pk']), dataArrived: false,);
          }));
    }
    else
      Navigator.of(context).push(MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return SignUpPage();
          }));
  }

  @override
  void initState() {
    super.initState();
    checkIfAlreadySigned();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CircularProgressIndicator(),
    );
  }
}
