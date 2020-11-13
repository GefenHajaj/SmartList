import 'package:flutter/material.dart';
import 'package:smart_list_app/loading.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';


void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        fontFamily: 'Rubik',
        backgroundColor: Colors.yellow[50],
        scaffoldBackgroundColor: Colors.yellow[50],
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingPage(),
      },
    );
  }
}

