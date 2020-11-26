import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/lists_page.dart';
import 'package:smart_list_app/api.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:smart_list_app/sign_up.dart';
import 'package:smart_list_app/ad_manager.dart';
import 'package:firebase_admob/firebase_admob.dart';

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

  Future<void> _initAdMob() {
    // Initialize AdMob SDK
    return FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  }

  /// Check if the user is already registered.
  /// Go to a page according to result.
  Future checkIfAlreadySigned() async {
    final directory = await getApplicationDocumentsDirectory();
    File userFile = File('${directory.path}/user_info.txt');
    if (userFile.existsSync()) {
      print("Registered");
      Map userInfo = json.decode(await userFile.readAsString());
      print ('${userInfo['name']} - ${userInfo['pk']}');
      User user = new User(name: userInfo['name'], pk: userInfo['pk'], secret: userInfo['secret']);
      Api.connect(user);
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return ListsPage(user: user, dataArrived: false,);
          }), (Route<dynamic> route) => false);
    }
    else
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return SignUpPage();
          }), (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    checkIfAlreadySigned();
    _initAdMob();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
