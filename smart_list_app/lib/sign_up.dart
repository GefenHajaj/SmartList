import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_list_app/api.dart';
import 'package:smart_list_app/classes.dart';
import 'package:smart_list_app/lists_page.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String buttonText = "יש למלא שם משתמש";
  String normalButtonText = "הירשם";
  String warningButtonText = "יש למלא שם משתמש";

  Color buttonColor = Colors.grey[350];
  Color normalButtonColor = Colors.green[200];
  Color warningButtonColor = Colors.grey[350];
  Color successButtonColor = Colors.green;

  bool isButtonDisabled = true;
  String logoPath = "assets/smart_list_logo.png";

  String name = "";

  double sizedBoxSize = 60.0;

  User createdUser;

  @override
  void initState() {
    super.initState();
  }

  /// Try to sign up (if the user entered all the needed info).
  void trySignUp() {
    if (name != "") {
      setState(() {
        buttonText = "טוען...";
      });
      signUp();
    }
    else {
      setState(() {
        buttonText = warningButtonText;
        buttonColor = warningButtonColor;
      });
    }
  }

  /// Sign up
  void signUp() async {
    createdUser = await Api.createUser({"name": name});
    print(createdUser.name);
    print(createdUser.pk);
    print(createdUser.secret);

    // Save user data locally
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_info.txt');
    file.writeAsString(jsonEncode({
      "name": createdUser.name,
      "pk": createdUser.pk,
      "secret": createdUser.secret
    }));
    setState(() {
      buttonText = "נרשמנו!";
      buttonColor = successButtonColor;
      Navigator.of(context).push(MaterialPageRoute<Null>(
          builder: (BuildContext context) {
      return ListsPage(user: createdUser, dataArrived: false,);
      }));
    });
  }

  /// This function will return the entire page.
  Widget getPage() {
    Widget page = SafeArea(
        child: SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Image.asset(
              logoPath,
            ),
          ),
          SizedBox(height: sizedBoxSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                        "שם משתמש",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 18.0
                      ),
                    )
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: TextField(
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(2.0),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.name,
                    textDirection: TextDirection.rtl,
                    maxLength: 50,
                    onChanged: (input) {
                      setState(() {
                        name = input;
                        if (name != "") {
                          buttonColor = normalButtonColor;
                          buttonText = normalButtonText;
                          isButtonDisabled = false;
                        }
                        else {
                          buttonColor = warningButtonColor;
                          buttonText = warningButtonText;
                          isButtonDisabled = true;
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sizedBoxSize),
          Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              FlatButton(
                padding: EdgeInsets.all(15.0),
                  onPressed: isButtonDisabled ? null : () {
                    trySignUp();
                  },
                  color: buttonColor,
                  child: Center(child: Text(buttonText,
                  textDirection: TextDirection.rtl,
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  ))),
            ]),
          )
        ],
      ),
    )));
    return page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(),
    );
  }
}
